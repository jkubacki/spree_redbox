class Redbox::Migrate::Unit
  def migrate_units(redbox_units = Redbox::Unit.all)
    redbox_units.each do |redbox_unit|
      migrate_unit redbox_unit
    end
  end

  def migrate_unit(redbox_unit)
    if Spree::Unit.exists?(redbox_unit.id)
      unit = Spree::Unit.find(redbox_unit.id)
      unit.short_name = redbox_unit.shortName
      unit.name = redbox_unit.name
      unit.save
    else
      Spree::Unit.create(
          id: redbox_unit.id,
          short_name: redbox_unit.shortName,
          name: redbox_unit.name,
      )
    end
  end
end