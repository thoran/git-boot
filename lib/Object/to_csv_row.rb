# Object/to_csv_row.rb
# Object#to_csv_row

# 20140419
# 0.1.0

# Description: Turn any Ruby object into a csv row, based on instance variables.

# Discussion:
# 1. Having noted that there was a _meta/to_h, and that there was recently created an Array#to_h and a Hash#to_h, I decided to create a _meta/to_csv_row and this is one part of that effort.
# 2. I could probably make do with only this method, since both OpenStruct and Struct will have basically the same form.  I'll look at that later, but for now I'll create class-specific methods.

# Changes:
# 1. - require 'Array/to_csv_row'.
# 2. + require 'Hash/to_csv_row'.
# 3. ~ Object#to_csv_row make use of Hash#to_csv_row, which in turn uses Array#to_csv_row anyway.

require 'Hash/to_csv_row'
require 'Object/to_h'

class Object

  def to_csv_row(quote = :double)
    to_h.to_csv_row(quote)
  end

end
