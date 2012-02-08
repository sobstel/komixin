module Komixin::Models
  module Comment
    COMMENT_MIN_LENGTH = 5
    COMMENT_MAX_LENGTH = 30000

    def self.included(base)
      base.instance_eval do
        include ActsAsCommentable::Comment

        belongs_to :commentable, :polymorphic => true
        belongs_to :user

        default_scope :order => 'created_at ASC'

        validates :comment,
          :presence => true,
          :length => { :within => COMMENT_MIN_LENGTH..COMMENT_MAX_LENGTH }

        validates :user,
          :presence => true
      end
    end

    def comic
      commentable
    end

  end
end