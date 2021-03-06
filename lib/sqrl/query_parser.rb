require 'rbnacl'
require 'sqrl/base64'

module SQRL
  class QueryParser
    def initialize(_params)
      if (_params.respond_to?(:split))
        pairs = _params.split('&').map {|s| s.split('=')}
        if pairs.any? {|pair| pair.length != 2}
          raise ArgumentError, "#{self.class.name} requires urlsafe base64, but some argument does not appear be in key=urlsafe_base64 form"
        end
        @params = Hash[pairs]
      else
        @params = _params
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

    def options
      (client_data['opt'] || '').split('~')
    end

    def opt?(option)
      options.include?(option)
    end

    def message
      params['client']+params['server']
    end

    def valid?(vuk = nil)
      ids_valid? && pids_valid? && urs_valid?(vuk)
    end

    def ids_valid?
      return false unless client_data['idk']
      RbNaCl::VerifyKey.new(idk).verify(ids, message)
    # rbnacl raises in a slight breeze
    rescue StandardError => e
      p e
      false
    end

    def pids_valid?
      return true unless client_data['pidk']
      RbNaCl::VerifyKey.new(pidk).verify(pids, message)
    # rbnacl raises in a slight breeze
    rescue StandardError => e
      p e
      false
    end

    def urs_valid?(vuk)
      return true unless vuk && params['urs']
      vuk.valid?(urs, message)
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
      Hash[client_string.split("\r\n").reject{|s| s.empty?}.map {|s| s.split('=')}]
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

    def ins
      decode(client_data['ins'])
    end

    def pins
      decode(client_data['ins'])
    end

    private
    def decode(s)
      Base64.decode(s)
    end
  end
end
