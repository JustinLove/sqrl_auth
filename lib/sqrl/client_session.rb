require 'sqrl/key/site'
require 'sqrl/url'

module SQRL
  class ClientSession
    def initialize(path, imks)
      @server_string = path
      url = URL.parse(path)
      @post_path = url.post_path
      @site_keys = imks.map {|imk| Key::Site.new(imk, url.signing_host)}
    end

    attr_accessor :server_string
    attr_accessor :post_path
    attr_reader :site_keys

    def site_key
      site_keys[0]
    end

    def previous_site_key
      site_keys[1]
    end

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
