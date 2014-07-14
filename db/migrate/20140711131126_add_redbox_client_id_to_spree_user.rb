class AddRedboxClientIdToSpreeUser < ActiveRecord::Migration
  def change
    add_column :spree_users, :redbox_client_id, :integer
  end
end
