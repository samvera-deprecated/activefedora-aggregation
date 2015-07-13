module ActiveFedora::Filter
  class Builder < ActiveFedora::Associations::Builder::CollectionAssociation
    self.macro = :filter
    self.valid_options = [:extending_from, :condition]
  end
end

