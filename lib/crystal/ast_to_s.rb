require(File.expand_path("../visitor",  __FILE__))

module Crystal
  class ASTNode
    def to_s
      visitor = ToSVisitor.new
      self.accept visitor
      visitor.to_s
    end
  end

  class ToSVisitor < Visitor
    def initialize
      @str = ""
    end

    def visit_module(node)
    end

    def visit_int(node)
      @str << node.value.to_s
    end

    [
      ["add", "+"],
      ["sub", "-"],
      ["mul", "*"],
      ["div", "/"]
    ].each do |node, op|
      class_eval %Q(
        def visit_#{node}(node)
          node.left.accept self
          @str << " #{op} "
          node.right.accept self
          false
        end
      )
    end

    def visit_ref(node)
      @str << node.name
      false
    end

    def visit_call(node)
      @str << node.name
      @str << "("
      i = 0
      node.args.each do |arg|
        @str << ", " if i > 0
        arg.accept self
        i += 1
      end
      @str << ")"
      false
    end

    def visit_def(node)
      @str << "def "
      @str << node.name
      unless node.args.empty?
        @str << "("
        i = 0
        node.args.each do |arg|
          @str << ", " if i > 0
          arg.accept self
          i += 1
        end
        @str << ")"
      end
      @str << "\n"
      @str << "  "
      node.body.accept self if node.body
      @str << "\n"
      @str << "end"
      false
    end

    def visit_arg(node)
      @str << node.name
    end

    def to_s
      @str
    end
  end
end
