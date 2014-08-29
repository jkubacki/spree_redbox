class Redbox::Category < ActiveRecord::Base
  establish_connection 'redbox'
  self.table_name = 'shop_category'
  after_initialize :decode_strings
  before_save :encode_strings

  scope :roots, -> { where("category_id LIKE '___'") }

  def products
    Redbox::CategoryTool.new.products self
  end

  def full_path
    if parent then parent.full_path + ' > ' + name else name end
  end

  def is_root?
    if number_chunks.size == 1
      true
    else
      false
    end
  end

  def parent
    return nil if is_root?
    if Redbox::Category.exists? parent_number
      Redbox::Category.find parent_number
    else
      nil
    end
  end

  def children(cascade = false)
    if cascade
      Redbox::Category.where("category_id LIKE '#{id}_%'")
    else
      Redbox::Category.where("category_id LIKE '#{id}___'")
    end
  end

  def self.category_tree(start_node = new, categories = [])
    start_node.children.each do |child|
      tree = category_tree(child)
      unless tree.empty?
        categories << { child => category_tree(child) }
      else
        categories << child.id
      end
    end
    categories
  end

  def self.all_names(start_node = new)
    names = {}
    start_node.children(true).each { |category| names[category.id] = category.full_path }
    names
  end

  def number_chunks
    id.to_s.scan /.{1,3}/
  end

  private
  def decode_strings
    decoder = Redbox::StringDecoder.new
    self.name = decoder.decode(self.name)
  end

  def encode_strings
    decoder = Redbox::StringDecoder.new
    self.name = decoder.encode(self.name)
  end

  def parent_number
    return nil if is_root?
    id[0..-4]
  end
end