require 'sqrl/base64'
require 'uri'
require 'uri/https'
require 'delegate'

module URI
  class SQRL < HTTPS
    def self.scheme
      'sqrl'
    end

    def post_scheme
      'https'
    end
  end
  @@schemes['SQRL'] = SQRL

  class QRL < HTTP
    def self.scheme
      'qrl'
    end

    def post_scheme
      'http'
    end
  end
  @@schemes['QRL'] = QRL
end

module SQRL
  class URL < SimpleDelegator
    def self.parse(url)
      new parser.parse(url)
    end

    def self.parser
      URI::Parser.new(:UNRESERVED => "|\\-_.!~*'()a-zA-Z\\d")
    end

    def self.sqrl(domain_path, options = {})
      create(URI::SQRL, domain_path, options)
    end

    def self.qrl(domain_path, options = {})
      create(URI::QRL, domain_path, options)
    end

    def self.create(kind, domain_path, options = {})
      parts = domain_path.split('/')
      host = parts.first
      parts[0] = ''
      path = parts.join('/')
      query = []
      query << 'nut='+options[:nut] if options[:nut]
      query << 'sfn='+SQRL::Base64.encode(options[:sfn]) if options[:sfn]
      new(kind.new(kind.scheme, nil, host, nil, nil, path, nil, query.join('&'), nil, parser))
    end

    def nut
      query.split('&').find {|n| n.match('nut=')}.gsub('nut=', '')
    end

    def sfn
      SQRL::Base64.decode(query.split('&').find {|n| n.match('sfn=')}.gsub('sfn=', ''))
    end

    def signing_host
      parts = path.split('|')
      if (parts.length > 1)
        host + parts.first
      else
        host
      end
    end

    def post_path
      path = dup
      path.scheme = post_scheme
      path.to_s.sub('|', '/')
    end
  end
end
