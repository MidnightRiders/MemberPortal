# == Schema Information
#
# Table name: pick_ems
#
#  id         :integer          not null, primary key
#  match_id   :integer
#  user_id    :integer
#  result     :integer
#  created_at :datetime
#  updated_at :datetime
#

require 'spec_helper'

describe PickEm do
  pending 'does not allow multiples from a user on a match'
  pending 'does not allow votes after kickoff'
end
