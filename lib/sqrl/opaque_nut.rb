module SQRL
  class OpaqueNut
    def initialize
      @to_s = SecureRandom.urlsafe_base64(20, false)
    end

    attr_reader :to_s

    alias_method :to_string, :to_s
  end
end
