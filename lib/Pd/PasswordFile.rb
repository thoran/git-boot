# Pd/PasswordFile.rb
# Pd::PasswordFile

module Pd
  class PasswordFile
    DEFAULT_CRYPT_LOCATION = '~/.pd'

    class << self
      def read
        File.read(crypt_location)
      end

      def write(encrypted_passwords)
        File.write(crypt_location, encrypted_passwords)
      end

      def crypt_location
        File.expand_path(DEFAULT_CRYPT_LOCATION)
      end
      alias_method :encrypted_filename, :crypt_location

      def crypt_missing_message
        "An encrypted password file cannot be found."
      end
    end # class << self
  end
end
