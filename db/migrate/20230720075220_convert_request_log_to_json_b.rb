class ConvertRequestLogToJsonB < ActiveRecord::Migration[7.0]
  def up
    change_table :request_logs, bulk: true do |t|
      t.change :request, :jsonb
      t.change :response, :jsonb
    end
  end

  def down
    change_table :request_logs, bulk: true do |t|
      t.change :request, :json
      t.change :response, :json
    end
  end
end
