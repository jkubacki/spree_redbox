class Redbox::StringDecoder

  def decode(str)
    str[4..-3]
  end

  def encode(str)
    "pl:\"#{str}*\";"
  end

end