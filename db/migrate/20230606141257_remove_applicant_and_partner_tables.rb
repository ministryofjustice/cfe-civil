class RemoveApplicantAndPartnerTables < ActiveRecord::Migration[7.0]
  def change
    drop_table :applicants do |t|
      t.uuid "assessment_id", null: false
      t.date "date_of_birth"
      t.string "involvement_type"
      t.boolean "has_partner_opponent"
      t.boolean "receives_qualifying_benefit"
      t.boolean "employed"
      t.boolean "receives_asylum_support", default: false, null: false
      t.index :assessment_id, unique: true
    end
    drop_table :partners do |t|
      t.uuid "assessment_id", null: false
      t.date "date_of_birth"
      t.boolean "employed"
      t.index :assessment_id, unique: true
    end
  end
end
