require 'rbnacl'
require 'sqrl/base64'

module SQRL
  class QueryParser
    def initialize(params)
      if (params.respond_to?(:split))
        @params = Hash[params.split('&').map {|s| s.split('=')}]
      else
        @params = params
      end
      if @params.any? && !@params.keys.first.kind_of?(String)
        raise ArgumentError, "#{self.class.name} uses string keys for params"
      end
    end

    attr_reader :params
    attr_accessor :login_ip # convenience data holder

    def commands
      (client_data['cmd'] || '').split('~')
    end

    def message
      params['client']+params['server']
    end

    def valid?
      return false unless client_data['idk']
      RbNaCl::VerifyKey.new(idk).verify(ids, message)
    # rbnacl raises in a slight breeze
    rescue StandardError => e
      p e
      false
    end

    def unlocked?(vuk)
      return false unless vuk && params['urs']
      vuk.valid?(urs, message)
    end

    def server_string
      decode(params['server'])
    end

    def client_string
      decode(params['client'])
    end

    def client_data
      Hash[client_string.split("\r\n").map {|s| s.split('=')}]
    end

    def idk
      decode(client_data['idk']).b
    end

    def ids
      decode(params['ids']).b
    end

    def pidk
      decode(client_data['pidk']).b
    end

    def pids
      decode(params['pids']).b
    end

    def suk
      decode(client_data['suk']).b if client_data['suk']
    end

    def vuk
      decode(client_data['vuk']).b if client_data['vuk']
    end

    def urs
      decode(params['urs']).b
    end

    private
    def decode(s)
      Base64.decode(s)
    end
  end
end
