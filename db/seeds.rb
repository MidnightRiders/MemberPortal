# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

require 'csv'

print 'Seeding clubs…'
CSV.foreach(Rails.root.join('lib/assets/clubs.csv'), headers: true, header_converters: :symbol) do |club|
  binding.pry
  Club.unscoped.find_or_initialize_by(abbrv: club[:abbrv]).update_attributes(club.to_h)
end
puts ' done.'

unless Rails.env.test?
  print 'Seeding players…'
  ne_id = Club.find_by(abbrv: 'NE').id
  CSV.foreach(Rails.root.join('lib/assets/players.csv'), headers: true, header_converters: :symbol) do |player|
    Player.unscoped.find_or_initialize_by(first_name: player[:first_name], last_name: player[:last_name]).update_attributes(p.to_h.merge({ club_id: ne_id }))
  end
  puts ' done.'
end
