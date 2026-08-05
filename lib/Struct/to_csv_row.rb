# Struct/to_csv_row.rb
# Struct#to_csv_row

# 20140419
# 0.1.0

# Description: Turn any Struct object into a csv row.

# Changes:
# 1. - require 'Array/to_csv_row'.
# 2. + require 'Hash/to_csv_row'.
# 3. ~ Struct#to_csv_row make use of Hash#to_csv_row, which in turn uses Array#to_csv_row anyway.

require 'Hash/to_csv_row'
require 'Struct/to_h'

class Struct

  def to_csv_row(quote = :double)
    to_h.to_csv_row(quote)
  end

end
