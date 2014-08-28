class Redbox::Size < ActiveRecord::Base
  establish_connection 'redbox'
  self.table_name = 'shop_sizes'

  has_and_belongs_to_many :products
end