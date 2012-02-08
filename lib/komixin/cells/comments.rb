module Komixin::Cells
  module Comments

    def index
      @comments = options[:comments]
      render
    end

    def show
      @comment = options[:comment]
      render
    end

    def new
      return render :view => '403' unless user_signed_in?

      @comment = options[:comment]
      render
    end
  end
end