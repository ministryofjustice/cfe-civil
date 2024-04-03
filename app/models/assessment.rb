class Assessment
  include ActiveModel::Model
  include ActiveModel::Validations
  include ActiveModel::Attributes

  CERTIFICATED = "certificated".freeze
  CONTROLLED = "controlled".freeze
  LEVELS_OF_HELP = [CERTIFICATED, CONTROLLED].freeze

  attr_accessor :level_of_help, :controlled_legal_representation, :not_aggregated_no_income_low_capital

  attribute :client_reference_id, :string
  attribute :remote_ip, :string
  attribute :submission_date, :date

  def id
    @id ||= SecureRandom.uuid
  end

  validates :remote_ip,
            :submission_date,
            presence: true
end
