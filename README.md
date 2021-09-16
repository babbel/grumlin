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

**Warning:** Grumlin is in development, but ready for simple use cases

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
end
```

### Traversing graphs

**Warning:** Not all steps and tools described in the standard are supported

#### Sugar

Grumlin provides an easy to use module called `Grumlin::Sugar`. Once included in your class it injects some useful
constants and methods turning your class into an entrypoint for traversals.

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

It is highly recommended to use `Grumlin::Sugar` and not trying to use lower level APIs as they are subject to change. 

## Development

Before running tests make sure you have gremlin-server running on your computer. The simplest way to run it is using 
[docker-compose](https://docs.docker.com/compose/) and provided `docker-compose.yml` and `gremlin_server/Dockerfile`:

    $ docker-compose up -d gremlin_server

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. 
You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update 
the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, 
push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/zhulik/grumlin. This project is intended to 
be a safe, welcoming space for collaboration, and contributors are expected to adhere to the 
[code of conduct](https://github.com/zhulik/grumlin/blob/master/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Grumlin project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/grumlin/blob/master/CODE_OF_CONDUCT.md).
