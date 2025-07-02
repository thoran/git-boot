# Pd/KeyFile.rb
# Pd::KeyFile

require 'Pd/ConfigFile'

module Pd
  class KeyFile
    class << self

      DEFAULT_KEY_FILENAME = '~/.config/pdsh/key.txt'

      def volume_names
        `ls /Volumes`.split("\n")
      end

      def removable_volume_key(volume_name, removable_volume_key_path)
        "/Volumes/#{volume_name}/#{removable_volume_key_path}"
      end

      def boot_volume_key_path
        File.expand_path(DEFAULT_KEY_FILENAME)
      end

      def configured_key_location
        if ConfigFile.config
          ConfigFile.config['key_file']
        end
      end

      def removable_volume_key_location
        if ConfigFile.config
          volume_names.each do |volume_name|
            ConfigFile.config['removable_volume_key_paths'].each do |removable_volume_key_path|
              if File.exist?(removable_volume_key(volume_name, removable_volume_key_path))
                return removable_volume_key(volume_name, removable_volume_key_path)
              end
            end
          end
        end
        nil
      end

      def default_key_location
        boot_volume_key_path
      end

      def key_location
        configured_key_location || removable_volume_key_location || default_key_location
      end

      def key_missing_message
        "A key file cannot be found."
      end

      def key
        if File.exist?(key_location)
          File.read(key_location)
        else
          raise RuntimeError, key_missing_message
        end
      end

    end # class << self
  end
end
