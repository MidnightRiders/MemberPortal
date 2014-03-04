class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  has_many :user_roles, dependent: :destroy
  has_many :roles, through: :user_roles

  validates :first_name, :last_name, presence: true
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

  def self.import(file, roles = [])
    allowed_attributes = [:last_name, :first_name, :last_name, :address, :city, :state, :postal_code, :phone, :email, :member_since, :username]
    spreadsheet = Roo::Spreadsheet.open(file.path.to_s)
    header = spreadsheet.row(1)
    (2..spreadsheet.last_row).each do |i|
      row = Hash[[header, spreadsheet.row(i)].transpose]
      user = find_by(username: row['username'], first_name: row['first_name'], last_name: row['last_name']) || new
      user.attributes = row.to_hash.select { |x| allowed_attributes.include? :"#{x}"  }
      user.roles = roles
      user.roles << Role.find_by(name: row['membership_type']) if row['membership_type']
      if user.new_record?
        puts "Adding #{row['first_name']} #{row['last_name']}…"
        user.password = (pass = rand(36**10).to_s(36))
      else
        puts "Updating #{row['first_name']} #{row['last_name']}…"
        if user.changed?
          puts "  Changed: #{user.changes.keys.to_sentence}"
        else
          puts '  No changes' unless user.changed?
        end
      end
      if !user.save
        puts "  Could not save user #{row['first_name']} #{row['last_name']}:"
        puts '  ' + user.errors.to_hash.map{|k,v| "#{k}: #{v.to_sentence}"}.join("\n  ")
      else
        if pass
          puts "  Randomly-generated temporary password: #{pass}"
        end
      end
    end
  end

  def phone= phone
    self.phone = phone.gsub!(/[^\d]/,'') unless self.phone.nil?
  end

end
