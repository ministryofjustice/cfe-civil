module AssessmentEligibility
  def non_means_tested?(proceeding_type_codes:, receives_asylum_support:, submission_date:)
    # skip proceeding types check if applicant receives asylum support after MTR go-live date
    if asylum_support_is_non_means_tested_for_all_matter_types?(submission_date)
      receives_asylum_support
    else
      proceeding_type_codes.map(&:to_sym).all? { _1.in?(CFEConstants::IMMIGRATION_AND_ASYLUM_PROCEEDING_TYPE_CCMS_CODES) } && receives_asylum_support
    end
  end

  def asylum_support_is_non_means_tested_for_all_matter_types?(submission_date)
    !!Threshold.value_for(:asylum_support_is_non_means_tested_for_all_matter_types, at: submission_date)
  end
end
