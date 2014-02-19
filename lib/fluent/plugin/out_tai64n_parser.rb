module Fluent
  class Tai64nParserOutput < Output
    include Fluent::HandleTagNameMixin
    Fluent::Plugin.register_output('tai64n_parser', self)

    # Define `log` method for v0.10.42 or earlier
    unless method_defined?(:log)
      define_method("log") { $log }
    end

    config_param :key, :string, :default => 'tai64n'
    config_param :output_key, :string, :default => nil

    def configure(conf)
      super
      if (
          !remove_tag_prefix &&
          !remove_tag_suffix &&
          !add_tag_prefix    &&
          !add_tag_suffix
      )
        raise ConfigError, "out_tai64n_parser: At least one of remove_tag_prefix/remove_tag_suffix/add_tag_prefix/add_tag_suffix is required to be set."
      end
      @output_key ||= @key
    end

    def start
      super
    end

    def shutdown
      super
    end

    def emit(tag, es, chain)
      es.each {|time,record|
        t = tag.dup
        filter_record(t, time, record)
        Engine.emit(t, time, record)
      }
      chain.next
    end

    def filter_record(tag, time, record)
      begin
        record[output_key] = replace_tai64n(record[key])
      rescue ArgumentError => error
        log.warn("out_tai64n_parser: #{error.class} #{error.message} #{error.backtrace.first}")
      end
      super(tag, time, record)
    end

    def replace_tai64n(str)
      tai64n, rest = str[0,25], str[25..-1]
      parsed = parse_tai64n(tai64n)
      parsed ? "#{parsed}#{rest}" : str
    end

    def parse_tai64n(tai64n)
      # @4000000052f88ea32489532c
      # 0123456789012345678901234
      # 0         1         2
      #   |-------------||------|
      return nil unless tai64n[0,2] == '@4'
      ts = tai64n[2,15].hex
      tf = tai64n[17,8].hex
      t = Time.at(ts-10,tf/1000.0)
      t.strftime("%Y-%m-%d %X.%9N")
    end
  end
end
