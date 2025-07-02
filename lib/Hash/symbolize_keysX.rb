# Hash/symbolize_keysX.rb
# Hash#symbolize_keys

# 20200106
# 0.0.0

class Hash

  def symbolize_keys!
    self.keys.each do |key|
      self[key.to_sym] = delete(key)
    end
    self
  end

end
