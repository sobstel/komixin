module Komixin
  class AuthFailure < Devise::FailureApp
    include ActionController::Rendering

    append_view_path Rails.root.join("app", "views")

    def respond
      if request.format == "xml"
        render 'users/shared/forbidden', :status => :forbidden
      else
        super
      end
    end
  end
end