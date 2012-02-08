module Komixin
  def self.setup
    path = File.dirname(__FILE__)

    ::ActionController::Base.class_eval do
      prepend_view_path path+'/komixin/views'
    end

    ::Cell::Base.view_paths = [path+'/komixin/cells', path+'/komixin/cells/layouts'] + Cell::DEFAULT_VIEW_PATHS

    I18n.load_path += Dir[path+'/komixin/locales/*.{yml,rb}']

    ::Devise.setup do |config|
      config.warden do |manager|
        manager.failure_app = AuthFailure
      end
    end

    require path+'/rails/action_dispatch/routing/mapper.rb'
  end
end
