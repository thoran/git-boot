# Hash/to_csv_row.rb
# Hash#to_csv_row

# 20140330
# 0.1.0

# Description: Given a Hash, take the values and return those as a CSV string.

# Changes:
# 1. /to_csv/to_csv_row/, for the reason that it makes clear that no keys are being used in order to form a header row.  This is complementary with the change to Array#to_csv becoming #to_csv_row.

require 'Array/to_csv_row'

class Hash

  def to_csv_row(quote = :double)
    values.to_csv_row(quote)
  end

end
