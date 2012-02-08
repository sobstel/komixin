# encoding: UTF-8
module Komixin::Controllers
  module Application
    def self.included(base)
      base.instance_eval do
        before_filter :e_before
        rescue_from ActiveRecord::RecordNotFound, :with => :render_404
        rescue_from ActionView::MissingTemplate, :with => :render_404
      end
    end

    private
      def render_return_cell(name, state, opts={})
        render :text => ::Cell::Base.render_cell_for(self, name, state, opts), :layout => _layout
      end

      # http://stackoverflow.com/questions/2385799/how-to-redirect-to-a-404-in-rails
      def render_404(exception = nil)
        if exception
          logger.info "Rendering 404 with exception: #{exception.message}"
        end
        respond_to do |format|
          format.html { render :file => "#{Rails.root}/public/404.html", :layout => false, :status => :not_found }
          format.any { head :not_found }
        end
      end

      # when site called from editor (before login)
      def e_before
        if params[:e]
          @notice = "Zaloguj się, a potem wróc do edytora, aby opublikować komiks."
          session[:e] = true
        end
      end

      # when site called from editor (after login)
      def e_after
        if session[:e]
          flash[:notice2] = "Wróć do edytora, aby opublikować komiks."
          session[:e] = nil
        end
      end

      def redirect_for_sign_in(scope, resource)
        e_after
        super(scope, resource)
      end
  end
end