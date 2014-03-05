# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

require 'csv'

Role.create([
    { name: 'admin' },
    { name: 'executive_board' },
    { name: 'at_large_board'},
    { name: 'individual' },
    { name: 'family' }
])

clubs = CSV.parse(File.read(Rails.root.join('lib/assets/clubs.csv')), headers: true)

clubs.each do |club|
  Club.create!(club.to_hash)
end