# == Schema Information
#
# Table name: mot_ms
#
#  id         :integer          not null, primary key
#  user_id    :integer
#  match_id   :integer
#  first_id   :integer
#  second_id  :integer
#  third_id   :integer
#  created_at :datetime
#  updated_at :datetime
#

require 'spec_helper'

describe MotM do
  skip 'does not allow multiples from a user on a match'
  skip 'does not allow repeated players'
  skip 'does not allow votes before halftime'
end
