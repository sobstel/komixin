module Komixin::Models
  module Comic
    TITLE_MIN_LENGTH = 4
    TITLE_MAX_LENGTH = 100
    DESC_MAX_LENGTH = 10000

    def self.included(base)
      base.instance_eval do
        paginates_per 10

        has_attached_file :image, :url => "/images/komiksy/:author_id/:id.jpg"
        acts_as_taggable
        acts_as_commentable
        
        #default_scope includes(:author, :tags, :comments, :likes, :dislikes)
        scope :public,
          where('comics.private != 1 OR comics.private IS NULL')
        scope :private,
          where('comics.private = 1').
          order('comics.created_at DESC')
        scope :all, public.order('created_at DESC')
        scope :best,
          public.
          joins(:votes).
          group('comics.id').
          order('(COUNT(NULLIF(votes.vote,0))-COUNT(NULLIF(votes.vote,1))) DESC, COUNT(votes.vote) DESC, comics.created_at DESC').
          having('COUNT(NULLIF(votes.vote,0))-COUNT(NULLIF(votes.vote,1)) > 9')
        scope :kudoed,
          public.
          where('kudoed_at IS NOT NULL').
          order('kudoed_at DESC')
        scope :notkudoed,
          public.
          where('kudoed_at IS NULL').
          order('created_at DESC')

        validates :title,
          :presence => true,
          :length => { :within => TITLE_MIN_LENGTH..TITLE_MAX_LENGTH }
        validates :description,
          :length => { :maximum => DESC_MAX_LENGTH }

        belongs_to :author, :class_name => "User"
        has_many :votes
        has_many :likes, :class_name => 'Vote', :conditions => 'votes.vote = 1'
        has_many :dislikes, :class_name => 'Vote', :conditions => 'votes.vote = 0'

        alias_method :orginal_tag_list=, :tag_list=
        alias_method :tag_list=, :new_tag_list=

        before_save :image_resolution
        before_save { |c| c.private_hash = ActiveSupport::SecureRandom.hex(8) if c.private_changed? && c.private && !c.private_hash }

        extend ClassMethods
      end
    end

    module ClassMethods
      def random
        self.kudoed.first(:offset => (self.kudoed.count * rand).to_i)
      end
    end

    # my own tag list to use both " " and "," as delimeters
    def new_tag_list=(new_tags)
      new_tags.gsub!(/\s+/, ',') unless new_tags.nil?
      set_tag_list_on('tag', new_tags)
    end

    def image_resolution
      unless self[:image_resolution]
        self[:image_resolution] = Paperclip::Geometry::from_file("#{Rails.public_path}#{image.url}").to_s        
      end
      self[:image_resolution] || '0x0'
    rescue Paperclip::NotIdentifiedByImageMagickError
      '0x0'
    rescue Paperclip::CommandNotFoundError
    end

    def image_width
      image_resolution.split('x')[0].to_i
    end

    def image_height
      image_resolution.split('x')[1].to_i
    end

    def deleteable?(current_author)
      (author == current_author) && (private? || (created_at  > Time.now - 30.minutes))
    end

    def kudoed?
      !!self[:kudoed_at]
    end

    def deserves_kudo?
      (self.likes.size - self.dislikes.size > 4)
    end

    def private?
      private
    end

    def to_param
      "#{id}-#{title.parameterize}"
    end
  end
end
