#!/usr/bin/env ruby
puts "Loading environment..."
lib = File.expand_path('../../lib',  __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'active_fedora/aggregation'
require 'byebug'
puts "Ready"
ActiveFedora::Base.logger = Logger.new('logfile.log')

# When the log level is set to debug, log all LDP HTTP API traffic
class LogSubscriber < ActiveSupport::LogSubscriber
  def initialize
    super
    @odd = false
  end

  def http(event)
    return unless logger.debug?

    payload = event.payload

    name  = "#{payload[:name]} (#{event.duration.round(1)}ms)"
    url   = payload[:url] || "[no url]"

    if odd?
      name = color(name, CYAN, true)
      url  = color(url, nil, true)
    else
      name = color(name, MAGENTA, true)
    end

    debug "  #{name} #{url} Service: #{payload[:ldp_client]}"
  end

  def odd?
    @odd = !@odd
  end

  def logger
    ActiveFedora::Base.logger
  end
end

LogSubscriber.attach_to :ldp


class Foo < ActiveFedora::Base
  ordered_aggregation :members,
                    has_member_relation: ::RDF::DC.hasPart,
                    class_name: 'ActiveFedora::Base',
                    through: :list_source
end
class Bar < ActiveFedora::Base
end

i = Foo.create!

iterations = 30
require 'benchmark'

iterations.times do |n|
  time = Benchmark.measure do |x|
    # byebug if n > 10
    image = Foo.find(i.id)
    fs = Bar.create!
    image.ordered_members << fs
    image.save!
  end

  puts "#{n} - #{time.real}"
end

