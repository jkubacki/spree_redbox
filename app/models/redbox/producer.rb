class Redbox::Producer < ActiveRecord::Base
  establish_connection 'redbox'
  self.table_name = 'shop_producer'
end