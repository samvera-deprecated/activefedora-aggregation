[![Gem Version](https://badge.fury.io/rb/activefedora-aggregation.svg)](http://badge.fury.io/rb/activefedora-aggregation) [![Build Status](https://circleci.com/gh/projecthydra-labs/activefedora-aggregation.svg?style=shield&circle-token=:circle-token)](https://circleci.com/gh/projecthydra-labs/activefedora-aggregation)
# ActiveFedora::Aggregation

Aggregations for ActiveFedora: manage a group of related objects using predicates from the
[OAI-ORE data model](http://www.openarchives.org/ore/1.0/datamodel).  Provides the foundation
for flexible relationships, including items appearing multiple times in a group,
flexible/optional ordering, etc.

Used extensively by [Hydra::PCDM](https://github.com/projecthydra-labs/hydra-pcdm/).

### Example
```ruby
class GenericFile < ActiveFedora::Base
end

generic_file1 = GenericFile.create(id: 'file1')
generic_file2 = GenericFile.create(id: 'file2')
generic_file3 = GenericFile.create(id: 'file3')

class Image < ActiveFedora::Base
  ordered_aggregation :generic_files, through: :list_source
end

image = Image.create(id: 'my_image')
image.ordered_generic_file_proxies.append_target generic_file2
image.ordered_generic_file_proxies.append_target generic_file1
image.save
image.generic_files # => [#<GenericFile id: "file2">, #<GenericFile id: "file1">]
image.ordered_generic_files.to_a # => [#<GenericFile id: "file2">, #<GenericFile id: "file1">]

# Not all generic files must be ordered.
image.generic_files += [generic_file3]
image.generic_files => [#<GenericFile id: "file2">, #<GenericFile id: "file1">, #<GenericFile id: "file3">]
image.ordered_generic_files.to_a => [#<GenericFile id: "file2">, #<GenericFile id: "file1">]

# non-ordered accessor is not ordered.
image.ordered_generic_file_proxies.insert_target_at(0, generic_file3)
image.generic_files # => [#<GenericFile id: "file2">, #<GenericFile id: "file1">, #<GenericFile id: "file3">]
image.ordered_generic_files.to_a # => [#<GenericFile id: "file3">, #<GenericFile id: "file2">, #<GenericFile id: "file1">] 

# Deletions
image.ordered_generic_file_proxies.delete_at(1) => #<GenericFile id: "file2">
image.ordered_generic_files.to_a # => [#<GenericFile id: "file3">, #<GenericFile id: "file1">]
image.generic_files # => [#<GenericFile id: "file2">, #<GenericFile id: "file1">, #<GenericFile id: "file3">]
```
