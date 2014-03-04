class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  has_many :user_roles, dependent: :destroy
  has_many :roles, through: :user_roles

  validates :username, :email, :first_name, :last_name, presence: true
  validates :phone, format: { with: /[0-9]{3} *.? *[0-9]{3} *.? *[0-9]{4}\z/ }, allow_blank: true

  has_paper_trail only: [ :username, :email, :first_name, :last_name, :address, :city, :state, :postal_code, :phone ]

  def role?(r)
    self.roles.find_by(name: r)
  end

  def list_roles(verbose: false)
    rs = self.roles.map{|r| r.name.titleize }
    if verbose
      rs.to_sentence
    else
      rs.join(', ')
    end
  end
end
