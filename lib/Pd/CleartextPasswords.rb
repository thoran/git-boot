# Pd/CleartextPasswords.rb
# Pd::CleartextPasswords

require 'Pd/EncryptedPasswords'
require 'Pd/KeyFile'
require 'sym'

module Pd
  class CleartextPasswords
    class << self
      include Sym

      def encrypt(cleartext_passwords_string)
        encr(cleartext_passwords_string, KeyFile.key)
      end
    end # class << self

    attr_accessor :cleartext_passwords_string

    def encrypt
      self.class.encrypt(@cleartext_passwords_string)
    end

    def to_encrypted_passwords
      EncryptedPasswords.new(encrypt)
    end

    def to_s
      @cleartext_passwords_string
    end

    private

    def initialize(cleartext_passwords_string = nil)
      @cleartext_passwords_string = cleartext_passwords_string
    end
  end
end
