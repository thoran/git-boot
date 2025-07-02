# Pd/PasswordFile.rb
# Pd::PasswordFile

require 'Pd/KeyFile'
require 'sym'

module Pd
  class PasswordFile

    DEFAULT_ENCRYPTED_FILENAME = '~/.pd'

    class << self

      include Sym

      def read
        decr(File.read(encrypted_filename), KeyFile.key)
      rescue RuntimeError => e
        puts e
        exit
      end

      def write(passwords)
        File.write(encrypted_filename, encr(passwords, KeyFile.key))
      rescue RuntimeError => e
        puts e
        exit
      end

      def encrypted_filename
        File.expand_path(DEFAULT_ENCRYPTED_FILENAME)
      end

    end # class << self

  end
end
