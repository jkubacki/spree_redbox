class Redbox::Color < ActiveRecord::Base
  establish_connection 'redbox'
  self.table_name = 'shop_colors'

  has_and_belongs_to_many :products
end