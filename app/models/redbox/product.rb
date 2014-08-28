class Redbox::Product < ActiveRecord::Base
  establish_connection 'redbox'
  self.table_name = 'shop_product'

  has_and_belongs_to_many :ocassions, class_name: 'Redbox::Ocassion'
  has_and_belongs_to_many :colors, class_name: 'Redbox::Color'
  has_and_belongs_to_many :styles, class_name: 'Redbox::Style'
  has_and_belongs_to_many :sizes, class_name: 'Redbox::Size'
  has_and_belongs_to_many :genders, class_name: 'Redbox::Gender'

  # accepts_nested_attributes_for :colors
  ENCODE_FIELDS = %w{description name name_storage name_invoice name_istore name_eprice name_eprice2 name_eprice3 keywords}
  DECODER = Redbox::StringDecoder.new

  ENCODE_FIELDS.each do |method|
    define_method(method) do |*args|
      DECODER.decode(super *args)
    end
    define_method(method + '=') do |*args|
      super DECODER.encode args[0]
    end
  end

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

  def self.within_category(id)
    where("category_id LIKE :id OR category_id2 LIKE :id OR category_id3 LIKE :id", {id: id.to_s + '%'})
  end

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
    return self.symbol[0..position-1]
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
    require 'php_serialize'
    PHP.unserialize(self.image).each do |img|
      images << img['name']
    end
    images
  end

  def images_links (admin = 't24', size = 0)
    links = []
    images_array.each do |img|
      if admin.blank?
        links << "http://www.red-box.pl/sklep/1/0_#{img}.jpg"
      else
        links << "http://red-box.pl/sklep/w.php?name=http://www.red-box.pl/sklep/1/#{size}_#{img}.jpg&admin=#{admin}"
      end
    end
    links
  end

  def price_brutto
    ((price * (vat.to_f/100 + 1))*100).round / 100.0
  end

  def on_hand
    in_stock - in_queue
  end

end
