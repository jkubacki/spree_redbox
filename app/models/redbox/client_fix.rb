class Redbox::ClientFix
  def fix_unregistered
    clients = Redbox::Client.where("login LIKE '%iezarejestrowany1%'")
    clients.each { |c| puts c.login }
    clients.each do |client|
      number = client.login.match(/1+/)[0].length
      client.login = "niezarejestrowany#{number}"
      client.save
    end
    nil
  end
end