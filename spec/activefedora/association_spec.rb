require 'spec_helper'

describe ActiveFedora::Aggregation::Association do
  before do
    class GenericFile < ActiveFedora::Base
      contains :original
    end

    class Image < ActiveFedora::Base
      aggregates :generic_files
    end
  end
  let(:generic_file1) { GenericFile.create }
  let(:generic_file2) { GenericFile.create }

  let(:image) { Image.create }

  before do
    image.generic_files = [generic_file2, generic_file1]
    image.save
  end

  let(:reloaded) { Image.find(image.id) } # because reload doesn't clear this association

  it "should save the images in order" do
    expect(reloaded.generic_files).to eq [generic_file2, generic_file1]
  end
end
