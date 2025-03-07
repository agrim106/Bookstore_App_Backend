class User < ApplicationRecord
  has_secure_password

  # Validations
  validates :full_name, presence: true, length: { minimum: 2, maximum: 50 }
  validates :email, presence: true, uniqueness: true, format: { with: /\A[^@\s]+@[^@\s]+\.[^@\s]+\z/, message: "must be a valid email" }
  validates :mobile_number, presence: true, format: { with: /\A\d{10}\z/, message: "must be a 10-digit number" }
  validates :password, presence: true, length: { minimum: 6 }, on: :create

  def generate_otp
    self.otp = rand(100000..999999).to_s
    self.otp_expires_at = 15.minutes.from_now
    save!
  end
  
  def valid_otp?(otp)
    otp == self.otp && otp_expires_at.present? && Time.current < otp_expires_at
  end
end
