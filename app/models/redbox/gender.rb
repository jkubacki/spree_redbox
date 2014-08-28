class Redbox::Gender < ActiveRecord::Base
  establish_connection 'redbox'
  self.table_name = 'shop_genders'

  has_and_belongs_to_many :products
end