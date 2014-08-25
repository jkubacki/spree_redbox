class Redbox::Category < ActiveRecord::Base
  establish_connection 'redbox'
  self.table_name = 'shop_category'
end