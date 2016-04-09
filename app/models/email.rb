class Email < ActiveRecord::Base
  validates :title, :content, presence: true
end
