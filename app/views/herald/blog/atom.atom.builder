xml.instruct! :xml, version: "1.0", encoding: "UTF-8"
xml.feed xmlns: "http://www.w3.org/2005/Atom" do
  xml.title "#{Herald.config.application_name} Blog"
  xml.subtitle "Latest articles from #{Herald.config.application_name}"
  xml.link href: herald.blog_atom_url(format: :atom), rel: "self", type: "application/atom+xml"
  xml.link href: herald.blog_url, rel: "alternate", type: "text/html"
  xml.id herald.blog_url
  xml.updated @posts.first&.updated_at&.iso8601

  @posts.each do |post|
    xml.entry do
      xml.title post.title
      xml.link href: herald.blog_post_url(post.slug), rel: "alternate", type: "text/html"
      xml.id herald.blog_post_url(post.slug)
      xml.published post.published_at.iso8601
      xml.updated post.updated_at.iso8601
      xml.summary post.excerpt if post.excerpt.present?
      xml.author do
        xml.name post.user.name
      end
    end
  end
end
