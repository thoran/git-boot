# Object/is_one_ofQ.rb
# Object#is_one_of?

# 20140330
# 0.0.0

# Description: Tests for whether an object is a member of one of a number of classes.

# Discussion: 
# 1. Should I overload is_a?().

# History: 
# 1. Taken from Array#to_csv 0.6.2, then reintroduced in 0.7 require-ing this.

class Object

	def is_one_of?(*klasses)
    klasses.flatten.inject(false){|member, klass| member || self.is_a?(klass)}
  end

end

if __FILE__ == $0
  o = [1, 2, 3, 4]

  if o.is_one_of?(Array, Hash)
    print '.'
  else
    print 'x'
  end

  if !o.is_one_of?(Hash)
    print '.'
  else
    print 'x'
  end

  o = {a: 1, b: 2}

  if o.is_one_of?(Array, Hash)
    print '.'
  else
    print 'x'
  end

  if !o.is_one_of?(Array)
    print '.'
  else
    print 'x'
  end

  puts
end
