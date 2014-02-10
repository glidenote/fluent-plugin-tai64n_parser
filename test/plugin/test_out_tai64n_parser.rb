# -*- encoding: utf-8 -*-
require 'test_helper'
require 'time'

class Tai64nParserOutputTest < Test::Unit::TestCase

  TAI64N_TIME = "@4000000052f88ea32489532c"
  BAD_TAI64N_TIME = "4000000052f88ea32489"

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
      add_tag_prefix extracted.
    ])
    assert_equal 'test', d.instance.key
    assert_equal 'extracted.', d.instance.add_tag_prefix

    #Default Key
    d = create_driver(%[
      add_tag_prefix extracted.
    ])
    assert_equal 'tai64n', d.instance.key
    assert_equal 'extracted.', d.instance.add_tag_prefix
  end

  def test_filter_record
    d = create_driver(%[
      key            tai64n
      add_tag_prefix extracted.
    ])
    tag    = 'test'
    record = {'tai64n' => TAI64N_TIME}
    d.instance.filter_record('test', Time.now, record)

    assert_equal record['tai64n'], TAI64N_TIME
    assert_equal record['parsed_time'], '2014-02-10 17:32:25.612979500'
  end

  def test_filter_record_bad_parameters
    d = create_driver(%[
      key            time
      add_tag_prefix extracted.
    ])
    tag    = 'test'
    record = {'time' => BAD_TAI64N_TIME}

    d.instance.filter_record('test', Time.now, record)
    assert_equal record['parsed_time'], nil

    record = {'time' => "this is not a date"}
    d.instance.filter_record('test', Time.now, record)
    assert_equal record['parsed_time'], nil
  end

  def test_emit
    d = create_driver(%[
      key            tai64n
      add_tag_prefix extracted.
    ])

    d.run { d.emit('tai64n' => TAI64N_TIME) }
    emits = d.emits

    assert_equal 1, emits.count
    assert_equal 'extracted.test', emits[0][0]
    assert_equal TAI64N_TIME, emits[0][2]['tai64n']
  end

  def test_emit_multi
    d = create_driver(%[
      key            tai64n
      add_tag_prefix extracted.
    ])

    d.run do
      d.emit('tai64n' => TAI64N_TIME)
      d.emit('tai64n' => TAI64N_TIME)
      d.emit('tai64n' => TAI64N_TIME)
    end
    emits = d.emits

    assert_equal 3, emits.count
    0.upto(2) do |i|
      assert_equal 'extracted.test', emits[i][0]
      assert_equal TAI64N_TIME, emits[i][2]['tai64n']
    end
  end

  def test_emit_with_invalid_tai64n
    d = create_driver(%[
      key            tai64n
      add_tag_prefix extracted.
    ])
    wrong_time = 'wrong time'
    d.run { d.emit('tai64n' => wrong_time) }
    emits = d.emits

    assert_equal 1, emits.count
    assert_equal 'extracted.test', emits[0][0]
    assert_equal wrong_time, emits[0][2]['tai64n']
  end

end
