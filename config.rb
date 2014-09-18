# --- General settings
set :css_dir, 'assets/stylesheets'
set :js_dir, 'assets/javascripts'
set :images_dir, 'assets/images'
set :partials_dir, 'partials'

set :markdown_engine, :redcarpet
set :markdown,
    strikethrough:                true,
    autolink:                     true,
    footnotes:                    true,
    hard_wrap:                    true,
    fenced_code_blocks:           true,
    disable_indented_code_blocks: true

set :haml, { ugly: true }

set :page_config, {
  url: "https://drfts.com"
}

set :base_uri, "https://drfts.com"
set :cdn_uri,  "https://drgwi2ssaadfq.cloudfront.net/podcast/"

activate :blog do |blog|
  blog.name = "articles"
  blog.permalink = ":title"
  blog.sources = "articles/:year-:month-:day-:title.html"
  blog.layout = "article"

  blog.summary_separator = /@@@/
end

activate :directory_indexes
# activate :livereload

page "/sitemap.xml", :layout => false






# --- Build-specific configuration
configure :build do
  activate :minify_css
  activate :minify_javascript
  activate :asset_hash
end


# --- Helpers
module DrftsHelper
  # remove some deprecation warnings
  I18n.enforce_available_locales = true

  # enable method access for hashes
  class Hash
    Hashie::Extensions::MethodReader
  end

  # define some instance methods for an article
  class Middleman::Sitemap::Resource
    def id
      id = Digest::MD5.hexdigest(self.url)
      id << "-#{self.url.gsub(/\//, "")}"
    end

    # this returns a hash that can be queried with Hashie
    def author
      metadata[:page]['author']
    end
  end

  class Redcarpet::Render::HTML
    # There is a new Redcarpet::Render::HTML instance created
    # for every article that gets rendered

    # since the footnote reference is generated before the
    # actual definition we can generate an ID in here
    def footnote_ref(number)
      @article_id ||= [*('a'..'z'),*('0'..'9')].shuffle[0,4].join

      fn_ref = "<sup id='fnref-#{@article_id}-#{number}'>"
      fn_ref << "<a href='#fn-#{@article_id}-#{number}' rel='footnote'>"
      fn_ref << "#{number}</a></sup>"
    end

    def footnote_def(content, number)
      fn_def = "<li id='fn-#{@article_id}-#{number}'>"

      # the content argument actually is already parsed
      # with Markdown before being passed in
      # and equals "<p>#{content}</p>"
      # so we need to inject the link back to the reference
      # into the string before the closing </p>
      content.gsub! "</p>", " <a href='#fnref-#{@article_id}-#{number}' rev='footnote'>↩</a></p>"

      fn_def << "#{content}</li>"
    end

  end
end

helpers do
  # remove protocols from urls
  def clean_url(u)

    if u.start_with?('http://www.')
      u = u[11..-1]
    elsif u.start_with?('https://www.')
      u = u[12..-1]
    elsif u.start_with?('http://')
      u = u[7..-1]
    elsif u.start_with?('https://')
      u = u[8..-1]
    end

    if u.end_with?('/')
      u = u.chomp('/')
    end

    u
  end
end