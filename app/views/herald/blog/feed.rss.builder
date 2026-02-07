xml.instruct! :xml, version: "1.0"
xml.rss "version" => "2.0", "xmlns:atom" => "http://www.w3.org/2005/Atom" do
  xml.channel do
    xml.title "#{Herald.config.application_name} Blog"
    xml.description "Latest articles from #{Herald.config.application_name}"
    xml.link blog_url
    xml.tag! "atom:link", href: blog_feed_url(format: :rss), rel: "self", type: "application/rss+xml"

    @posts.each do |post|
      xml.item do
        xml.title post.title
        xml.description post.excerpt
        xml.pubDate post.published_at.to_fs(:rfc822)
        xml.link blog_post_url(post.slug)
        xml.guid blog_post_url(post.slug)
      end
    end
  end
end
