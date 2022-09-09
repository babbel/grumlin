# Middlewares

Every single query performed by `Grumlin` goes through a stack of middlewares just like every single request in Rails 
or many other web frameworks. `Grumlin` ships with a set of middlewares, each one performs some part of the query
execution process:

- `Middlewares::SerializeToSteps` - converts a `Step` into `Steps`
- `Middlewares::ApplyShortcuts` - applies shortcuts to `Steps`
- `Middlewares::SerializeToBytecode` - converts `Steps` into bytecode
- `Middlewares::BuildQuery` - builds an actual message that will be send to server
- `Middlewares::CastResults` - casts server response into ruby objects
- `Middlewares::RunQuery` - actually sends the message to the server

Normally these middlewares must never be rearranged or removed from the stack. Middlewares added after
`Middlewares::RunQuery` will not be executed.

## Writing a middleware for Grumlin

This entire feature is built on top of [ibsciss-middleware](https://github.com/Ibsciss/ruby-middleware) but uses a
slightly modified `Builder` which caches the chain for better performance.
Please refer to ibsciss-middleware docs if you want to implement a middleware.


A minimal middleware that measures query execution time and puts it back to `env`:

```ruby
class MeasureExecutionTime < Grumlin::Middlewares::Middleware # Middleware provides only an initializer with one argument for `app`
  def call(env)
    started = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    result = @app.call(env)
    env[:execution_time] = Process.clock_gettime(Process::CLOCK_MONOTONIC) - started
    result
  end
end
```

When placed right before `Grumlin::Middlewares::CastResults` your middleware will have access to every intermediate result
of the query execution process:
- `env[:traversal]` - contains the original traversal
- `env[:steps]` - contains the `Steps` representing the traversal
- `env[:steps_without_shortcuts]` - contains the `Steps` representing the traversal, but with all shortcuts applied
- `env[:bytecode]` - raw bytecode of the traversal
- `env[:query]` - raw message that will be sent to the server. `requestId` can be found here: `env[:query][:requestId]`

After the query is performed (after `@app.call(env)`), these keys become available:
- `env[:results]` - raw results received from the server
- `env[:parsed_results]` - server results mapped to ruby types, basically the query results as the client gets it

Other useful parts of `env`:
- `env[:session_id]` - id of the session when executed inside a transaction, otherwise `nil`
- `env[:pool]` - connection pool that will be used to interact with the server
- `env[:need_results]` - flag stating whether the client needs the query execution results(`toList`, `next`) or not(`iterate`)

## Adding your middleware to the stack

There are two ways of adding middlewares to your queries:
- `global` - add the middleware to every single query from every single repository
- `per repository` - add the middleware to queries performed by particular repositories

Grumlin has one global middleware stack and every repository defines it's which is by default is a
copy of the global stack. This means one can easily modify repository's stack without worrying about the global one.

When inherited a class extending `Grumlin::Repository` will copy it's middlewares to the subclass, they can also be
modified independently from the parent's middlewares.

### Adding a middleware globally
```ruby
Grumlin.configure do |cfg|
  cfg.url = ENV.fetch("GREMLIN_URL", "ws://localhost:8182/gremlin")
  cfg.provider = :tinkergraph

  cfg.middlewares do |b|
    b.insert_before Grumlin::Middlewares::CastResults, MeasureExecutionTime
  end
end
```

### Adding a middleware to a repository
```ruby
class MyRepository
  # MyRepository inherits a copy of global middlewares
  extend Grumlin::Repository

  # SomeOtherMiddleware will be added to MyRepository's middlewares only
  middlewares do |b|
    b.insert_before Grumlin::Middlewares::CastResults, MeasureExecutionTime
  end
end

class AnotherRepository < MyRepository
  # AnotherRepository inherits parent's middlewares
  middlewares do |b|
    # SomeOtherMiddleware will be added to AnotherRepository's middlewares only 
    b.insert_before Grumlin::Middlewares::CastResults, SomeOtherMiddleware
  end
end
```