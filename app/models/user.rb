class User < ApplicationRecord
  has_secure_password
  has_many :achievements
  has_many :tasks, :through => :achievements

end
