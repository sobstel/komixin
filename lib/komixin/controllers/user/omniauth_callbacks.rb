module Komixin::Controllers
  module User::OmniauthCallbacks
    def facebook
      @user = ::User.find_for_facebook_oauth(env["omniauth.auth"], current_user)

      if @user.persisted?
        flash[:notice] = I18n.t "devise.omniauth_callbacks.facebook.success", :kind => "Facebook"
        sign_in_and_redirect @user, :event => :authentication
      else
        flash[:notice] = I18n.t "devise.omniauth_callbacks.facebook.error", :kind => "Facebook"
        redirect_to :root
      end
    end
  end
end