[![Gem Version](https://badge.fury.io/rb/activefedora-aggregation.svg)](http://badge.fury.io/rb/activefedora-aggregation) [![Build Status](https://travis-ci.org/curationexperts/activefedora-aggregation.svg?branch=v0.1.0)](https://travis-ci.org/curationexperts/activefedora-aggregation)
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

Here's what the graph looks like:

```ttl
<http://127.0.0.1:8983/fedora/rest/dev/2f/9e/8e/04/2f9e8e04-e4c9-49c9-99ae-4fb24ab3e52d> a <http://www.w3.org/ns/ldp#RDFSource>,
     <http://www.w3.org/ns/ldp#Container>;
   <http://www.w3.org/ns/ldp#contains> <http://127.0.0.1:8983/fedora/rest/dev/2f/9e/8e/04/2f9e8e04-e4c9-49c9-99ae-4fb24ab3e52d/files>;
   <info:fedora/fedora-system:def/model#hasModel> "Image" .

<http://127.0.0.1:8983/fedora/rest/dev/2f/9e/8e/04/2f9e8e04-e4c9-49c9-99ae-4fb24ab3e52d/files> a <http://www.w3.org/ns/ldp#RDFSource>,
     <http://www.w3.org/ns/ldp#Container>;
   <http://www.iana.org/assignments/relation/first> <http://127.0.0.1:8983/fedora/rest/dev/2f/9e/8e/04/2f9e8e04-e4c9-49c9-99ae-4fb24ab3e52d/files/5a5af870-594b-4966-93f6-0348402583f0>;
   <http://www.iana.org/assignments/relation/last> <http://127.0.0.1:8983/fedora/rest/dev/2f/9e/8e/04/2f9e8e04-e4c9-49c9-99ae-4fb24ab3e52d/files/9cc70b3d-c9d7-4cfc-b504-adbcb0bdfb3d>;
   <http://www.w3.org/ns/ldp#contains> <http://127.0.0.1:8983/fedora/rest/dev/2f/9e/8e/04/2f9e8e04-e4c9-49c9-99ae-4fb24ab3e52d/files/5a5af870-594b-4966-93f6-0348402583f0>,
     <http://127.0.0.1:8983/fedora/rest/dev/2f/9e/8e/04/2f9e8e04-e4c9-49c9-99ae-4fb24ab3e52d/files/9cc70b3d-c9d7-4cfc-b504-adbcb0bdfb3d>;
   <info:fedora/fedora-system:def/model#hasModel> "ActiveFedora::Aggregation::Aggregator" .

<http://127.0.0.1:8983/fedora/rest/dev/2f/9e/8e/04/2f9e8e04-e4c9-49c9-99ae-4fb24ab3e52d/files/5a5af870-594b-4966-93f6-0348402583f0> a <http://www.w3.org/ns/ldp#RDFSource>,
     <http://www.w3.org/ns/ldp#Container>;
   <http://www.iana.org/assignments/relation/next> <http://127.0.0.1:8983/fedora/rest/dev/2f/9e/8e/04/2f9e8e04-e4c9-49c9-99ae-4fb24ab3e52d/files/9cc70b3d-c9d7-4cfc-b504-adbcb0bdfb3d>;
   <http://www.openarchives.org/ore/terms/proxyFor> <http://127.0.0.1:8983/fedora/rest/dev/34/61/5e/ae/34615eae-73db-48b3-a09d-05b76e8db86b>;
   <http://www.openarchives.org/ore/terms/proxyIn> <http://127.0.0.1:8983/fedora/rest/dev/2f/9e/8e/04/2f9e8e04-e4c9-49c9-99ae-4fb24ab3e52d/files>;
   <info:fedora/fedora-system:def/model#hasModel> "ActiveFedora::Aggregation::Proxy" .

<http://127.0.0.1:8983/fedora/rest/dev/2f/9e/8e/04/2f9e8e04-e4c9-49c9-99ae-4fb24ab3e52d/files/9cc70b3d-c9d7-4cfc-b504-adbcb0bdfb3d> a <http://www.w3.org/ns/ldp#RDFSource>,
     <http://www.w3.org/ns/ldp#Container>;
   <http://www.iana.org/assignments/relation/prev> <http://127.0.0.1:8983/fedora/rest/dev/2f/9e/8e/04/2f9e8e04-e4c9-49c9-99ae-4fb24ab3e52d/files/5a5af870-594b-4966-93f6-0348402583f0>;
   <http://www.openarchives.org/ore/terms/proxyFor> <http://127.0.0.1:8983/fedora/rest/dev/95/2a/5d/0c/952a5d0c-69c0-4231-9dfa-221d26be7786>;
   <http://www.openarchives.org/ore/terms/proxyIn> <http://127.0.0.1:8983/fedora/rest/dev/2f/9e/8e/04/2f9e8e04-e4c9-49c9-99ae-4fb24ab3e52d/files>;
   <info:fedora/fedora-system:def/model#hasModel> "ActiveFedora::Aggregation::Proxy" .
```
