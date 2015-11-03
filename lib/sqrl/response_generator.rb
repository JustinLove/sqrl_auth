require 'sqrl/base64'
require 'sqrl/tif'

module SQRL
  class ResponseGenerator
    def initialize(nut, flags, fields)
      @nut = nut
      @flags = flags
      @fields = fields
      @fields[:suk] = encode(@fields[:suk]) if @fields[:suk]
      @tif_base = 16
    end

    attr_accessor :tif_base

    def response_body
      encode(server_string)
    end

    def to_hash
      server_data
    end

    def server_string
      server_data.to_a.map{|pair| pair.join('=')}.join("\r\n")
    end

    def server_data
      {
        :ver => '1',
        :nut => @nut,
        :tif => tif.to_s(tif_base),
      }.merge(@fields).reject {|k,v| v.nil? || v == ''}
    end

    def tif
      TIF.map {|bit, prop| @flags[prop] ? bit : 0}.reduce(0, &:|)
    end

    private

    def encode(string)
      Base64.encode(string)
    end
  end
end
