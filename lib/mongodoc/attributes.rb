module MongoDoc
  module Document
    module Attributes
      module Tree
        attr_accessor :_parent

        def _root
          @_root
        end

        def _root=(root)
          _associations.each do|a|
            association = send(a)
            association._root = root if association
          end
          @_root = root
        end
      end

      def self.extended(klass)
        klass.class_inheritable_array :_keys
        klass._keys = []
        klass.class_inheritable_array :_associations
        klass._associations = []

        klass.class_eval <<-RUBY, __FILE__, __LINE__ + 1
          include Tree

          def self._attributes
            _keys + _associations
          end
        RUBY
      end

      def key(*args)
        args.each do |name|
          _keys << name unless _keys.include?(name)
          attr_accessor name
        end
      end

      def has_one(*args)
        args.each do |name|
          _associations << name unless _associations.include?(name)
          attr_reader name
          define_method("#{name}=") do |value|
            raise NotADocumentError unless Document === value
            value._parent = self
            value._root = _root || self
            instance_variable_set("@#{name}", value)
          end
        end
      end

      def has_many(*args)
        options = args.extract_options!
        collection_class = if class_name = options.delete(:class_name)
          type_name_with_module(class_name).constantize
        end

        args.each do |name|
          _associations << name unless _associations.include?(name)
          define_method("#{name}") do
            association = instance_variable_get("@#{name}")
            unless association
              association = Proxy.new(:root => _root || self, :parent => self, :collection_class => collection_class || self.class.type_name_with_module(name.to_s.classify).constantize)
              instance_variable_set("@#{name}", association)
            end
            association
          end

          define_method("#{name}=") do |array|
            proxy = send("#{name}")
            proxy.clear
            proxy << array
          end
        end
      end

      def type_name_with_module(type_name)
        (/^::/ =~ type_name) ? type_name : "#{parents}::#{type_name}"
      end
    end
  end
end
