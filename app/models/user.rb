require 'digest/sha2'

class User < ActiveRecord::Base
  attr_reader :password

  validates :username, :password_digest, :session_token, :salt, presence: true
  validates :password, length: { minimum: 6, allow_nil: true }

  before_validation :ensure_session_token

  def password=(password)
    @password = password
    self.password_digest = BCrypt::Password.create(password))
  end

  def self.find_by_credentials(username:, password:)
    user = find_by(username: username)
    return nil if user.blank?
    user.password_digest.is_password?(password) ? user : nil
  end

  def ensure_session_token
    self.session_token ||= SecureRandom::urlsafe_base64
  end

  def reset_session_token!
    self.session_token = SecureRandom::urlsafe_base64
    self.save!
  end

  def password_digest
    BCrypt::Password.new(super)
  end
end
