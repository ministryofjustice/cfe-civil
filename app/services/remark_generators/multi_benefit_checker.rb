module RemarkGenerators
  class MultiBenefitChecker < BaseChecker
    class << self
      def call(collection)
        populate_remarks(collection) if flagged?(collection)
      end

    private

      def flagged?(collection)
        collection.map(&:flags).any?(%w[multi_benefit])
      end

      def populate_remarks(collection)
        RemarksData.new(type: record_type(collection), issue: :multi_benefit, ids: collection.map(&:client_id))
      end
    end
  end
end
