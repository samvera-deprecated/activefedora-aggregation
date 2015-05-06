[![Gem Version](https://badge.fury.io/rb/activefedora-aggregation.svg)](http://badge.fury.io/rb/activefedora-aggregation) [![Build Status](https://travis-ci.org/projecthydra-labs/activefedora-aggregation.svg)](https://travis-ci.org/projecthydra-labs/activefedora-aggregation)
# ActiveFedora::Aggregation

Aggregations for ActiveFedora.

### Example
```ruby
class GenericFile < ActiveFedora::Base
end

generic_file1 = GenericFile.create(id: 'file1')
generic_file2 = GenericFile.create(id: 'file2')

class Image < ActiveFedora::Base
  aggregates :generic_files
end

image = Image.create(id: 'my_image')
image.generic_files = [generic_file2, generic_file1]
image.save

```

Now the `generic\_files` method returns an ordered list of GenericFile objects.
