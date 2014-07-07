class Redbox::StringDecoder

  # Decode redbox string. Only if encoded.
  def decode(str)
    captures = /pl:"(.*)\*";/m.match(str).captures
    if captures.size > 0 then captures else str end
  end

  # Encode redbox string.
  def encode(str)
    "pl:\"#{str}*\";"
  end

end