# OpenStruct/to_csv_header_row.rb
# OpenStruct#to_csv_header_row

# 20140419
# 0.1.0

require 'Hash/to_csv_header_row'

class OpenStruct

  def to_csv_header_row(quote = :double)
    to_h.to_csv_header_row(quote)
  end

end
