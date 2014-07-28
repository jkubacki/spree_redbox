module Redbox::Migrate
  def update_fields(subject, source, fields)
    fields.each do |field, source_field|
      if source_field.kind_of?(Array)
        i = 1
        while true
          break unless source_field[0].match /@\d/
          source_field[0].gsub!("@#{i}", eval("source.#{source_field[i]}").to_s)
          i = i + 1
        end
        eval "subject.#{field} = #{source_field[0]}"
      elsif source_field[0] == '#'
        eval "subject.#{field} = #{source_field[1..-1]}"
      else
        eval "subject.#{field} = source.#{source_field}"
      end
    end
  end
end