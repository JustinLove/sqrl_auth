require 'sqrl/key/site'
require 'sqrl/url'

module SQRL
  class ClientSession
    def initialize(path, imk)
      @server_string = path
      url = URL.parse(path)
      @post_path = url.post_path
      @site_key = Key::Site.new(imk, url.signing_host)
    end

    attr_accessor :server_string
    attr_accessor :post_path
    attr_reader :site_key
  end
end
