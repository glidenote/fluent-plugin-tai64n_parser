require_relative 'tai64n_parser_mixin'

module Fluent
  class Tai64nParserOutput < Output
    include Fluent::HandleTagNameMixin
    include Fluent::Tai64nParserMixin
    Fluent::Plugin.register_output('tai64n_parser', self)

    # Define `log` method for v0.10.42 or earlier
    unless method_defined?(:log)
      define_method("log") { $log }
    end

    # Define `router` method of v0.12 to support v0.10 or earlier
    unless method_defined?(:router)
      define_method("router") { Fluent::Engine }
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
        router.emit(t, time, record)
      }
      chain.next
    end

    def filter_record(tag, time, record)
      begin
        record[output_key] = try_replace_tai64n(record[key])
      rescue => e
        log.warn("out_tai64n_parser: #{e.class} #{e.message}")
        log.warn_backtrace
      end
      super(tag, time, record) # HandleTagNameMixin
    end

  end
end
