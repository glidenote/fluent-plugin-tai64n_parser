require_relative '../test_helper'
require 'fluent/plugin/tai64n_parser'

class Tai64nParserTest < Test::Unit::TestCase

  class Tai64nParser
    include Fluent::Plugin::Tai64nParser

    def log
      @log ||= Logger.new(logdev)
    end

    def logdev
      @logdev ||= StringIO.new
    end

    def key
      'foo'
    end
  end

  def parser
    @parser ||= Tai64nParser.new
  end

  def test_try_replace_tai64n
    good_tai64n = "@4000000052f88ea32489532c"
    expected_time = "2014-02-10 17:32:25.612979500"
    assert_equal expected_time, parser.try_replace_tai64n(good_tai64n)
    assert_equal "#{expected_time} foo", parser.try_replace_tai64n("#{good_tai64n} foo")

    bad_tai64n = "4000000052f88ea32489"
    assert_equal bad_tai64n, parser.try_replace_tai64n(bad_tai64n)
    assert_true parser.logdev.tap {|d| d.rewind }.read.include?('does not start with valid tai64n')
  end

end
