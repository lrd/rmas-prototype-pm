class ChangeDescriptionInProposalsAgain < ActiveRecord::Migration
  def change
    remove_column :proposals, :description
    add_column :proposals, :description, :text
  end
end
