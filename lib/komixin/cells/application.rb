module Komixin::Cells
  module Application
    def self.included(base)
      base.instance_eval do
        include Devise::Controllers::Helpers

        helper_method :current_user
        helper ApplicationHelper

      end
    end
  end
end