# Grumlin

[![Ruby](https://github.com/babbel/grumlin/actions/workflows/main.yml/badge.svg)](https://github.com/babbel/grumlin/actions/workflows/main.yml)
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


## Dependencies

Grumlin works with ruby >= 2.7, but it's recommended to use 3.1 due to [zlib warnings](https://github.com/socketry/async-websocket/issues/42).

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
some parts of it's functionality to comply provider's supported features.

To check current providers supported features use

```ruby
Grumlin.features
```

Current differences between providers:

| Feature      | TinkerGraph                                                                                                                                               |AWS Neptune|
|--------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------|-----------|
| Transactions | Transaction semantic is ignoroed, data is always writen, `tx.rollback` does nothing, an info is printed every time transactions are used with TinkerGraph |Full support

### Traversing graphs

**Warning**: Not all steps and expressions defined in the reference documentation are supported.

#### Grumlin::Repository
`Grumlin::Repository` - is a starting point for all traversals. It provides easy access to `g`, `__` and usual gremlin
expressions for you class. It has support for defining your own shortcuts and is even shipped with a couple of useful
shortcuts to make gremlin code more rubyish. **Classes extending `Grumlin::Repository`
or `Grumlin::Shortcuts` can be inherited**, successors don't need to extend them again and have access to shortcuts
defined in the ancestor.

**Definition**

```ruby
class MyRepository
  extend Grumlin::Repository
  # read_only! - forbids mutating queries for this repository. May be useful for separation reads and writes
  
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
- `add_vertex(label, id = nil, start: g, **properties)`
- `add_edge(label, id = nil, from:, to:, start: g, **properties)`
- `drop_vertex(id, start: g)`
- `drop_edge(id = nil, from: nil, to: nil, label: nil, start: g)`
- `drop_in_batches(traversal, batch_size: 10_000)`

and a few methods that emulate upserts:
- `upsert_vertex(label, id, create_properties: {}, update_properties: {}, on_failure: :retry, start: g, **params)`
- `upsert_vertices(edges, batch_size: 100, on_failure: :retry, start: g, **params)`
- `upsert_edge(label, from:, to:, create_properties: {}, update_properties: {}, on_failure: :retry, start: g, **params)`
- `upsert_edges(edges, batch_size: 100, on_failure: :retry, start: g, **params)`

**Note**: all upsert methods expect your provider has support for user supplied string ids for nodes and edges 
respectively. For edges and if `create_properties[T.id]` if nil, grumlin will generate a uuid-like id out of `from` and
`to` vertex ids and edge's label to ensure uniqueness of the edge. If you manually provide an id, it's your 
responsibility to ensure it's uniquely identifies the edge using it's `from`, `to` and `label`.

All of them support 3 different modes for error handling: `:retry`, `:ignore` and `:raise`. Retry mode is implemented
with [retryable](https://github.com/nfedyashev/retryable). **params will be merged to the default config for upserts
and passed to `Retryable.retryable`. In case if you want to modify retryable behaviour you are to do so.

If you want to use these methods inside a transaction simply pass your `gtx` as `start` parameter:
```ruby
g.tx do |gtx|
  add_vertex(:vertex, start: gtx)
end
```

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

#### Shortcuts

**Shortcuts** is a way to share and organize gremlin code. They let developers define their own steps consisting of
sequences of standard gremlin steps, other shortcuts and even add new initially unsupported by Grumlin steps.
Remember ActiveRecord scopes? Shortcuts are very similar.

**Important**: if a shortcut's name matches a name of a method defined on the wrapped object, this shortcut will be
be ignored because methods have higher priority.

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

##### Middlewares

Middlewares can be used to perform certain actions before and after every query made by `Grumlin`. It can be useful for
measuring query execution time or performing some modification or validation to the query before it reaches the server or
modify the response before client gets it.

See [doc/middlewares.md](doc/middlewares.md) for more info and examples.

#### Transactions

Since 0.22.0 `Grumlin` supports transactions when working with providers that supports them:
```ruby
# Using Transaction directly
tx = g.tx
gtx = tx.begin
gtx.addV(:vertex).iterate
tx.commit # or tx.rollback

# Using with a block
g.tx do |gtx|
  gtx.addV(:vertex).iterate
  # raise Grumlin::Rollback to manually rollback
  # any other exception will also rollback the transaction and will be reraised 
end # commits automatically
```

#### IRB

Please check out [bin/console](bin/console) for inspiration. A similar trick may be applied to PRY.

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
config.include_context(Grumlin::Test::RSpec::GremlinContext) # Injects `g`, `__` and expressions, makes sure client is closed after every test
config.include_context(Grumlin::Test::RSpec::DBCleanerContext) # Cleans the database before every test
...
```

It is highly recommended to use `Grumlin::Repository` and not trying to use lower level APIs as they are subject to 
change.

#### Using in a web app

As previously mentioned, `Grumlin` is built on top of the [async stack](https://github.com/socketry/async).
This basically means you'd either have to use [Falcon](https://github.com/socketry/falcon) as you application server,
or you'd need to wrap every place where you use `Grumlin` into an `Async` block:

```ruby
Async do
  MyGrumlinRepository.some_query
ensure
  Grumlin.close
end
```

`Falcon` is preferred because it can keep connections to your Gremlin server open between requests. The only downside
is that `ActiveRecord` currently does not play well with ruby's fiber scheduler so far, and it can block the event loop.
When using `Falcon` you don't need explicit `Async` blocks.

Currently it's not recommended to use `ActiveRecord` with `Falcon`. If you still need access to a SQL database from your app,
consider using [socketry/db](https://github.com/socketry/db)

#### Rails console

In order to make it possible to execute gremlin queries from the rails console you need to define
a custom console class. It should look somewhat like

```ruby
class Async::RailsConsole
  extend Grumlin::Repository

  def start
    self.class.shortcuts_from Shortcuts::Content

    IRB::WorkSpace.prepend(Rails::Console::BacktraceCleaner)
    IRB::ExtendCommandBundle.include(Rails::ConsoleMethods)

    IRB.setup(binding.source_location[0], argv: [])
    workspace = IRB::WorkSpace.new(binding)

    begin
      Async do
        IRB::Irb.new(workspace).run(IRB.conf)
      ensure
        Grumlin.close
      end
    rescue StandardError, Interrupt, Async::Stop, IRB::Abort
      retry
    end
  end

  def inspect
    'main'
  end

  def to_s
    inspect
  end
end
```

#### AWS Neptune

See [docs/neptune.md](./docs/neptune.md)

#### Sidekiq

See [docs/neptune.md](./docs/sidekiq.md)

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
[code of conduct](https://github.com/babbel/grumlin/blob/master/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Grumlin project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/grumlin/blob/master/CODE_OF_CONDUCT.md).
