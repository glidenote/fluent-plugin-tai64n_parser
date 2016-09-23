require_relative '../test_helper'
require 'fluent/plugin/filter_tai64n_parser'

class Tai64nParserFilterTest < Test::Unit::TestCase

  TAI64N_TIME = "@4000000052f88ea32489532c"
  PARSED_TIME = "2014-02-10 17:32:25.612979500"

  def setup
    Fluent::Test.setup
    @time = Fluent::Engine.now
  end

  def create_driver(conf)
    Fluent::Test::FilterTestDriver.new(
      Fluent::Tai64nParserFilter
    ).configure(conf)
  end

  def filter(config, msgs)
    d = create_driver(config)
    d.run {
      msgs.each {|msg|
        d.filter(msg, @time)
      }
    }
    filtered = d.filtered_as_array
    filtered.map {|m| m[2] }
  end

  def test_configure
    d = create_driver(%[
      key        test
      output_key parsed_time
    ])
    assert_equal 'test', d.instance.key
    assert_equal 'parsed_time', d.instance.output_key

    #Default Key
    d = create_driver(%[
    ])
    assert_equal 'tai64n', d.instance.key
    assert_equal 'tai64n', d.instance.output_key
  end

  def test_filter
    d = create_driver(%[
      key        tai64n
      output_key parsed_time
    ])
    record = {'tai64n' => TAI64N_TIME}
    d.run { d.filter(record, @time) }

    filtered_record = d.filtered_as_array.first[2]
    assert_equal PARSED_TIME, filtered_record['parsed_time']
  end

end if defined?(Fluent::Filter)
