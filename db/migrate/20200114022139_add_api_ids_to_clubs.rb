API_CLUB_IDS = {
  '773958' => 'ATL',
  '6397' => 'CHI',
  '6001' => 'CLB',
  '8314' => 'COL',
  '6399' => 'DAL',
  '6602' => 'DC',
  '722265' => 'FCC',
  '8259' => 'HOU',
  '6637' => 'LA',
  '867280' => 'LAFC',
  '960720' => 'MIA',
  '207242' => 'MIN',
  '161195' => 'MTL',
  '915807' => 'NSC',
  '6580' => 'NE',
  '6514' => 'NY',
  '546238' => 'NYC',
  '267810' => 'ORL',
  '191716' => 'PHI',
  '307690' => 'POR',
  '6606' => 'RSL',
  '130394' => 'SEA',
  '6603' => 'SJ',
  '6604' => 'SKC',
  '56453' => 'TOR',
  '307691' => 'VAN',
  '0' => 'CHV',
}.freeze

class AddApiIdsToClubs < ActiveRecord::Migration
  def up
    add_column :clubs, :api_id, :integer, null: true

    API_CLUB_IDS.each do |id, abbrv|
      printf "Seeding #{abbrv}…"
      Club.find_by(abbrv: abbrv).update(api_id: id.to_i)
      puts "done."
    end

    change_column_null :clubs, :api_id, false
  end

  def down
    remove_column :clubs, :api_id
  end
end
