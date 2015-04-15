require_relative 'spec_helper'

describe "drfts.com website" do
  include Rack::Test::Methods

  it "should load all urls from the sitemap" do
    get '/sitemap.xml'

    doc = Nokogiri::HTML(last_response.body)
    doc.xpath("//loc").each do |loc|
      path = loc.content.gsub("https://drfts.com","")
      get path

      assert last_response.ok?, "`#{path}` returned #{last_response.status}"
    end
  end

  def test_that_sitemap_contains_all_pages
    crawled_paths = PAGES.map { |p| URI.parse(p.url.to_s).path }
    
    get '/sitemap.xml'
    doc = Nokogiri::HTML(last_response.body)
    sitemap_paths = doc.xpath("//loc").map { |l| URI.parse(l.content.to_s).path }
    sitemap_paths[0] = "/" # change the homepage path to be "/" instead of ""

    # both arrays should contain the same paths
    assert_equal [], crawled_paths - sitemap_paths
    assert_equal [], sitemap_paths - crawled_paths
  end

end

describe "automated crawl" do

  def test_that_all_internal_links_are_200
    PAGES.each do |p|
      assert_equal 200, p.code, "Error getting `#{p.url}` (ref: #{p.referer})"
    end
  end

  def test_that_every_page_has_a_valid_title
    PAGES.each do |p|
      title = p.doc.at_xpath("/html/head/title").text rescue nil

      assert title != nil && title != "", "`#{p.url}` invalid <title>"
    end
  end

  def test_external_links
    external_links = []

    PAGES.each do |p|
      links = []

      # grab all links from document body
      p.doc.css("a").each do |l|
        href = l.attribute("href").to_s

        # and filter out internal ones and local anchors
        if href[0] != "/" && href[0] != "#" && !href.match(/drfts\.com/)
          external_links << href
        end
      end
    end

    # test all these external links for status
    # external_links.uniq.great_test_method_here!
  end

end
