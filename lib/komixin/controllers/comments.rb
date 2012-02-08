module Komixin::Controllers
  module Comments
    def self.included(base)
      base.instance_eval do
        before_filter :authenticate_user!, :only => [:create]
      end
    end

    def create
      @comic = Comic.find(params[:comic_id]) or raise ArgumentError, 'Invalid comic id'

      @comment = @comic.comments.new
      @comment.comment = params[:comment][:comment]
      @comment.user = current_user

      if @comment.save
        path = comic_path(@comic.id, :anchor => "comment-#{@comment.id}")
        redirect_to path, :notice => I18n.t('msg.comment.added')
      else
        render_return_cell :comments, :new, :comment => @comment
      end
    end
  end
end
