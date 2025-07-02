# ApiCredentials.rb
# ApiCredentials

# 20250323
# 0.3.0

# Changes since 0.2:
# -/0: A more comprehensive set of aliases.
# 1. /password()/credentials()/
# 2. ~ api_key(): Use credentials and use the method rather than doing to_h first as that's redundant.
# 3. ~ api_secret(): Use credentials and use the method...
# 4. + alias_method :passphrase for api_secret()
# 5. + alias_method :password for api_secret()
# 6. + alias_method :username for api_key()

require 'Pd/PasswordFile'
require 'Pd/Password'

class ApiCredentials
  class << self
    def find(label)
      self.new(label: label)
    end
  end # class << self

  def api_key
    @api_key ||= credentials.username
  end
  alias_method :username, :api_key

  def api_secret
    @api_secret ||= credentials.password
  end
  alias_method :api_token, :api_secret
  alias_method :passphrase, :api_secret
  alias_method :password, :api_secret
  alias_method :to_s, :api_secret
  alias_method :token, :api_secret

  private

  def initialize(label:)
    @label = label
    setup
  end

  def credentials
    @credentials ||= Pd::Password.find(@label).first
  end

  def setup
    if File.exist?(Pd::PasswordFile.encrypted_filename)
      Pd::Password.from_csv(Pd::PasswordFile.read)
    end
  end
end
