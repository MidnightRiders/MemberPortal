class Family < Membership
  has_many :relatives

  after_create :re_up_relatives

  private

  def re_up_relatives
    return unless previous&.is_a? Family
    previous.relatives.approved.find_each do |relative|
      relative.re_up_for(year)
    end
  end
end
