# Pd/ConfigFile.rb
# Pd::ConfigFile

require 'json'

module Pd
  class ConfigFile
    class << self

      CONFIGURATION_FILENAME = '~/.config/pdsh/config.json'

      def config_file_location
        File.expand_path(CONFIGURATION_FILENAME)
      end

      def config
        @config ||= (
          if File.exist?(config_file_location)
            JSON.parse(File.read(config_file_location))
          end
        )
      end

    end # class << self
  end
end
