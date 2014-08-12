class Redbox::Product < ActiveRecord::Base
  establish_connection 'redbox'
  self.table_name = 'shop_product'

  after_initialize :decode_strings
  before_save :encode_strings

  class << self
    def instance_method_already_implemented?(method_name)
      return true if method_name =~ /^attributes/
      if (method_name == 'update')
        return
      end
      super
    end
  end

  scope :sprzedawalnia, -> { where(producer_id: 99) }
  scope :dollar, -> { where(producer_id: 73, visible: 1) }
  scope :with_hash, -> { where("`symbol` LIKE '#%'") }
  scope :with_variants, -> { where("`symbol` LIKE '#%\\^%'") }
  scope :without_variants, -> { where("`symbol` NOT LIKE '#%\\^%'") }
  scope :visible, -> { where(visible: 1) }

  def is_main_multiproduct?
    if Redbox::Multiproduct.exists?(symbol: self.symbol) then true else false end
  end

  def is_sub_multiproduct?
    if Redbox::Multiproduct.where("multi LIKE '%#{self.symbol}=%'").count > 0 then true else false end
  end

  def has_variants?
    if self.symbol =~ /\^/ && self.symbol[0] == '#' then true else false end
  end

  def master_symbol
    throw "Product has no variants." unless has_variants?
    position = self.symbol =~ /\^/
    return self.symbol[0..position]
  end

  def variants
    throw "Product has no variants." unless has_variants?
    Redbox::Product.where('`symbol` LIKE ?', master_symbol + '%').order(:symbol)
  end

  def images_array
    images = []
    if self.image.blank?
      return images
    end
    PHP.unserialize(self.image).each do |img|
      images << img['name']
    end
    images
  end

  def images_links (admin = 't24')
    links = []
    images_array.each do |img|
      if admin.blank?
        links << "http://www.red-box.pl/sklep/1/0_#{img}.jpg"
      else
        links << "http://red-box.pl/sklep/w.php?name=http://www.red-box.pl/sklep/1/0_#{img}.jpg&admin=#{admin}"
      end
    end
    links
  end

  def price_brutto
    ((price * (vat.to_f/100 + 1))*100).round / 100.0
  end

  private
  def decode_strings
    decoder = Redbox::StringDecoder.new
    self.description = decoder.decode(self.description)
    self.name = decoder.decode(self.name)
    self.name_storage = decoder.decode(self.name_storage)
    self.name_invoice = decoder.decode(self.name_invoice)
    self.name_istore = decoder.decode(self.name_istore) # kostiumowo
    self.name_eprice = decoder.decode(self.name_eprice) # eprice
    self.name_eprice2 = decoder.decode(self.name_eprice2) # eprice
    self.name_eprice3 = decoder.decode(self.name_eprice3) # eprice
    self.keywords = decoder.decode(self.keywords)
  end

  def encode_strings
    decoder = Redbox::StringDecoder.new
    self.description = decoder.encode(self.description)
    self.name = decoder.encode(self.name)
    self.name_storage = decoder.encode(self.name_storage)
    self.name_invoice = decoder.encode(self.name_invoice)
    self.name_istore = decoder.encode(self.name_istore) # kostiumowo
    self.name_eprice = decoder.encode(self.name_eprice) # eprice
    self.name_eprice2 = decoder.encode(self.name_eprice2) # eprice
    self.name_eprice3 = decoder.encode(self.name_eprice3) # eprice
    self.keywords = decoder.encode(self.keywords)
  end
end
