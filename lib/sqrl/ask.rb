require 'sqrl/base64'

module SQRL
  class Ask
    def initialize(message)
      @message = message
      @buttons = []
    end

    def self.parse(s)
      parts = s.split('~').map {|part| Base64.decode(part)}
      message = parts.shift
      ask = new(message)
      ask.buttons = parts
      ask
    end

    attr_accessor :message
    attr_accessor :buttons

    def to_s
      parts = [message] + buttons
      parts.map {|part| Base64.encode(part)}.join('~')
    end
  end
end
