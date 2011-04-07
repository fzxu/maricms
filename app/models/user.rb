class User
  include Mongoid::Document
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable, :lockable and :timeoutable
  devise :database_authenticatable, :registerable,
    :recoverable, :rememberable, :trackable, :validatable, :confirmable, :lockable, :token_authenticatable ,:timeoutable

  # Virtual attribute for authenticating by either username or email
  # This is in addition to a real persisted field like 'username'
  attr_accessor :login, :email
  attr_accessible :login, :user_name, :email, :password, :password_confirmation
  
  field :user_name, :type => String
  
  validates_presence_of :user_name
  validates_uniqueness_of :user_name, :scope => authentication_keys[1..-1],
    :case_sensitive => false, :allow_blank => true
  #TODO validates_format_of     :user_name, :with  => email_regexp, :allow_blank => true
  
  protected

  def self.find_for_database_authentication(conditions)
    value = conditions[authentication_keys.first]
    self.any_of({ :user_name => value }, { :email => value }).first
  end
  
end
