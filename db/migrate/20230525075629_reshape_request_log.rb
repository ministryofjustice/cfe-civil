class ReshapeRequestLog < ActiveRecord::Migration[7.0]
  def change
    change_table :request_logs, bulk: true do |t|
      t.remove :assessment_id, type: :string
      t.remove :request_method, type: :string
      t.remove :endpoint, type: :string
      t.remove :params, type: :string
      t.remove :response, type: :string
      t.json :request, null: false
      t.json :response
      t.date :created_at
    end
  end
end
