class User
  include Mongoid::Document
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable, :lockable and :timeoutable
  devise :database_authenticatable, :registerable,
    :recoverable, :rememberable, :trackable, :validatable, :confirmable, :lockable, :token_authenticatable ,:timeoutable

  # Virtual attribute for authenticating by either username or email
  # This is in addition to a real persisted field like 'username'
  attr_accessor :login
  attr_accessible :login, :user_name, :email, :password, :password_confirmation
  
  field :user_name
  
  protected

  def self.find_for_database_authentication(conditions)
    value = conditions[authentication_keys.first]
    self.any_of({ :user_name => value }, { :email => value }).first
  end
  
end
