class User
  include ActiveModel::Model
  include ActiveModel::Dirty
  attr_accessor :first_name, :last_name, :username, :email, :password
  validates :password, presence: true, password: true, if: -> { new_record? || changes[:password] }

  def new_record?
    true
  end

  def password=(value)
    changes[:password] = true
    @password = value
  end
end
