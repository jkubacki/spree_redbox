class Redbox::Unit < ActiveRecord::Base
  establish_connection 'redbox'
  self.table_name = 'unit'
end