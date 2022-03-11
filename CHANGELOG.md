## [0.16.0] - 2022-03-11

- Query building is rewritten from scratch. No public APIs were changed. [Details](https://github.com/babbel/grumlin/pull/64)
- Add support for [TextP](https://tinkerpop.apache.org/javadocs/current/core/org/apache/tinkerpop/gremlin/process/traversal/TextP.html)

## [0.15.4] - 2022-01-20

- Move step and expression definitions to a yaml file for better diffs
- Add `definitions:format` rake task

## [0.15.3] - 2022-01-18

- Fix passing nils as step arguments. Even if they are not supported by the server, they should not be omitted.

## [0.15.2] - 2022-01-17

- New steps: `map` and `identity`

## [0.15.1] - 2022-01-17

- Fix passing arrays as step arguments

## [0.15.0] - 2022-01-11

- Add `properties` step
- Add proper support for bulked results
- Add support for `Property` objects

## [0.14.5] - 2021-12-27

- Fix params handling
- Add `aggregate` step
- Add `Order.shuffle`

## [0.14.4] - 2021-12-17

- `Grumlin::Repository.shorcuts_from` do not raise `ArgumentError` when importing an already existing shortcut
  pointing to the same block. This fixes importing shortcuts from another repository.

## [0.14.2] - 2021-12-13

- Fix `Module` bloating
- Add `Operator` expressions
- Add `__.coalesce` and `__.constant`
- Add steps: `sum`, `sack`
- Add configuration steps: `withSack`
- Rename `Grumlin::Expressions::Tool` to `Grumlin::Expressions::Expression`


## [0.14.2] - 2021-12-12

- Better exceptions
- Add `choose` step
- Add `__.hasNot`, `__.is`, `__.select`

## [0.14.0] - 2021-12-07

- Add initial support for [configuration steps](https://tinkerpop.apache.org/docs/current/reference/#configuration-steps)
- Add the `withSideEffect` configuration step
- Fix passing keyword arguments to regular steps
- *Drop support for ruby 2.6*

## [0.13.0] - 2021-12-03

- Add `Shortcuts` and `Repository`
- Allow executing any gremlin steps by name using `Grumlin::AnonymousStep#step`
- Rename `Grumlin::Tools` to `Grumlin::Expressions`

## [0.1.0] - 2021-05-25

- Initial release
