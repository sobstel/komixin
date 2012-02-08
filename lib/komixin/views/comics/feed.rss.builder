xml.instruct! :xml, :version => "1.0"
xml.rss :version => "2.0" do
  xml.channel do
    xml.title Settings.title
    xml.description Settings.desc
    xml.link request.protocol+request.host_with_port
    xml.language "pl"


    for comic in @comics
      xml.item do
        xml.title comic.title
        xml.description "#{image_tag request.protocol+request.host_with_port+comic.image.url}<br/>#{comic.description}"
        xml.link comic_url(comic)
        xml.guid comic_url(comic)
        xml.pubDate comic.created_at.to_s(:rfc822)
        xml.author comic.author.username
        xml.comments comic_url(comic)
      end
    end
  end
end