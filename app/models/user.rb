class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  belongs_to :role

  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :role, presence: true

  def manager?
    role.name == 'manager'
  end
end
