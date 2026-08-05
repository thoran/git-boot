# Pd/EncryptedPasswords.rb
# Pd::EncryptedPasswords

require 'Pd/CleartextPasswords'
require 'Pd/KeyFile'
require 'Pd/PasswordFile'
require 'sym'

module Pd
  class EncryptedPasswords
    class << self
      include Sym

      def read
        self.new(Pd::PasswordFile.read)
      end

      def write(encrypted_passwords)
        Pd::PasswordFile.write(encrypted_passwords.to_s)
      end

      def decrypt(encrypted_passwords_string)
        decr(encrypted_passwords_string, KeyFile.key)
      end
    end # class << self

    attr_accessor :encrypted_passwords_string

    def decrypt
      self.class.decrypt(@encrypted_passwords_string)
    end

    def to_cleartext_passwords
      CleartextPasswords.new(decrypt)
    end

    def to_s
      @encrypted_passwords_string
    end

    private

    def initialize(encrypted_passwords_string = nil)
      @encrypted_passwords_string = encrypted_passwords_string
    end
  end
end
