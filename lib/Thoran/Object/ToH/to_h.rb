# Thoran/Object/ToH/to_h.rb
# Thoran::Object::ToH#to_h

# 20160202
# 0.3.2

# Description: Turn any Ruby object into a hash, based on instance variables.

# Changes:
# 1. Switched from using refinements to including in the ancestor chain.
# 0/1
# 2. + key_type argument.
# 1/2
# 3. /inject/each_with_object/.  It is soooo annoying that I also have to swap the block arguments around: /|h, instance_variable|/|instance_variable, h|/ as well.

module Thoran
  module Object
    module ToH

      def to_h(key_type = :symbol)
        instance_variables.each_with_object({}) do |instance_variable, h|
          key = instance_variable.to_s.sub(/^@/, '')
          key = key.to_sym if key_type == :symbol
          h[key] = instance_variable_get(instance_variable)
        end
      end

    end
  end
end

Object.send(:include, Thoran::Object::ToH)

if $PROGRAM_NAME == __FILE__
  class A
    def initialize
      @a = 1
      @b = 2
      @c = 3
    end
  end

  a = A.new
  print(a.to_h == {a: 1, b: 2, c: 3} ? '.' : 'x')
  print(a.to_h(:symbol) == {a: 1, b: 2, c: 3} ? '.' : 'x')
  print(a.to_h(:string) == {'a' => 1, 'b' => 2, 'c' => 3} ? '.' : 'x')
  puts
end
