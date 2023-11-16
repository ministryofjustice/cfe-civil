module RemarkGenerators
  class BaseChecker
    class << self
      def record_type(collection)
        collection.first.class.to_s.underscore.tr("/", "_").to_sym
      end
    end
  end
end
