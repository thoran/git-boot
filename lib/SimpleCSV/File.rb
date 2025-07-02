# SimpleCSV/File.rb
# SimpleCSV::File

require_relative File.join('..', 'SimpleCSV')

class SimpleCSV
  class File < SimpleCSV

    class << self

      def open(source, *args, &block)
        @csv_file = new(source, *args)
        super(source, *args, &block)
      end

    end # class << self

    def initialize(filename, *args)
      @filename = filename
      @args = args
      super(source, *args)
    end

    def source
      @source ||= ::File.new(filename, mode, permissions)
    end

    def mode
      @mode ||= (
        case @args.peek_options[:mode].to_s
        when 'r', 'r+', 'w', 'w+', 'a', 'a+'; @args.peek_options[:mode].to_s
        when 'read_only', 'read-only', 'readonly'; 'r'
        when 'rw', 'read_write', 'read-write', 'readwrite'; 'r+'
        when 'write_only', 'write-only', 'writeonly'; 'w'
        when 'append'; 'a'
        else 'r'
        end
      )
    end

    def permissions
      @permissions ||= @args.peek_options[:permissions]
    end

    def filename
      @filename ||= File.expand_path(@filename)
    end

  end
end
