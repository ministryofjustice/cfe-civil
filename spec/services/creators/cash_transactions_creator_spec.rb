require "rails_helper"

describe Creators::CashTransactionsCreator do
  describe ".call" do
    let(:assessment) { create :assessment }
    let(:cash_transaction_params) { params }
    let(:month0) { assessment.submission_date.beginning_of_month - 4.months }
    let(:month1) { assessment.submission_date.beginning_of_month - 3.months }
    let(:month2) { assessment.submission_date.beginning_of_month - 2.months }
    let(:month3) { assessment.submission_date.beginning_of_month - 1.month }

    subject(:creator) do
      described_class.call(cash_transaction_params:, submission_date: assessment.submission_date)
    end

    context "happy_path" do
      let(:params) { valid_params }

      it "doesnt error" do
        expect(creator.errors).to be_empty
      end

      it "creates the payment records" do
        cat = creator.records.select(&:child_care_payment?)
        trx_details = cat.sort_by(&:date).map { [_1.date, _1.amount, _1.client_id] }
        expect(trx_details).to eq(
          [
            [month1, 256.0, "ec7b707b-d795-47c2-8b39-ccf022eae33b"],
            [month2, 257.0, "ee7b707b-d795-47c2-8b39-ccf022eae33b"],
            [month3, 258.0, "ff7b707b-d795-47c2-8b39-ccf022eae33b"],
          ],
        )
      end
    end

    context "unhappy paths" do
      context "not exactly three occurrences of payments" do
        let(:params) { invalid_params_two_payments }

        it "returns expected errors" do
          expect(creator.errors).to eq ["There must be exactly 3 payments for category maintenance_in"]
        end
      end

      context "not consecutive months" do
        let(:params) { invalid_params_not_consecutive_months }

        it "returns expected errors" do
          expect(creator.errors).to eq ["Expecting payment dates for category maintenance_in to be 1st of three of the previous 3 months"]
        end
      end

      context "not the expected dates" do
        let(:params) { invalid_params_wrong_dates }

        it "returns expected errors" do
          expect(creator.errors).to eq ["Expecting payment dates for category child_care to be 1st of three of the previous 3 months"]
        end
      end
    end

    def valid_params
      {
        income: [
          {
            category: :maintenance_in,
            payments: [
              {
                date: month1.strftime("%F"),
                amount: 1046.44,
                client_id: "05459c0f-a620-4743-9f0c-b3daa93e5711",
              },
              {
                date: month2.strftime("%F"),
                amount: 1034.33,
                client_id: "10318f7b-289a-4fa5-a986-fc6f499fecd0",
              },
              {
                date: month3.strftime("%F"),
                amount: 1033.44,
                client_id: "5cf62a12-c92b-4cc1-b8ca-eeb4efbcce21",
              },
            ],
          },
          {
            category: :friends_or_family,
            payments: [
              {
                date: month2.strftime("%F"),
                amount: 250.0,
                client_id: "e47b707b-d795-47c2-8b39-ccf022eae33b",
              },
              {
                date: month3.strftime("%F"),
                amount: 266.02,
                client_id: "b0c46cc7-8478-4658-a7f9-85ec85d420b1",
              },
              {
                date: month1.strftime("%F"),
                amount: 250.0,
                client_id: "f3ec68a3-8748-4ed5-971a-94d133e0efa0",
              },
            ],
          },
        ],
        outgoings:
          [
            {
              category: :maintenance_out,
              payments: [
                {
                  date: month2.strftime("%F"),
                  amount: 256.0,
                  client_id: "347b707b-d795-47c2-8b39-ccf022eae33b",
                },
                {
                  date: month3.strftime("%F"),
                  amount: 256.0,
                  client_id: "722b707b-d795-47c2-8b39-ccf022eae33b",
                },
                {
                  date: month1.strftime("%F"),
                  amount: 256.0,
                  client_id: "abcb707b-d795-47c2-8b39-ccf022eae33b",
                },
              ],
            },
            {
              category: :child_care,
              payments: [
                {
                  date: month3.strftime("%F"),
                  amount: 258.0,
                  client_id: "ff7b707b-d795-47c2-8b39-ccf022eae33b",
                },
                {
                  date: month2.strftime("%F"),
                  amount: 257.0,
                  client_id: "ee7b707b-d795-47c2-8b39-ccf022eae33b",
                },
                {
                  date: month1.strftime("%F"),
                  amount: 256.0,
                  client_id: "ec7b707b-d795-47c2-8b39-ccf022eae33b",
                },
              ],
            },
          ],
      }
    end

    def invalid_params_two_payments
      params = valid_params.clone
      params[:income].first[:payments].pop
      params
    end

    def invalid_params_wrong_dates
      params = valid_params.clone
      params[:outgoings].last[:payments].first[:date] = "2020-05-06"
      params
    end

    def invalid_params_not_consecutive_months
      params = valid_params.clone
      params[:income].first[:payments].first[:date] = month0.strftime("%F")
      params
    end
  end
end
