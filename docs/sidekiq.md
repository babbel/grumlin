# Sidekiq

Sidekiq does not use event loop, so you'd have to use explicit `Async` blocks:

```ruby
class MyWorker
  include Sidekiq::Worker

  def perform
    Async do
      MyGrumlinRepository.some_query
    ensure
      Grumlin.close
    end
  end
end
```

As the other option you can use a server middleware:

```ruby
# async_server_middleware.rb

class AsyncServerMiddleware
  def call(_worker, _job, _queue)
    Async do
      yield
    ensure
      Grumlin.close
    end
  end
end
```

```ruby
# config/initializers/sidekiq.rb

Sidekiq.configure_server do |config|
  config.server_middleware do |chain|
    chain.add AsyncServerMiddleware
  end

  config.on(:shutdown) do
    Grumlin.close
  end
end
```
