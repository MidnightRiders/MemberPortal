# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

require 'csv'

%w(admin executive_board at_large_board individual family).each do |type|
  Role.find_or_create_by(name: type)
end

clubs = CSV.parse(File.read(Rails.root.join('lib/assets/clubs.csv')), headers: true)

clubs.each do |club|
  Club.create!(club.to_hash)
end