class ChangeClientInvolvementType < ActiveRecord::Migration[7.0]
  def change
    change_column_null :proceeding_types, :client_involvement_type, true, from: false
  end
end
