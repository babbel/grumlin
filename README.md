# Grumlin

[![Ruby](https://github.com/zhulik/grumlin/actions/workflows/main.yml/badge.svg)](https://github.com/zhulik/grumlin/actions/workflows/main.yml)
[![standard-readme compliant](https://img.shields.io/badge/readme%20style-standard-brightgreen.svg?style=flat-square)](https://github.com/RichardLitt/standard-readme)
[![MIT license](https://img.shields.io/badge/License-MIT-blue.svg)](https://lbesson.mit-license.org/)

Grumlin is a [Gremlin](https://tinkerpop.apache.org/gremlin.html) graph traversal language DSL and client for Ruby. 
Suitable for and tested with [gremlin-server](http://tinkerpop.apache.org/) and [AWS Neptune](https://aws.amazon.com/neptune/).

**Important**: Grumlin and it's author are not affiliated with The Apache Software Foundation which develops gremlin
and gremlin-server.

**Important**: Grumlin is based on the [async stack](https://github.com/socketry/async) and utilizes 
[async-websocket](https://github.com/socketry/async-websocket). Code using grumlin must be executed in an async
event loop.

**Warning**: Grumlin is in development, but ready for simple use cases

## Table of contents
- [Install](#install)
- [Usage](#usage)
- [Development](#development)
- [Contributing](#contributing)
- [License](#license)
- [Code Of Conduct](#code-of-conduct)

## Install

Add this line to your application's Gemfile:

```ruby
gem 'grumlin'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install grumlin

## Usage

### Configuration
```ruby
Grumlin.configure do |config|
  config.url = "ws://localhost:8182/gremlin"

  # make sure you select right provider for better compatibility
  config.provider = :tinkergraph
end
```

#### Providers

Currently `Grumlin` supports 2 providers:
- tinkergraph (default)
- neptune

As different providers may have or may have not support for specific features it's recommended to
explicitly specify the provider you use.

#### Provider features

Every provider is described by a set of features. In the future `Grumlin` may decide to disable or enable 
some parts of it's functionality to comply provider's supported features. Currently there is no difference
in behaviour when working with different providers.

To check current providers supported features use

```ruby
Grumlin.features
```

### Traversing graphs

**Warning**: Not all steps and expressions defined in the reference documentation are supported.

#### Sugar

Grumlin provides an easy to use module called `Grumlin::Sugar`. Once included in your class it injects some useful
constants and methods turning your class into an entrypoint for traversals with pure gremlin experience.

```ruby
class MyRepository
  include Grumlin::Sugar
  
  def nodes(property1:, property2:)
    g.V()
      .has(T.label, "node")
      .has(:property1, property1)
      .has(:property2, property2)
      .order.by(:property3, Order.asc).limit(10)
      .toList
  end
end
```

#### Shortcuts

**Shortcuts** is a way to share and organize gremlin code. They let developers define their own steps consisting of
sequences of standard gremlin steps, other shortcuts and even add new initially unsupported by Grumlin steps.
Remember ActiveRecord scopes? Shortcuts are very similar.

**Important**: if a shortcut's name matches a name of a method defined on the wrapped object, this shortcut will be
be ignored because methods have higher priority.

Shortcuts are designed to be used with `Grumlin::Repository` but still can be used separately, with `Grumlin::Sugar`
for example.

**Defining**:
```ruby

# Defining shortcuts
class ColorShortcut
  extend Grumlin::Shortcuts

  # Custom step
  shortcut :hasColor do |color|
    has(:color, color)
  end
end

class ChooseShortcut
  extend Grumlin::Shortcuts

  # Standard Gremlin step
  shortcut :choose do |*args|
    step(:choose, *args)
  end
end

class AllShortcuts
  extend Grumlin::Shortcuts

  # Adding shortcuts from other modules
  shortcuts_from ColorShortcut
  shortcuts_from ChooseShortcut
end
```

**Using with Grumlin::Sugar**:
```ruby
class MyRepository
  include Grumlin::Sugar
  extend Grumlin::Shortcuts

  shortcuts_from AllShortcuts

  # Wrapping a traversal
  def red_triangles
    g(self.class.shortcuts).V.hasLabel(:triangle)
       .hasColor("red")
       .toList
  end

  # Wrapping _
  def something_else
    g(self.class.shortcuts).V.hasColor("red")
       .repeat(__(self.class.shortcuts))
       .out(:has)
       .hasColor("blue")
       .toList
  end
end
```

##### Overriding standard steps and shortcuts

Sometimes it may be useful to override standard steps. Grumlin does not allow it by default, but one
is still able to override standard steps if they know what they are doing:

```ruby
shortcut :addV, override: true do |label|
  super(label).property(:default, :value)
end
```

This will create a new shortcut that overrides the standard step `addV` and adds default properties to all vertices
created by the repository that uses this shortcut.

Shortcuts also can be overridden, but super() is not available.

#### Grumlin::Repository
`Grumlin::Repository` combines functionality of `Grumlin::Sugar` and `Grumlin::Shortcuts` as well as adds a few useful
shortcuts to make gremlin code more rubyish. Can be used as a drop in replacement for `Grumlin::Sugar`. Remember that
`Grumlin::Sugar` needs to be included, but `Grumlin::Repository` - extended. **Classes extending `Grumlin::Repository`
or `Grumlin::Shortcuts` can be inherited**, successors don't need to extend them again and have access to shortcuts 
defined in the ancestor.

**Definition**

```ruby
class MyRepository
  extend Grumlin::Repository

  # Repository supports all Grumlin::Shortcut and Grumlin::Sugar features.
  # It can add shortcuts from another repository or a shortcuts module
  shortcuts_from ChooseShortcut
  
  shortcut :red_triangles do |color|
    # hasAll unwraps a hash of properties into a chain of `has` steps:
    # hasAll(name1: :value, name2: :value) == has(:name1, :value).has(:name2, :value)
    # the `props` shortcut does exactly the same but with `property` steps.
    hasAll(T.label => :triangle, color: color)
  end

  # `default_vertex_properties` and `default_edge_properties`
  # override `addV` and `addE` according and inject hashes returned from passed
  # as properties for newly created vertices and edges.
  # In case if a repository is inherited, newly defined default properties will be merged to
  # default properties defined in the parent repository.
  default_vertex_properties do |_label|
    {
      created_at: Time.now.to_i
    }
  end

  default_edge_properties do |_label|
    {
      created_at: Time.now.to_i
    }
  end

  # g and __ are already aware of shortcuts
  query(:triangles_with_color, return_mode: :list) do |color| # :list is the default return mode, also possible: :none, :single, :traversal
    g.V.hasLabel(:triangle)
       .hasColor(color)
  end
  # Note that when using the `query` one does not need to call a termination step like `next` or `toList`,
  # repository does it automatically in according to the `return_mode` parameter. 
end
```

Each `return_mode` is mapped to a particular termination step:
- `:list` - `toList`
- `:single` - `next`
- `:none` - `iterate`
- `:traversal` - do not execute the query and return the traversal as is

`Grumlin::Repository` also provides a set of generic CRUD operations:
- `add_vertex(label, id = nil, **properties)`
- `add_edge(label, id = nil, from:, to:, **properties)`
- `drop_vertex(id)`
- `drop_edge(id = nil, from: nil, to: nil, label: nil)`

and a few methods that emulate upserts:
- `upsert_vertex(label, id, create_properties: {}, update_properties: {}, on_failure: :retry, **params)` 
- `upsert_edge(label, from:, to:, create_properties: {}, update_properties: {}, on_failure: :retry, **params)`
- `upsert_edges(edges, batch_size: 100, on_failure: :retry, **params)`
- `upsert_vertices(edges, batch_size: 100, on_failure: :retry, **params)`

All of them support 3 different modes for error handling: `:retry`, `:ignore` and `:raise`. Retry mode is implemented
with [retryable](https://github.com/nfedyashev/retryable). **params will be merged to the default config for upserts 
and passed to `Retryable.retryable`. In case if you want to modify retryable behaviour you are to do so.

If you don't want to define you own repository, simply use

`Grumlin::Repository.new` returns an instance of an anonymous class extending `Grumlin::Repository`. 

**Usage**

To execute the query defined in a query block one simply needs to call a method with the same name:

`MyRepository.new.triangles_with_color(:red)`

One can also override the `return_mode`:

`MyRepository.new.triangles_with_color(:red, query_params: { return_mode: :single })`

or even pass a block to the method and a raw traversal will be yielded:
```ruby
MyRepository.new.triangles_with_color(:red) do |t|
  t.has(:other_property, :some_value).toList
end
```
it may be useful for debugging. Note that one needs to call a termination step manually in this case.

`query` also provides a helper for profiling requests:
`MyRepository.new.triangles_with_color(:red, query_params: { profile: true })`

method will return profiling data of the results.

#### IRB

An example of how to start an IRB session with support for executing gremlin queries:

```ruby
Async do
  include Grumlin::Sugar

  IRB.start
ensure
  Grumlin.close
end
```

Please check out [bin/console](bin/console) for full source. A similar trick may be applied to PRY.

#### Rails console

In order to make it possible to execute gremlin queries from the rails console you need to define
a custom console class. It should look somehow like

```ruby
class MyRailsConsole
  def self.start
    IRB::WorkSpace.prepend(Rails::Console::BacktraceCleaner)
    IRB::ExtendCommandBundle.include(Rails::ConsoleMethods)

    Async do
      include Grumlin::Sugar

      IRB.setup(binding.source_location[0], argv: [])
      workspace = IRB::WorkSpace.new(binding)

      IRB::Irb.new(workspace).run(IRB.conf)
    ensure
      Grumlin.close
    end
  end
end
```

Then you need to reference it in your application.rb:
```ruby
config.console = MyRailsConsole
```

#### Testing

Grumlin provides a couple of helpers to simplify testing code written with it.

##### RSpec

Make sure you have [async-rspec](https://github.com/socketry/async-rspec) installed.

`spec_helper.rb` or `rails_helper.rb`:
```ruby
require 'async/rspec'
require require "grumlin/test/rspec"
...
config.include_context(Async::RSpec::Reactor) # Runs async reactor
config.include_context(Grumlin::Test::RSpec::GremlinContext) # Injects sugar and makes sure client is closed after every test
config.include_context(Grumlin::Test::RSpec::DBCleanerContext) # Cleans the database before every test
...
```

It is highly recommended to use `Grumlin::Sugar` or `Grumlin::Repository` and not trying to use lower level APIs
as they are subject to change.

## Development

Before running tests make sure you have gremlin-server running on your computer. The simplest way to run it is using 
[docker-compose](https://docs.docker.com/compose/) and provided `docker-compose.yml` and `gremlin_server/Dockerfile`:

    $ docker-compose up -d gremlin_server

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. 
You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update 
the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, 
push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

### Adding new steps and expressions
To add a new step or an expression simple put it to the corresponding list in [definitions.yml](lib/definitions.yml)
and run `rake definitions:format`. You don't need to properly sort the lists manually, the rake task will do it for you.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/zhulik/grumlin. This project is intended to 
be a safe, welcoming space for collaboration, and contributors are expected to adhere to the 
[code of conduct](https://github.com/zhulik/grumlin/blob/master/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Grumlin project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/grumlin/blob/master/CODE_OF_CONDUCT.md).
