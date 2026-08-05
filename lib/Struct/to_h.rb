# Struct/to_h.rb
# Struct#to_h

# 20140331
# 0.0.0

# Description: Turn a Struct instance into a Hash instance.

# Discussion:
# 1. This is to complement the other to_h() methods, many of which were created in the last few days and were included in _meta/to_h as will this be...

class Struct

  def to_h
    members.inject({}) do |h, member|
      h[member] = self.send(member)
      h
    end
  end

end
