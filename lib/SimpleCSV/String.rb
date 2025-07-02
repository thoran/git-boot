# SimpleCSV/String.rb
# SimpleCSV::String

require 'stringio'

require_relative File.join('..', 'SimpleCSV')

class SimpleCSV
  class String < SimpleCSV

    class << self

      def open(source, *args, &block)
        @csv_file = new(source, *args)
        super(source, *args, &block)
      end

    end # class << self

    def initialize(string, *args)
      @string = string
      super(source, *args)
    end

    def source
      @source ||= StringIO.new(@string)
    end

  end
end
