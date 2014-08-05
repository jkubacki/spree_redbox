class Redbox::ProductLocal < Redbox::Product
  establish_connection 'redbox_local'
end
