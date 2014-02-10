module Fluent
  class Tai64nParserOutput < Output
    include Fluent::HandleTagNameMixin
    Fluent::Plugin.register_output('tai64n_parser', self)

    config_param :key, :string, :default => 'tai64n'
    config_param :parsed_time_tag, :string, :default => 'parsed_time'

    def configure(conf)
      super
      if (
          !remove_tag_prefix &&
          !remove_tag_suffix &&
          !add_tag_prefix    &&
          !add_tag_suffix
      )
        raise ConfigError, "out_extract_query_params: At least one of remove_tag_prefix/remove_tag_suffix/add_tag_prefix/add_tag_suffix is required to be set."
      end
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
        if record[key] =~ /\@40000000([\da-f]{8})([\da-f]{8})/
          t = Time.at($1.hex-10, $2.hex/1000.0)
          record_time = t.strftime("%Y-%m-%d %X.%9N").to_s
        else
          record_time = nil
        end

        record[parsed_time_tag] = record_time

      rescue ArgumentError => error
        $log.warn("out_extract_query_params: #{error.message}")
      end
      super(tag, time, record)
    end
  end
end
