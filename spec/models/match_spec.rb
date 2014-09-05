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
  pending 'does not accept empty attributes'
  pending 'returns score'
  pending ''
end
