## Argument Labeled

Add a handful of convenient methods to
Module, which make working with argument hashes in Ruby a bit easier.

## Requirements

- This only works with Ruby 1.9. This, however, is as far as I know no
  big problem because there is also a gem for Ruby 1.8.


## Special notes

* You shouldn't redefine any of the \*\_arguments methods
  (as in

      class Test; def self.default_arguments; nil; end; end

  because then you won't be able to use the ones from our package
  unless you use `::Module.default_arguments`

* default arguments are to be passed as blocks returning hashes.
