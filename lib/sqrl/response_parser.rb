require 'sqrl/base64'
require 'sqrl/key/site'
require 'sqrl/url'
require 'sqrl/tif'
require 'sqrl/ask'

module SQRL
  class ResponseParser
    def initialize(session, params)
      @session = session
      @tif_base = 16

      begin
        @params = parse_params(decode(params))
      rescue
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
    end

    attr_reader :params
    attr_reader :session
    attr_accessor :tif_base

    def post_path
      session.post_path
    end

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

    def parse_form(s)
      Hash[s.split("&").map {|s|
        m = s.match(/([^=]+)=(.*)/)
        [m[1], m[2]]
      }]
    rescue ArgumentError => e
      {'error' => e, 'tif' => 0x40.to_s(tif_base)}
    end

    def parse_params(s)
      Hash[s.split("\r\n").map {|s|
        m = s.match(/([^=]+)=(.*)/)
        [m[1], m[2]]
      }]
    rescue ArgumentError => e
      {'error' => e, 'tif' => 0x40.to_s(tif_base)}
    end
  end
end
