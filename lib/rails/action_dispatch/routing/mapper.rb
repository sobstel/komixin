module ActionDispatch
  module Routing
    class Mapper
      def komixin
        scope :path_names => { :new => "nowy", :edit => "edycja" } do

        resources :comics, :only => [:index, :show, :new, :create, :edit, :update, :destroy], :path => "komiksy" do
          collection do
            get "fajne", :to => redirect("/komiksy/poczekalnia"), :as => :index_cool
            get "wybrane", :to => "comics#index_kudoed", :as => :index_kudoed
            get "najlepsze", :to => "comics#index_best", :as => :index_best
            get "poczekalnia", :to => "comics#index_notkudoed", :as => :index_notkudoed
            get "losowy", :to => "comics#show_random", :as => :random
            get "prywatne", :to => "comics#index_private", :as => :index_private
            get "a/:username", :to => "comics#index_by_username", :as => :index_by_username, :constraints => { :username => /.+/ }
          end
          member do
            get "lubie", :to => "comics#like", :as => :like
            get "nie-lubie", :to => "comics#dislike", :as => :dislike
            get "kudo", :to => "comics#kudo", :as => :kudo
            get "unkudo", :to => "comics#unkudo", :as => :unkudo
            get ":private_hash", :to => "comics#show", :constraints => { :private_hash => /\w{16}/ }, :as => :private
          end
          resources :comments, :only => [:create], :path => "komentarze"
        end
        get "sprawdz_w_abw", :to => "comics#current_user_can_create"
        get "wszystkie-komiksy.rss", :to => redirect("/wybrane-komiksy.rss")
        get "wybrane-komiksy.rss", :to => "comics#feed", :format => "rss", :as => :feed

        devise_for :users, :controllers => { :omniauth_callbacks => "user/omniauth_callbacks" }, :skip => [:sessions, :registrations, :passwords, :confirmations] do
          # sessions
          get "logowanie", :to => "devise/sessions#new", :as => :sign_in
          get "logowanie", :to => "devise/sessions#new", :as => :new_user_session
          post "logowanie", :to => "devise/sessions#create", :as => :sign_in
          get "wylogowanie", :to => "devise/sessions#destroy", :as => :sign_out
          # registrations
          scope :controller => "user/registrations" do
            get "rejestracja", :action => "new", :as => :sign_up # new_user_registration GET
            post "rejestracja", :action => "create", :as => :sign_up # user_registration POST
            get "profil/edycja", :action => "edit", :as => :edit_user_registration # edit_user_registration GET
            put "profil", :action => "update", :as => :user_registration # user_registration PUT
            # cancel_user_registration GET /users/cancel(.:format) {:action=>"cancel", :controller=>"devise/registrations"}
            # user_registration DELETE /users(.:format) {:action=>"destroy", :controller=>"devise/registrations"}
          end
          # password
          scope :controller => "devise/passwords" do
            post "haslo", :action => "create", :as => :user_password # user_password POST
            get "haslo/nowe", :action => "new", :as => :new_user_password # new_user_password GET
            get "haslo/edycja", :action => "edit", :as => :edit_user_password # edit_user_password GET
            put "haslo", :action => "update", :as => :user_password # user_password PUT
          end
          # confirmation
          scope :controller => "devise/confirmations" do
            post "potwierdzenie", :action => "create", :as => :user_confirmation # user_confirmation POST
            get "potwierdzenie/nowe", :action => "new", :as => :new_user_confirmation # new_user_confirmation GET
            get "potwierdzenie", :action => "show", :as => :user_confirmation # user_confirmation GET
          end
        end
        end
        match 'regulamin' => 'high_voltage/pages#show', :id => :terms, :as => :terms
        match 'polityka-prywatnosci' => 'high_voltage/pages#show', :id => :privacy_policy, :as => :privacy_policy
      end
    end
  end
end
