class User < ActiveRecord::Base
  has_many :searches, dependent: :destroy
  has_many :results, through: :searches
  # has_many :properties # TODO: Implement soon

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :authentication_keys => [:login]

  # Virtual attribute for authenticating by either username or email
  # This is in addition to a real persisted field like 'username'
  attr_accessor :login

  def self.find_first_by_auth_conditions(warden_conditions)
    conditions = warden_conditions.dup
    if login = conditions.delete(:login)
      where(conditions).where(["lower(username) = :value OR lower(email) = :value", { :value => login.downcase }]).first
    else
      where(conditions).first
    end
  end

  validates :username,
    presence: true,
    length: {maximum: 255},
    uniqueness: { case_sensitive: false, message: "Sorry. This username has been taken. Please supply a unique username." },
    format: { with: /\A[a-zA-Z0-9]*\z/, message: "Your username can only contain letters and numbers." }
end
