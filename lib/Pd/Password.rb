# Pd/Password.rb
# Pd::Password

require 'Hash/symbolize_keysX'
require 'SimpleCSV'

module Pd
  class Password

    @passwords = []

    class << self

      def all
        @passwords
      end

      def <<(password_instance)
        @passwords << password_instance
      end

      def load_from_csv(csv_string)
        SimpleCSV.parse(csv_string, headers: false, columns: [:label, :username, :password]) do |row|
          if row.keys.include?('label') && row.keys.include?('username')
            @passwords << Password.new(**row.symbolize_keys!)
          else
            puts "#{row} is malformed"
          end
        end
        @passwords
      end
      alias_method :from_csv, :load_from_csv

      def reload_from_csv(csv_string)
        SimpleCSV.parse(csv_string, headers: false, columns: [:label, :username, :password]) do |row|
          if row.keys.include?('label') && row.keys.include?('username')
            unless matching_entry?(label: label)
              @passwords << Password.new(**row.symbolize_keys!)
            end
          else
            puts "#{row} is malformed"
          end
        end
        @passwords
      end

      def matching_entry?(label:)
        @passwords.detect{|p| p.label == label}
      end

      def to_csv
        @passwords.collect do |password|
          password.to_csv
        end.join("\n")
      end

      def find(search_term)
        @passwords.select do |password|
          password.label =~ /#{search_term.downcase}/i
        end
      end

      def size
        @passwords.size
      end

      def delete(entry)
        @passwords.reject!{|password| password.label == entry}
      end

      def to_s
        @passwords.sort_by{|password| password.label}.collect{|password| password.to_s}.join("\n")
      end

    end # class << self

    attr_reader :label, :username, :password

    def initialize(label:, username:, password: nil)
      @label = label
      @username = username
      @password = password
    end

    def to_csv
      [@label, @username, @password].join(',')
    end

    def to_s
      "#{@label} #{@username} : #{@password}"
    end

    def to_h
      {label: @label, username: @username, password: @password}
    end

  end
end
