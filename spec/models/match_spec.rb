# == Schema Information
#
# Table name: matches
#
#  id           :integer          not null, primary key
#  home_team_id :integer
#  away_team_id :integer
#  kickoff      :datetime
#  location     :string(255)
#  home_goals   :integer
#  away_goals   :integer
#  created_at   :datetime
#  updated_at   :datetime
#  uid          :string(255)
#

require 'spec_helper'

describe Match do
  skip 'does not accept empty attributes'
  skip 'returns score'
  skip ''
end
