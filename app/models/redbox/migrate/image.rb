class Redbox::Migrate::Image
  include Redbox::Migrate

  def update_variant_images(redbox_product, variant)
    require 'php_serialize'
    images_serialized = redbox_product.image
    return if images_serialized.blank?
    begin
      images_unserialized = PHP.unserialize(images_serialized)
    rescue Exception => e
      puts "Image unserialize exception #{e.message}. Variant #{variant.id}, sku: #{variant.sku}."
      raise e
    end

    redbox_images = []
    images_unserialized.each do |image_serialized|
      filename = "#{image_serialized['name']}.jpg"
      redbox_images << filename
      add_image_to_variant(variant, filename)
    end
    # check_deleted_variant_images(variant, redbox_images)
  end

  private
  def add_image_to_variant(variant, filename)
    image_content = open(ENV['REDBOX_IMAGE_PREFIX'] + filename + ENV['REDBOX_IMAGE_SUFFIX']).read
    found = false
    variant.images.each do |image|
      if image.attachment_file_name == filename
        found = true
        break
      end
    end
    unless found
      file_path = 'uploads/tmp/' + filename
      File.open(file_path, 'wb+') { |f| f.write(image_content) }
      Spree::Image.create!(attachment: File.open(file_path), viewable: variant)
      File.delete(file_path) if File.exist?(file_path)
    end
  end

  def check_deleted_variant_images(variant, redbox_images)
    variant.images.each do |variant_image|
      variant_filename = variant_image.attachment_file_name
      found = false
      redbox_images.each do |redbox_filename|
        if redbox_filename == variant_filename
          found = true
          break
        end
      end
      unless found
        variant_image.destroy
      end
    end
  end

end
