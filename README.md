# fluent-plugin-tai64n_parser

[![Build Status](https://travis-ci.org/glidenote/fluent-plugin-tai64n_parser.png?branch=master)](https://travis-ci.org/glidenote/fluent-plugin-tai64n_parser)

Fluentd plugin to parse [TAI64N format](http://cr.yp.to/libtai/tai64.html#tai64n).

## Installation

Use RubyGems:

```
gem install fluent-plugin-tai64n_parser
```

## Configuration

Exampe:

```
<match test.**>
  type             tai64n_parser

  key              tai64n
  parsed_time_tag  parsed_time
  add_tag_prefix   parsed.
</match>
```

Assume following input is coming (indented):

``` js
"test" => {
  "tai64n"      => "@4000000052f88ea32489532c"
}
```

then output becomes as below (indented):

``` js
"parsed.test" => {
  "tai64n"      => "@4000000052f88ea32489532c"
  "parsed_time" => "2014-02-10 17:32:25.612979500",
}
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

### Copyright

Copyright (c) 2014- Akira Maeda. See [LICENSE](LICENSE) for details.
