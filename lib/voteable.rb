module Voteable
  def upvote(user_id)
    v = relevant_vote(user_id)
    v.update_attribute(:value, v.value == 1 ? 0 : 1)
    reset_score
    v
  end

  def downvote(user_id)
    v = relevant_vote(user_id)
    v.update_attribute(:value, v.value == -1 ? 0 : -1)
    reset_score
    v
  end

  def relevant_vote(user_id)
    raise 'No user_id provided' unless user_id
    votes.find_or_initialize_by(user_id: user_id) do |v|
      v.value = 0
    end
  end

  def score
    s = votes.sum(:value) || 0
    if self[:score]
      self[:score] ||= s
    else
      s
    end
  end

  def reset_score
    self[:score] = nil if self[:score]
  end
end
