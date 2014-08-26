class Redbox::Style < ActiveRecord::Base
  establish_connection 'redbox'
  self.table_name = 'shop_styles'

  has_and_belongs_to_many :products
end