class AddRmasIdToProposals < ActiveRecord::Migration
  def change
    add_column :proposals, :rmas_id, :string
  end
end
