module Komixin::Models
  module Vote
    def self.included(base)
      base.instance_eval do
        belongs_to :user

        scope :likes, where('vote = 1')
        scope :dislikes, where('vote = 0')
      end
    end
  end
end