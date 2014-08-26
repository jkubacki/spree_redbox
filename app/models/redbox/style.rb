class Redbox::Style < ActiveRecord::Base
  establish_connection 'redbox'
  self.table_name = 'shop_styles'
end