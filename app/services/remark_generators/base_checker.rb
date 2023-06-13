module RemarkGenerators
  class BaseChecker
    def self.call(disposable_income_summary, collection)
      new(disposable_income_summary, collection).call
    end

    def initialize(disposable_income_summary, collection)
      @disposable_income_summary = disposable_income_summary
      @collection = collection
    end

  private

    def record_type
      @collection.first.class.to_s.underscore.tr("/", "_").to_sym
    end
  end
end
