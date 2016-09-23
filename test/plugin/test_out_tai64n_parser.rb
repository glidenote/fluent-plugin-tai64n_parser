require_relative '../test_helper'
require 'fluent/plugin/out_tai64n_parser'

class Tai64nParserOutputTest < Test::Unit::TestCase

  TAI64N_TIME = "@4000000052f88ea32489532c"
  PARSED_TIME = "2014-02-10 17:32:25.612979500"

  def setup
    Fluent::Test.setup
  end

  def create_driver(conf, tag = 'test')
    Fluent::Test::OutputTestDriver.new(
      Fluent::Tai64nParserOutput, tag
    ).configure(conf)
  end

  def test_configure
    d = create_driver(%[
      key            test
      output_key     parsed_time
      add_tag_prefix parsed.
    ])
    assert_equal 'test', d.instance.key
    assert_equal 'parsed_time', d.instance.output_key
    assert_equal 'parsed.', d.instance.add_tag_prefix

    #Default Key
    d = create_driver(%[
      add_tag_prefix parsed.
    ])
    assert_equal 'tai64n', d.instance.key
    assert_equal 'tai64n', d.instance.output_key
    assert_equal 'parsed.', d.instance.add_tag_prefix
  end

  def test_filter_record
    d = create_driver(%[
      key            tai64n
      output_key     parsed_time
      add_tag_prefix parsed.
    ])
    tag    = 'test'
    record = {'tai64n' => TAI64N_TIME}
    d.instance.filter_record('test', Time.now, record)

    assert_equal record['tai64n'], TAI64N_TIME
    assert_equal record['parsed_time'], '2014-02-10 17:32:25.612979500'
  end

  def test_emit
    d = create_driver(%[
      key            tai64n
      output_key     parsed_time
      add_tag_prefix parsed.
    ])

    d.run { d.emit('tai64n' => TAI64N_TIME) }
    emits = d.emits

    assert_equal 1, emits.count
    assert_equal 'parsed.test', emits[0][0]
    assert_equal TAI64N_TIME, emits[0][2]['tai64n']
  end

  def test_emit_multi
    d = create_driver(%[
      key            tai64n
      output_key     parsed_time
      add_tag_prefix parsed.
    ])

    d.run do
      d.emit('tai64n' => TAI64N_TIME)
      d.emit('tai64n' => TAI64N_TIME)
      d.emit('tai64n' => TAI64N_TIME)
    end
    emits = d.emits

    assert_equal 3, emits.count
    0.upto(2) do |i|
      assert_equal 'parsed.test', emits[i][0]
      assert_equal TAI64N_TIME, emits[i][2]['tai64n']
    end
  end

end
