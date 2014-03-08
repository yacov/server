class AddDescriptionColumnToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :country,    :string
    add_column :orders, :city,       :string
    add_column :orders, :street,     :string
    add_column :orders, :house,      :string
    add_column :orders, :time_start, :datetime
    add_column :orders, :time_close, :datetime
  end
end
