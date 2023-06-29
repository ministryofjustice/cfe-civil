class DropBankHolidays < ActiveRecord::Migration[7.0]
  def up
    drop_table :bank_holidays
  end

  def down
    create_table :bank_holidays, id: :uuid do |t|
      t.text :dates
      t.timestamps
    end
  end
end
