# Array/to_csv_header_row.rb
# Array#to_csv_header_row

# 20140412, 13, 19
# 0.0.0

require 'Array/to_csv_row'

class Array

  def to_csv_header_row(quote = :double)
    to_csv_row(quote)
  end

end
