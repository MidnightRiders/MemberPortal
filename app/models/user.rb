class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  has_many :user_roles
  has_many :roles, through: :user_roles

  validates :username, :email, :first_name, :last_name, presence: true

  has_paper_trail only: [ :username, :email, :first_name, :last_name, :address, :city, :state, :postal_code, :phone ]

  def role? r
    self.roles.find_by(name: r)
  end
end
