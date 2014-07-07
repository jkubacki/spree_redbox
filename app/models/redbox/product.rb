class Redbox::Product < ActiveRecord::Base
  establish_connection 'redbox'
  self.table_name = 'shop_product'

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
end
