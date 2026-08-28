# Ditto

Ditto adds an `acts_as_ditto` DSL to your ActiveRecord models for duplicating
records with custom control

Similar to `.dup`, but with the options like resetting attributes, applying static
overrides, running custom transformations, or recursively cloning associations.

And yes, the name comes from the Pokemon [Ditto](https://www.pokemon.com/us/pokedex/ditto), which can use its unique move transform to mirror any opposing Pokemon :D

## Installation

Install the gem and add it to the application's Gemfile by executing:

```bash
bundle add acts_as_ditto
```

## Usage

Call `acts_as_ditto` on a model, then duplicate records with `#ditto` or `#ditto!`:

```ruby
class Invoice < ApplicationRecord
  acts_as_ditto do
    override status: "draft"
  end
end
```

### Duplicating associatons

Recursively duplicates the given associations along with the record.

```ruby
acts_as_ditto do
  clone_associations :posts, :address
end
```

The associated model doesn't need `acts_as_ditto` itself, if it does, its own custom 
configuration is used, otherwise they're duplicated as is.

To duplicate multiple layers of associations, every model needs an `acts_as_ditto` configuration
that configures which associations get cloned.

### Nullifying attributes

Reset the given attributes to `nil` on the duplicate.

```ruby
acts_as_ditto do
  nullify :email
end
```

### Reset attributes to column defaults

Reset the given attributes to their column default on the duplicate.

```ruby
acts_as_ditto do
  reset_to_default :status
end
```

### Overwrite attributes with hardcoded values

Overwrites the given attributes with hardcoded values on the duplicate.

```ruby
acts_as_ditto do
  override status: "draft"
end
```

### Prefix or Suffix attributes

Prepend or append a string to an attributes current value.

```ruby
acts_as_ditto do
  prefix :name, "Copy of "
  suffix :name, " (Copy)"
end
```

### Transform attribute values

Transform attribute values with a block, yielded the record and the attribute's
original value.

```ruby
acts_as_ditto do
  transform :secret_number do |_record, old_value|
    old_value.reverse
  end
end
```

## Inspiration

Ditto was inspired by [amoeba](https://github.com/amoeba-rb/amoeba), which solves the same problem with similar DSL logic.

Ditto is opt-in rather than opt-out: you list exactly which associations to
clone with `clone_associations`, instead of enabling everything and excluding
what you don't want.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/njaeggi/acts_as_ditto. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/njaeggi/acts_as_ditto/blob/master/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
