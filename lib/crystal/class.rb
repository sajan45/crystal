module Crystal
  class Class
    def initialize(name, superclass = nil, type = nil)
      @name = name
      @superclass = superclass
      @type = type
      @methods = {}
    end

    def type(class_class)
      @type ||= Metaclass.new self, class_class
    end

    def subclass_of?(other)
      self == other || @superclass == other
    end

    def find_method(name)
      method = @methods[name]
      if method
        method.dup
      else
        @superclass ? @superclass.find_method(name) : nil
      end
    end

    def define_method(name, method)
      @methods[name] = method
    end

    def define_static_method(name, method, class_class)
      type(class_class).define_method name, method
    end
  end

  class Metaclass < Class
    def initialize(a_class, class_class)
      @class = a_class
      @class_class = class_class
      @methods = {}
    end

    def find_method(name)
      method = @methods[name]
      if method
        method.dup
      else
        if @class.superclass
          @class.superclass.type(@class_class).find_method name
        else
          @class_class.find_method name
        end
      end
    end

    def subclass_of?(other)
      @class_class.subclass_of? other
    end

    def llvm_type
      @class_class.llvm_type
    end

    def name
      @class_class.name
    end

    def resolved_type
      self
    end

    def to_s
      name
    end
  end
end
