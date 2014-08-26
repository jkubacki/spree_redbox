class Redbox::Ocassion < ActiveRecord::Base
  establish_connection 'redbox'
  self.table_name = 'shop_ocassions'
end