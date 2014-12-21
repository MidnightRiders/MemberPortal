# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

require 'csv'

def create_or_update x, y
  x.attributes = y
  new = x.new_record?
  if new || x.changed?
    if x.save
      if new
        '  Created.'
      elsif  x.changed.empty?
        '  No changes.'
      else
        '  Updated: ' + x.changed.keys.join(', ')
      end
    else
      ' Could not save:' + x.errors.map{|k,v| "#{k}: #{v}\n"}.join
    end
  else
    '  No changes.'
  end
end

clubs = CSV.parse(File.read(Rails.root.join('lib/assets/clubs.csv')), headers: true)
clubs.each do |club|
  club = club.to_hash
  c = Club.find_or_initialize_by(abbrv: club['abbrv'])
  new = c.new_record?
  puts "#{new ? 'Adding' : 'Updating'} #{club['name']}…" unless Rails.env.test?
  if Rails.env.test?
    create_or_update(c, club)
  else
    puts create_or_update(c, club)
  end
end

players = CSV.parse(File.read(Rails.root.join('lib/assets/players.csv')), headers: true)
players.each do |player|
  player = player.to_hash
  p = Player.find_or_initialize_by(first_name: player['first_name'], last_name: player['last_name'])
  new = p.new_record?
  puts "#{new ? 'Adding' : 'Updating'} #{player['first_name']} #{player['last_name']}…" unless Rails.env.test?
  p.club_id = Club.find_by(abbrv: 'NE').id
  puts create_or_update(p, player) unless Rails.env.test?
end