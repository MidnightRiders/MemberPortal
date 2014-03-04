namespace :db do
  task :import_executive_board => :environment do
    if File.exists?(Rails.root.join('lib/assets/executive_seeds.csv'))
      User.import(File.open(Rails.root.join('lib/assets/executive_seeds.csv')),[ Role.find_by(name: 'admin'), Role.find_by(name: 'executive_board')])
    else
      puts 'Executive Board file does not exist!'
    end
  end
  task :import_at_large_board => :environment do
    if File.exists?(Rails.root.join('lib/assets/at_large_seeds.csv'))
      User.import(File.open(Rails.root.join('lib/assets/at_large_seeds.csv')),[ Role.find_by(name: 'at_large_board')])
    else
      puts 'At Large Board file does not exist!'
    end
  end
  task import_boards: [ 'db:import_executive_board', 'db:import_at_large_board' ]
end