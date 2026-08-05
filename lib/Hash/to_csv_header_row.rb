# Hash/to_csv_header_row.rb
# Hash#to_csv_header_row

# 20140419
# 0.1.0

require 'Array/to_csv_row'

class Hash

  def to_csv_header_row(quote = :double)
    keys.to_csv_row(quote)
  end

end
