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
  end
end
