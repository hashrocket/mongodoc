# Thanks Sandro!
# http://github.com/sandro
module MongoDoc
  module Associations
    class CollectionProxy
      include ProxyBase

      # List of array methods (that are not in +Object+) that need to be
      # delegated to +collection+.
      ARRAY_METHODS = (Array.instance_methods - Object.instance_methods).map { |n| n.to_s }

      # List of additional methods that must be delegated to +collection+.
      MUST_DEFINE = %w[to_a to_ary inspect to_bson ==]

      DO_NOT_DEFINE = %w[concat insert replace]

      (ARRAY_METHODS + MUST_DEFINE - DO_NOT_DEFINE).uniq.each do |method|
        class_eval <<-RUBY, __FILE__, __LINE__ + 1
          def #{method}(*args, &block)                 # def each(*args, &block)
            collection.send(:#{method}, *args, &block) #   collection.send(:each, *args, &block)
          end                                          # end
        RUBY
      end

      attr_reader :collection

      def _root=(root)
        @_root = root
        collection.each do |item|
          item._root = root if is_document?(item)
        end
      end

      def initialize(options)
        super
        @collection = []
      end

      alias _append <<
      def <<(item)
        attach(item)
        _append item
        self
      end
      alias push <<

      alias add []=
      def []=(index, item)
        attach(item)
        add(index, item)
      end
      alias insert []=

      def build(attrs)
        item = assoc_class.new(attrs)
        push(item)
      end

      def concat(array)
        array.each do |item|
          push(item)
        end
      end

      # Lie about our class. Borrowed from Rake::FileList
      # Note: Does not work for case equality (<tt>===</tt>)
      def is_a?(klass)
        klass == Array || super(klass)
      end
      alias kind_of? is_a?

      def replace(other)
        clear
        concat(other)
      end

      alias _unshift unshift
      def unshift(item)
        attach(item)
        _unshift(item)
      end

      def valid?
        all? do |child|
          if is_document?(child)
            child.valid?
          else
            true
          end
        end
      end

      protected

      def annotated_keys(src, attrs)
        assoc_path = "#{assoc_name}.#{index(src)}"
        annotated = {}
        attrs.each do |(key, value)|
          annotated["#{assoc_path}.#{key}"] = value
        end
        annotated
      end
    end
  end
end
