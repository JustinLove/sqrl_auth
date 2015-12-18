require 'sqrl/base64'

module SQRL
  class QueryGenerator
    def initialize(session, server_string = session.server_string)
      @session = session
      if server_string.match('://')
        @server_string = encode(server_string)
      else
        @server_string = server_string
      end
      @commands = []
    end

    attr_reader :session
    attr_reader :server_string
    attr_reader :commands
    attr_reader :server_unlock_key
    attr_reader :verify_unlock_key

    def disable!
      @commands << 'disable'
      self
    end

    def enable!
      @commands << 'enable'
      self
    end

    def ident!
      @commands << 'ident'
      self
    end

    def query!
      @commands << 'query'
      self
    end

    def remove!
      @commands << 'remove'
      self
    end

    def setlock(options)
      if !(options[:suk] && options[:vuk])
        raise ArgumentError, ":suk and :vuk are required to setlock"
      end
      @server_unlock_key = encode(options[:suk])
      @verify_unlock_key = encode(options[:vuk])
      self
    end

    def unlock(ursk)
      @ursk = ursk
      self
    end

    def post_path
      @session.post_path
    end

    def post_body
      to_hash.to_a.map{|pair| pair.join('=')}.join('&')
    end

    def to_hash
      client = encode(client_string)
      server = server_string
      base = client + server
      {
        :client => client,
        :server => server,
        :ids => encode(site_key.signature(base)),
        :pids => previous_site_key && encode(previous_site_key.signature(base)),
        :urs => @ursk && encode(@ursk.signature(base)),
      }.reject {|k,v| v.nil? || v == ''}
    end

    def client_string
      client_data.to_a.map{|pair| pair.join('=')}.join("\r\n")
    end

    def client_data
      {
        :ver => 1,
        :cmd => @commands.join('~'),
        :idk => encode(site_key.public_key),
        :pidk => previous_site_key && encode(previous_site_key.public_key),
        :suk => @server_unlock_key,
        :vuk => @verify_unlock_key,
      }.reject {|k,v| v.nil? || v == ''}
    end

    private

    def site_key
      @session.site_key
    end

    def previous_site_key
      @session.previous_site_key
    end

    def encode(string)
      Base64.encode(string)
    end
  end
end
