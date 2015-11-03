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

    def update_post_path(qry)
      return unless qry
      pp = URI(@post_path)
      q = URI(qry)
      pp.path = q.path
      pp.query = q.query
      @post_path = pp.to_s
    end
  end
end
