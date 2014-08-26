class Redbox::Color < ActiveRecord::Base
  establish_connection 'redbox'
  self.table_name = 'shop_colors'
end