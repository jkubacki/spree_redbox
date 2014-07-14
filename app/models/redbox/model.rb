class Redbox::Model < ActiveRecord::Base
  establish_connection 'redbox'
end