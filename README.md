# ActiveFedora::Aggregation

Aggregations for ActiveFedora.

### Example
```ruby
class GenericFile < ActiveFedora::Base
end

generic_file1 = GenericFile.create
generic_file2 = GenericFile.create

class Image < ActiveFedora::Base
  aggregates :generic_files
end

image = Image.create
image.generic_files = [generic_file2, generic_file1]
image.save

```

Now the "generic\_files" method returns an ordered list of GenericFile objects.
