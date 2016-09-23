require_relative 'tai64n_parser_mixin'

module Fluent
  class Tai64nParserFilter < Filter
    include Fluent::Tai64nParserMixin
    Fluent::Plugin.register_filter('tai64n_parser', self)

    config_param :key, :string, :default => 'tai64n'
    config_param :output_key, :string, :default => nil

    def configure(conf)
      super
      @output_key ||= @key
    end

    def start
      super
    end

    def shutdown
      super
    end

    def filter(tag, time, record)
      begin
        record[output_key] = try_replace_tai64n(record[key])
      rescue => e
        log.warn("filter_tai64n_parser: #{e.class} #{e.message}")
        log.warn_backtrace
      end
      record
    end

  end
end if defined?(Fluent::Filter) # Support only >= v0.12
