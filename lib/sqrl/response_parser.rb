require 'sqrl/base64'
require 'sqrl/key/site'
require 'sqrl/url'
require 'sqrl/tif'
require 'sqrl/ask'

module SQRL
  class ResponseParser
    def initialize(params)
      @server_string = params
      @tif_base = 16

      begin
        @params = parse_params(decode(params))
      rescue
        heuristic_parse(params)
      end
    end

    def heuristic_parse(params)
      warn "response not canoncial, tyring hueristics"
      p params
      if (params.respond_to?(:split))
        if params.count("\r") > params.count("&")
          @params = parse_params(params)
        else
          @params = parse_form(params)
        end
      else
        @params = params

        if @params.any? && !@params.keys.first.kind_of?(String)
          raise ArgumentError, "#{self.class.name} uses string keys for params"
        end
      end

      if @params['server']
        @params = parse_params(decode(@params['server']))
      end
    end

    def update_session(session)
      session.server_string = server_string
      session.update_post_path(params['qry']) if params['qry']
      self
    end

    attr_reader :params
    attr_reader :server_string
    attr_accessor :tif_base

    def server_friendly_name
      params['sfn'] || 'unspecified'
    end

    def tif
      (params['tif'] || '').to_i(@tif_base)
    end

    TIF.each do |bit,prop|
      define_method(prop.to_s+'?') do
        tif & bit != 0
      end
    end

    def suk?
      !!params['suk']
    end

    def suk
      decode(params['suk']).b
    end

    def url?
      !!params['url']
    end

    def url
      params['url']
    end

    def sin?
      !!params['sin']
    end

    def sin
      decode(params['sin'])
    end

    def ask?
      !!params['ask']
    end

    def ask
      if params['ask']
        Ask.parse(params['ask'])
      else
        Ask.new('')
      end
    end

    private

    def decode(s)
      Base64.decode(s)
    end

    def parse_form(f)
      Hash[f.split("&").map {|s|
        m = s.match(/([^=]+)=(.*)/)
        [m[1], m[2]]
      }]
    rescue ArgumentError => e
      {'error' => e, 'tif' => 0x40.to_s(tif_base)}
    end

    def parse_params(p)
      Hash[p.split("\r\n").map {|s|
        m = s.match(/([^=]+)=(.*)/)
        [m[1], m[2]]
      }]
    rescue ArgumentError => e
      {'error' => e, 'tif' => 0x40.to_s(tif_base)}
    end
  end
end
