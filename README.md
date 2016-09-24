# fluent-plugin-tai64n_parser

[![Build Status](https://travis-ci.org/glidenote/fluent-plugin-tai64n_parser.png?branch=master)](https://travis-ci.org/glidenote/fluent-plugin-tai64n_parser)

Fluentd plugin to parse [TAI64N format](http://cr.yp.to/libtai/tai64.html#tai64n).

## Installation

Use RubyGems:

```
gem install fluent-plugin-tai64n_parser
```

## Configuration

### Filter Plugin

```
<filter test.**>
  @type tai64n_parser
  key   message
</match>
```

Assume following input is coming (indented):

``` js
"test" => {
  "message" => "@4000000052f88ea32489532c [FATAL] blah blah"
}
```

then output becomes as below (indented):

``` js
"test" => {
  "message" => "2014-02-10 17:32:25.612979500 [FATAL] blah blah"
}
```

### Output Plugin (Old Style)

```
<match test.**>
  @type           tai64n_parser
  
  key             message
  add_tag_prefix  parsed.
</match>
```

Assume following input is coming (indented):

``` js
"test" => {
  "message" => "@4000000052f88ea32489532c [FATAL] blah blah"
}
```

then output becomes as below (indented):

``` js
"parsed.test" => {
  "message" => "2014-02-10 17:32:25.612979500 [FATAL] blah blah"
}
```

### Parse qmail log example:

```
<match raw.qmail.sent>
  type             parser
  remove_prefix    raw
  format           /^(?<tai64n>[^ ]+) (?<message>(((?:new|end) msg (?<key>[0-9]+)|info msg (?<key>[0-9]+): bytes (?:\d+) from <(?<address>[^>]*)> |starting delivery (?<delivery_id>[0-9]+): msg (?<key>[0-9]+) to (?:local|remote) (?<address>.+)|delivery (?<delivery_id>[0-9]+))?.*))$/
  key_name         message
  suppress_parse_error_log true
</match>

<match qmail.sent>
  type             tai64n_parser

  key              tai64n
  output_key       parsed_time
  add_tag_prefix   parsed.
</match>

<match parsed.qmail.sent>
  type file
  path /var/log/td-agent/qmail_tai64n_parsed.log
</match>
```

Assume following input is coming:

```
@4000000052fafd8d3298434c new msg 3890
@4000000052fafd8d32984b1c info msg 3890: bytes 372 from <root@**********.pb> qp 31835 uid 0
@4000000052fafd8d373b5dbc starting delivery 9: msg 3890 to remote glidenote@********.co.jp
@4000000052fafd8d373b6974 status: local 0/120 remote 1/60
@4000000052fafd8d38754cec delivery 9: success: ***.***.***.***_accepted_message./Remote_host_said:_250_ok_1392180611_qp_10394/
@4000000052fafd8d387554bc status: local 0/120 remote 0/60
@4000000052fafd8d387554bc end msg 3890
```

then output becomes as below:

```
2014-02-12T13:50:11+09:00       parsed.qmail.sent       {"tai64n":"@4000000052fafd8d3298434c","message":"new msg 3890","key":"3890","parsed_time":"2014-02-12 13:50:11.848839500"}
2014-02-12T13:50:11+09:00       parsed.qmail.sent       {"tai64n":"@4000000052fafd8d32984b1c","message":"info msg 3890: bytes 372 from <root@**********.pb> qp 31835 uid 0","key":"3890","address":"root@**********.pb","parsed_time":"2014-02-12 13:50:11.848841500"}
2014-02-12T13:50:11+09:00       parsed.qmail.sent       {"tai64n":"@4000000052fafd8d373b5dbc","message":"starting delivery 9: msg 3890 to remote glidenote@**********.co.jp","key":"3890","address":"glidenote@**********.co.jp","delivery_id":"9","parsed_time":"2014-02-12 13:50:11.926637500"}
2014-02-12T13:50:11+09:00       parsed.qmail.sent       {"tai64n":"@4000000052fafd8d373b6974","message":"status: local 0/120 remote 1/60","parsed_time":"2014-02-12 13:50:11.926640500"}
2014-02-12T13:50:11+09:00       parsed.qmail.sent       {"tai64n":"@4000000052fafd8d38754cec","message":"delivery 9: success: ***.***.***.***_accepted_message./Remote_host_said:_250_ok_1392180611_qp_10394/","
delivery_id":"9","parsed_time":"2014-02-12 13:50:11.947211500"}
2014-02-12T13:50:11+09:00       parsed.qmail.sent       {"tai64n":"@4000000052fafd8d387554bc","message":"status: local 0/120 remote 0/60","parsed_time":"2014-02-12 13:50:11.947213500"}
2014-02-12T13:50:11+09:00       parsed.qmail.sent       {"tai64n":"@4000000052fafd8d387554bc","message":"end msg 3890","key":"3890","parsed_time":"2014-02-12 13:50:11.947213500"}
```

## Parameters

### Filter Plugin

- key *field\_key*

    The target field key to parse tai64n. The first 25 characters are tried to parse.
    If the characters are of tail64n format, convert to the time format as of `tai64nlocal` command.
    If the characters are not of tai64n format, just pass through the input with info level messages on the log.

- output\_key *field\_key*

    The target field to output the parsed result. The default is equivalent with `key` which means to overwrite the `key` field. 

### Output Plugin (Old Style)

- key *field\_key*

    The target field key to parse tai64n. The first 25 characters are tried to parse.
    If the characters are of tail64n format, convert to the time format as of `tai64nlocal` command.
    If the characters are not of tai64n format, just pass through the input with info level messages on the log.

- output\_key *field\_key*

    The target field to output the parsed result. The default is equivalent with `key` which means to overwrite the `key` field. 

- add_tag_prefix

    Add tag prefix for output message

- remove_tag_prefix

    Remove tag prefix for output message

- add_tag_suffix

    Add tag suffix for output message

- remove_tag_suffix

    Remove tag suffix for output message

## ChangeLog

[CHANGELOG.md](./CHANGELOG.md)

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

### Copyright

Copyright (c) 2014- Akira Maeda. See [LICENSE](LICENSE) for details.
