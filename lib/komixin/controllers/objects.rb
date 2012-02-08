# encoding: UTF-8
module Komixin::Controllers
  module Objects
    def self.included(base)

    end

    def index
      render :text => "abc"
    end

    def new
      render :text => "abc"
    end

    def create
      render :text => "abc"
    end
  end
end