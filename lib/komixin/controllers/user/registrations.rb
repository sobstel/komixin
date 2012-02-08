module Komixin::Controllers
  module User::Registrations
    def update
      if resource.update_attributes(params[resource_name])
        set_flash_message :notice, :update
        redirect_to :edit_user_registration
      else
        render_with_scope :edit
      end
    end
  end
end