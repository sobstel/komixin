module Komixin::Models
  module User
    USERNAME_MIN_LENGTH = 2
    USERNAME_MAX_LENGTH = 30
    PASSWORD_MIN_LENGTH = 6
    PASSWORD_MAX_LENGTH = 50

    def self.included(base)
      base.instance_eval do
        devise :database_authenticatable, :omniauthable, :registerable, :confirmable, :recoverable, :rememberable

        has_many :comics, :foreign_key => :author_id

        attr_accessible :username, :email, :password, :password_confirmation, :remember_me

        validates :username,
          :presence => true,
          :uniqueness => { :case_sensitive => false },
          :length => { :within => USERNAME_MIN_LENGTH..USERNAME_MAX_LENGTH },
          :format => { :with => /^[\p{Word}\-\_\.\s]+$/u }
        validates :email,
          :presence => true,
          :unless => :facebook?
        validates :email,
          :uniqueness => { :case_sensitive => false },
          :format => { :with => /^([\w\.%\+\-]+)@([\w\-]+\.)+([\w]{2,})$/i },
          :if => :email?
        validates :password,
          :presence => true,
          :if => :validate_password_presence?
        validates :password,
          :length => { :within => PASSWORD_MIN_LENGTH..PASSWORD_MAX_LENGTH },
          :confirmation => true,
          :if => :password?

        extend ClassMethods
      end
    end

    module ClassMethods
      def find_for_database_authentication(conditions)
        value = conditions[authentication_keys.first]
        where(["username = :value OR email = :value", { :value => value }]).first
      end

      def send_reset_password_instructions(attributes={})
        super(authentication_attribute(attributes))
      end

      def send_confirmation_instructions(attributes={})
        super(authentication_attribute(attributes))
      end

      def find_for_facebook_oauth(access_token, signed_in_resource=nil)
        data = access_token['extra']['user_hash']
        facebook_id = data['id']
        unless user = signed_in_resource || self.find_by_facebook_id(facebook_id)
          unless data['verified']
            user = self.new
            user.errors[:base] << I18n.t('devise.oauth_callbacks.facebook.unverified')
          else
            # username from link
            username = data['link'].match(/([\w\.]+)$/).to_s
            if username.empty? || username == username.to_i.to_s # empty or number
              # username from name
              username = data['name']
              if username.empty?
                username = "anonim"
              end
            end

            username = username.truncate USERNAME_MAX_LENGTH, :omission => ""

            # check if unique
            while self.find_by_username(username) do
              counter = 0 unless defined?(counter)
              counter += 1
              username = username.truncate USERNAME_MAX_LENGTH - counter.to_s.length - 1, :omission => ""
              username = "#{username}_#{counter}"
            end

            user = self.new
            user.username = username
            user.facebook_id = facebook_id
            user.password = Devise.friendly_token
            user.confirmed_at = Time.now
            user.save
          end
        end
        user
      end

      protected
        # determine email by username
        def authentication_attribute(attributes)
          user = self.find_by_username(attributes[:email])
          attributes[:email] = user[:email] if user
          attributes
        end
    end

    def email?
      email.present?
    end

    def password?
      password.present?
    end

    def facebook?
      facebook_id.present?
    end

    def validate_password_presence?
      # not facebook user or registration form (not id)
      !facebook? && !id
    end

  end
end