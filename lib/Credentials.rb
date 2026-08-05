# Credentials.rb
# Credentials

# 20260310
# 0.1.0

# Notes:
# 1. Essentially renamed ApiCredentials to Credentials, keeping Credentials version number sequence and retired ApiCredentials.

# Changes:
# -/0: Merge ApiCredentials and Credentials
# 1. /ApiCredentials/Credentials/
# 2. ~ #to_s: Not an alias of api_secret/password anymore.
# 3. - class << self as that was unnecessary for a single class method.

require 'Pd/Password'
require 'Pd/EncryptedPasswords'

class Credentials
  def self.find(label)
    self.new(label: label)
  end

  def username
    @username ||= credentials.username
  end
  alias_method :api_key, :username

  def password
    @password ||= credentials.password
  end
  alias_method :api_secret, :password
  alias_method :api_token, :password
  alias_method :passphrase, :password
  alias_method :token, :password

  def to_s
    "#{username}:#{password}"
  end

  private

  def initialize(label:)
    @label = label
    setup
  end

  def credentials
    @credentials ||= Pd::Password.find(@label).first
  end

  def setup
    Pd::Password.from_csv(Pd::EncryptedPasswords.read.decrypt)
  end
end
