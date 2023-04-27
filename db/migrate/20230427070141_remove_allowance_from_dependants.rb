class RemoveAllowanceFromDependants < ActiveRecord::Migration[7.0]
  def change
    change_table :dependants, bulk: true do |t|
      t.remove :dependant_allowance,
               type: :decimal, default: 0
    end
  end
end
