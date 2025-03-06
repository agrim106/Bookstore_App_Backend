class User < ApplicationRecord
  has_secure_password

  # Validations
  validates :full_name, presence: true, length: { minimum: 2, maximum: 50 }
  validates :email, presence: true, uniqueness: true, format: { with: /\A[^@\s]+@[^@\s]+\.[^@\s]+\z/, message: "must be a valid email" }
  validates :mobile_number, presence: true, format: { with: /\A\d{10}\z/, message: "must be a 10-digit number" }
  validates :password, presence: true, length: { minimum: 6 }, on: :create
end
