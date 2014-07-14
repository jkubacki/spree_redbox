class Redbox::Migrate::Client
  def migrate_client(redbox_client)
    if Spree::User.exists?(redbox_client_id: redbox_client.client_id)
      return nil
      # Spree::User.find_by(redbox_client_id: redbox_client.client_id)
    end
    user = Spree::User.new(create_hash(redbox_client))
    unless user.valid?
      puts user.errors.inspect
      return user.errors
    else
      user.save
    end
    return nil
  end

  def create_hash redbox_client
    email = redbox_client.mail
    if email.blank? or Spree::User.exists?(email: email)
      email = SecureRandom.uuid.to_s + '@email.com'
    end
    {
      email: email,
      redbox_client_id: redbox_client.client_id,
      encrypted_password: 'passwordsdadasdsa',
      password: 'passwordsdadasdsa',
      password_salt: 'salt',
      login: 'login'
    }
  end
end