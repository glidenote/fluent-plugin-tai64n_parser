module Fluent
  module Plugin
    module Tai64nParser
      def replace_tai64n(str)
        tai64n, rest = str[0,25], str[25..-1]
        parsed = parse_tai64n(tai64n)
        if parsed
          "#{parsed}#{rest}"
        else
          log.info("tai64n_parser: record['#{key}']='#{str}' does not start with valid tai64n")
          str
        end
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
end
