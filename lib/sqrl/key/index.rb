require 'rbnacl'

module SQRL
  class Key
    class Index < Key
      def signature(message)
        RbNaCl::SigningKey.new(@bytes).sign(message)
      end
    end
  end
end
