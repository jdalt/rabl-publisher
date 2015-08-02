module Publisher
  module Util
    def super_klasses(klass)
      super_klasses = []
      super_klass = klass
      while(super_klass != Object)
        super_klasses << super_klass
        super_klass = super_klass.superclass
      end
      super_klasses
    end

    def self_and_descandants(klass)
      descandants = ObjectSpace.each_object(Class).select { |child| child < klass }
      [klass] + descandants
    end
  end
end
