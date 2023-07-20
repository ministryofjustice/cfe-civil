module RemarkGenerators
  class BaseChecker
    def self.call(collection)
      new(collection).call
    end

    def initialize(collection)
      @collection = collection
    end

  private

    def record_type
      @collection.first.class.to_s.underscore.tr("/", "_").to_sym
    end
  end
end
