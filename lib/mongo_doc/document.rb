require 'mongo_doc/bson'
require 'mongo_doc/query'
require 'mongo_doc/attributes'
require 'mongo_doc/associations'
require 'mongo_doc/criteria'
require 'mongo_doc/finders'
require 'mongo_doc/index'
require 'mongo_doc/scope'
require 'mongo_doc/validations/macros'

module MongoDoc
  class UnsupportedOperation < RuntimeError; end
  class DocumentInvalidError < RuntimeError; end
  class NotADocumentError < RuntimeError; end

  module Document

    def self.included(klass)
      klass.class_eval do
        include Attributes
        extend Associations
        extend ClassMethods
        extend Criteria
        extend Finders
        extend Index
        extend Scope
        include ::Validatable
        extend Validations::Macros

        alias :id :_id
      end
    end

    def initialize(attrs = {})
      self.attributes = attrs
    end

    def ==(other)
      return false unless self.class === other
      self.class._attributes.all? {|var| self.send(var) == other.send(var)}
    end

    def new_record?
      _id.nil?
    end

    def remove
      raise UnsupportedOperation.new('Document#remove is not supported for embedded documents') if _root
      remove_document
    end

    def remove_document
      return _root.remove_document if _root
      _remove
    end

    def save(validate = true)
      return _root.save(validate) if _root
      return _save(false) unless validate and not valid?
      false
    end

    def save!
      return _root.save! if _root
      raise DocumentInvalidError unless valid?
      _save(true)
    end

    def to_bson(*args)
      {MongoDoc::BSON::CLASS_KEY => self.class.name}.tap do |bson_hash|
        bson_hash['_id'] = _id unless new_record?
        self.class._attributes.each do |name|
          bson_hash[name.to_s] = send(name).to_bson(args)
        end
      end
    end

    def to_param
      _id.to_s
    end

    def update_attributes(attrs)
      strict = attrs.delete(:__strict__)
      self.attributes = attrs
      return save if new_record?
      return false unless valid?
      if strict
        _strict_update_attributes(_path_to_root(self, attrs), false)
      else
        _naive_update_attributes(_path_to_root(self, attrs), false)
      end
    end

    def update_attributes!(attrs)
      strict = attrs.delete(:__strict__)
      self.attributes = attrs
      return save! if new_record?
      raise DocumentInvalidError unless valid?
      if strict
        _strict_update_attributes(_path_to_root(self, attrs), true)
      else
        _naive_update_attributes(_path_to_root(self, attrs), true)
      end
    end

    module ClassMethods
      def bson_create(bson_hash, options = {})
        new.tap do |obj|
          bson_hash.each do |name, value|
            obj.send("#{name}=", MongoDoc::BSON.decode(value, options))
          end
        end
      end

      def collection
        @collection ||= MongoDoc::Collection.new(collection_name)
      end

      def collection_name
        self.to_s.tableize.gsub('/', '.')
      end

      def create(attrs = {})
        instance = new(attrs)
        instance.save(true)
        instance
      end

      def create!(attrs = {})
        instance = new(attrs)
        instance.save!
        instance
      end
    end

    protected

    def _collection
      self.class.collection
    end

    def _naive_update_attributes(attrs, safe)
      return _root.send(:_naive_update_attributes, attrs, safe) if _root
      _update({}, attrs, safe)
    end

    def _remove
      _collection.remove({'_id' => _id})
    end

    def _strict_update_attributes(attrs, safe, selector = {})
      return _root.send(:_strict_update_attributes, attrs, safe, _path_to_root(self, '_id' => _id)) if _root
      _update(selector, attrs, safe)
    end

    def _update(selector, data, safe)
      _collection.update({'_id' => _id}.merge(selector), MongoDoc::Query.set_modifier(data), :safe => safe)
    end

    def _save(safe)
      notify_before_save_observers
      self._id = _collection.save(self, :safe => safe)
      notify_save_success_observers
      self._id
    rescue Mongo::MongoDBError => e
      notify_save_failed_observers
      raise e
    end

    def before_save_callback(root)
      self._id = Mongo::ObjectID.new if new_record?
    end

    def save_failed_callback(root)
      self._id = nil
    end

    def save_success_callback(root)
      root.unregister_save_observer(self)
    end

    def save_observers
      @save_observers ||= []
    end

    def register_save_observer(child)
      save_observers << child
    end

    def unregister_save_observer(child)
      save_observers.delete(child)
    end

    def notify_before_save_observers
      save_observers.each {|obs| obs.before_save_callback(self) }
    end

    def notify_save_success_observers
      save_observers.each {|obs| obs.save_success_callback(self) }
    end

    def notify_save_failed_observers
      save_observers.each {|obs| obs.save_failed_callback(self) }
    end
  end
end
