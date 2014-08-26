class Redbox::Ocassion < ActiveRecord::Base
  establish_connection 'redbox'
  self.table_name = 'shop_ocassions'

  has_and_belongs_to_many :products
end