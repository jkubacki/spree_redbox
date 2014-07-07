class Redbox::Migrator

  def migrate_product(redbox = Redbox::Product.last)
    create_tools
    product = Spree::Product.new
    master = Spree::Variant.new
    master.description = @string_decoder.decode(redbox.description)

    puts product.inspect
    puts master.inspect
    'OK'
  end

  private
  def create_tools
    @string_decoder = Redbox::StringDecoder.new
  end

end