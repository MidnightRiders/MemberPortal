namespace :db do
  task clean: [ 'db:drop', 'db:create', 'db:migrate', 'db:seed', 'db:import_boards' ]
end