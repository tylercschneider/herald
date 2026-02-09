xml.instruct! :xml, version: "1.0", encoding: "UTF-8"
xml.urlset xmlns: "http://www.sitemaps.org/schemas/sitemap/0.9" do
  xml.url do
    xml.loc blog_url
    xml.changefreq "daily"
    xml.priority "1.0"
  end

  @posts.each do |post|
    xml.url do
      xml.loc blog_post_url(post.slug)
      xml.lastmod post.updated_at.iso8601
      xml.changefreq "weekly"
      xml.priority "0.8"
    end
  end

  @categories.each do |category|
    xml.url do
      xml.loc blog_category_url(category.slug)
      xml.changefreq "weekly"
      xml.priority "0.6"
    end
  end
end
