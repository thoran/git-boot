# Hash/symbolize_keysX.rb
# Hash#symbolize_keys!

# 20200106
# 0.1.0

class Hash

  def symbolize_keys!
    self.keys.each do |key|
      self[key.to_sym] = delete(key)
    end
    self
  end

end

if __FILE__ == $0
  before = {'a' => 1, 'b' => 2}
  desired_after = {:a => 1, :b => 2}
  after = before.symbolize_keys!
  if after == desired_after
    print '.'
  else
    print 'x'
  end

  puts
end
