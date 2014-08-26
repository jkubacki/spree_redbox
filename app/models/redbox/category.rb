class Redbox::Category < ActiveRecord::Base
  establish_connection 'redbox'
  self.table_name = 'shop_category'
  after_initialize :decode_strings
  before_save :encode_strings


  private
  def decode_strings
    decoder = Redbox::StringDecoder.new
    self.name = decoder.decode(self.name)
  end

  def encode_strings
    decoder = Redbox::StringDecoder.new
    self.name = decoder.encode(self.name)
  end
end