Spree.user_class.class_eval do
  has_many :user_authentications, dependent: :destroy

  devise :omniauthable

  def apply_omniauth(omniauth)
    skip_signup_providers = SpreeSocial::OAUTH_PROVIDERS.map { |p| p[1] if p[2] == 'true' }.compact
    if skip_signup_providers.include? omniauth['provider']
      self.email = omniauth['info']['email'] if email.blank?
      self.first_name = omniauth['info']['first_name'] if self.respond_to?(:first_name)
      self.last_name = omniauth['info']['last_name'] if self.respond_to?(:last_name)
    end
    user_authentications.build(provider: omniauth['provider'], uid: omniauth['uid'])
  end

  def password_required?
    (user_authentications.empty? || !password.blank?) && super
  end
end
