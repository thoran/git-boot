# Array/to_csv_row.rb
# Array#to_csv_row

# 20160925
# 0.11.1

# Todo:
# 1. Measure speed differences and reintroduce String#wrap and friends if negligible.

# Changes since 0.10:
# 1. - require '_meta/default_to', and instead have a default for nil in the case expression.

class Array

  def to_csv_row(quote = :double)
    case quote&.to_sym
    when :double
      self.collect{|e| '"' + e.to_s + '"'}.join(',')
    when :spacey_double
      self.collect{|e| '"' + e.to_s + '"'}.join(', ')
    when :single
      self.collect{|e| "'" + e.to_s + "'"}.join(',')
    when :spacey_single
      self.collect{|e| "'" + e.to_s + "'"}.join(', ')
    when :none, :unquoted
      self.join(',')
    when :spacey_none, :spacey_unquoted
      self.join(', ')
    else # default is :double
      self.collect{|e| '"' + e.to_s + '"'}.join(',')
    end
  end

end
