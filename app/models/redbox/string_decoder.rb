class Redbox::StringDecoder

  # Decode redbox string. Only if encoded.
  def decode(str)
    unless (str =~/pl:".*\*";/m).nil?
      captures = /pl:"(.*)\*";/m.match(str).captures
      if captures.size > 0 then captures[0] else str end
    else
      str
    end
  end

  # Encode redbox string.
  def encode(str)
    unless (str =~/pl:".*\*";/m).nil?
      return str
    end
    "pl:\"#{str}*\";"
  end

end