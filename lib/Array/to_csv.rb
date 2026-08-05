# Array/to_csv.rb
# Array#to_csv

# 20140331, 0402, 0404, 0405, 0419
# 0.9.0

# Description: Turn an array into a CSV string for single or for multiple rows.

# Discussion:
# 1. One of the downsides of handling either rows or whole CSV files with the one method is that I have to be explicit with determining what objects I will handle and this makes for the continual need to update this, at present anyway.

# Changes since 0.8:
# 1. - require 'Array/to_csv_row'.
# 2. - require 'Hash/to_csv_row'.
# 3. + require '_meta/to_csv_row'.
# 3. + require '_meta/to_csv_header_row'.

require '_meta/to_csv_header_row'
require '_meta/to_csv_row'
require 'Object/is_one_ofQ'

class Array

  def to_csv(quote = :double)
    if first.is_one_of?(Array, Hash, OpenStruct, Struct) || first.instance_variables.any?
      header = first.to_csv_header_row(quote) + "\n"
      body = self.collect{|item| item.to_csv_row(quote) + "\n"}.join
      header + body
    else
      to_csv_row(quote) + "\n"
    end
  end

end

if __FILE__ == $0
  a = [{a: 1, b: 2}, {a: 3, b: 4}]
  if a.to_csv == "\"a\",\"b\"\n\"1\",\"2\"\n\"3\",\"4\"\n"
    print '.'
  else
    print 'x'
  end

  class A
    attr_accessor :a, :b
    def initialize(a, b)
      @a, @b = a, b
    end
  end

  a = [A.new(1,2), A.new(3,4)]
  if a.to_csv == "\"a\",\"b\"\n\"1\",\"2\"\n\"3\",\"4\"\n"
    print '.'
  else
    print 'x'
  end

  require 'ostruct'
  a = [OpenStruct.new({a: 1, b: 2}), OpenStruct.new({a: 3, b: 4})]
  if a.to_csv == "\"a\",\"b\"\n\"1\",\"2\"\n\"3\",\"4\"\n"
    print '.'
  else
    print 'x'
  end

  a = [[[:a, 1], [:b, 2]], [[:a, 3], [:b, 4]]]
  if a.to_csv == "\"a\",\"b\"\n\"1\",\"2\"\n\"3\",\"4\"\n"
    print '.'
  else
    print 'x'
  end

  B = Struct.new(:a, :b)

  a = [B.new(1, 2), B.new(3, 4)]
  if a.to_csv == "\"a\",\"b\"\n\"1\",\"2\"\n\"3\",\"4\"\n"
    print '.'
  else
    print 'x'
  end


  a = [1, 2, 3, 4]
  if a.to_csv == "\"1\",\"2\",\"3\",\"4\"\n"
    print '.'
  else
    print 'x'
  end

  puts
end
