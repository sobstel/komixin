# encoding: UTF-8
module Komixin::Controllers
  module Comics
    def self.included(base)
      base.instance_eval do
        before_filter :authenticate_user!, :only => [:new, :create, :edit, :update, :destroy, :like, :dislike, :index_private]
        before_filter :find_comic, :only => [:show, :edit, :update, :destroy, :like, :dislike, :kudo, :unkudo]
      end
    end

    def index
      redirect_to index_kudoed_comics_path, :status => 301
    end

    def index_kudoed
      @comics = ::Comic.kudoed.page(params[:s] || params[:page])
      @title = "Wybrane komiksy" unless request.path == "/"
      render :index
    end

    def index_notkudoed
      @comics = ::Comic.notkudoed.page(params[:s] || params[:page])
      @title = "Poczekalnia"
      render :index
    end

    def index_best
      @comics = ::Comic.best.page(params[:s] || params[:page])
      @title = "Najlepsze komiksy"
      render :index
    end

    def index_by_username
      @user = ::User.where(:username => params[:username]).first
      raise ActiveRecord::RecordNotFound, "Couldn't find User with USERNAME=#{params[:username]}" unless @user

      @comics = @user.comics.public.order('comics.created_at DESC').page(params[:s] || params[:page])
      @title = "Komiksy (#{@user.username})"
      render :index
    end

    def index_private
      @comics = current_user.comics.private.page(params[:s] || params[:page])
      @title = "Prywatne komiksy"
      render :index
    end

    def show
      if (@comic.private || params[:private_hash]) && @comic.author != current_user
        raise ActiveRecord::RecordNotFound if params[:private_hash] != @comic.private_hash
      end
    end

    def show_random
      @comic = ::Comic.random
      raise ActiveRecord::RecordNotFound unless @comic
      render :show
    end

    def new
      if current_user && current_user.id == 3
        @comic = ::Comic.new
      else
        render_404
      end
    end

    def create
      comic_params = params[:comic]
      comic_data = {
        :title => comic_params[:title],
        :image => comic_params[:image],
        :author_id => current_user.id,
        :tag_list => comic_params[:tags],
        :private => comic_params[:private]
      }
      comic_data[:description] = comic_params[:description] if comic_params[:description]
      @comic = Comic.create(comic_data)
    end

    def edit
    end

    def update
      comic_params = params[:comic]
      @comic.title = comic_params[:title]
      @comic.description = comic_params[:description]
      @comic.private = false if comic_params[:private].to_i == 0
      @comic.tag_list = comic_params[:tags]
      if @comic.save
        redirect_to comic_url(@comic)
      else
        render :edit
      end
    end

    def destroy
      if @comic.deleteable?(current_user)
        @comic.destroy
        redirect_to comics_path, :alert => I18n::t('msg.comic.deleted')
      else
        redirect_to comics_path
      end
    end

    def current_user_can_create
      @can_create = user_signed_in?
    end

    def like
      vote(1)
      if (!@comic.kudoed? && @comic.deserves_kudo?)
        @comic.kudoed_at = Time.now
        @comic.save
      end
    end

    def dislike
      vote(0)
    end

    def kudo
      unless @comic.kudoed?
        @comic.kudoed_at = Time.now
        @comic.save
      end
      redirect_to :root
    end

    def unkudo
      if @comic.kudoed?
        @comic.kudoed_at = nil
        @comic.save
      end
      redirect_to :root
    end

    def feed
      @comics = ::Comic.kudoed.limit(15)
      render :feed
    end

    private
      def find_comic
        @comic = Comic.includes([{:comments => :user}, :votes]).find(params[:id]) 
      end

      def vote(vote)
        @vote = ::Vote.find_or_create_by_user_id_and_comic_id(current_user.id, @comic.id)
        vote_name = vote ? 'like' : 'dislike'
        if @vote.new_record? || @vote.vote != vote
          @vote.vote = vote
          @vote.save
          success = true
          msg = I18n::t("msg.comic.#{vote_name}d")
        else
          success = false
          msg = I18n::t("msg.comic.already_#{vote_name}d")
        end
        respond_to do |f|
          f.html { redirect_to comic_path(@comic), :notice => msg }
          f.json do
            json_response = Komixin::JsonResponse.new({:success => success, :msg => msg})
            if success
              json_response.args[:likes] = @comic.likes.count
              json_response.args[:dislikes] = @comic.dislikes.count
            end
            render :json => json_response
          end
        end
      end

      def render(*args, &block)
        if @title && params[:page] && params[:page].to_i > 1
          @title += " [str. #{params[:page]}]"
        end
        super
      end
  end
end
