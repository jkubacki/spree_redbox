class Redbox::Client < ActiveRecord::Base
  establish_connection 'redbox'
  self.table_name = 'shop_client'
end