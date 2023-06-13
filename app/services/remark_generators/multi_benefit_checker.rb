module RemarkGenerators
  class MultiBenefitChecker < BaseChecker
    def call
      populate_remarks if flagged?
    end

  private

    def flagged?
      @collection.map(&:flags).any?(%w[multi_benefit])
    end

    def populate_remarks
      RemarksData.new(type: record_type, issue: :multi_benefit, ids: @collection.map(&:client_id))
    end
  end
end
