xml.instruct!
xml.urlset xmlns: "http://www.sitemaps.org/schemas/sitemap/0.9" do

  # homepage
  xml.url do
    xml.loc settings.base_uri
    xml.changefreq "daily"
    xml.priority 1.0
  end

  # articles pages
  blog("articles").articles.each do |article|
    xml.url do
      xml.loc URI.join(config.base_uri, article.url)
      xml.changefreq "weekly"
      xml.priority 0.8
    end
  end

end