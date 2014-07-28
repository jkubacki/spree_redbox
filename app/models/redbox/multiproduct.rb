class Redbox::Multiproduct < ActiveRecord::Base
  establish_connection 'redbox'
  self.table_name = 'multiproduct_main'
end