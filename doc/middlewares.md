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

Normally these middlewares must never be rearranged or removed from the stack. Middlewares added after `Middlewares::RunQuery`
will not be executed.

# Writing a middleware for Grumlin

TODO
