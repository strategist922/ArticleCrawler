require 'uri'
require 'nokogiri'
require 'open-uri'
require 'pandoc-ruby'

module ArticleCrawler
  class << self
    def [](url)
      uri = URI(URI.escape(url))
      class_name = uri.host.split('.')[0].capitalize
      class_name = 'Weixin' if class_name == 'Mp'

      const_get(class_name).new uri, uri.host
    end
  end

  class Base
    attr_reader :title

    def initialize(uri, hostname)
      @uri = uri

      @save_file_path = "./save/#{hostname}"
      system 'mkdir', '-p', @save_file_path

      @title = ''
      @content = ''
      @page = Nokogiri::HTML(open(@uri.to_s))
    end

    def crawl
      @page = Nokogiri::HTML(open(@uri.to_s))
      crawl_article_list
    end

    def crawl_article_list
      list = []

      loop do
        article_list.each { |article| list.push(article_link(article)) }

        # Exit if no next page
        break if next_page_link.nil?

        # Crawl next page
        @page = open_page(next_page_link)
      end

      list
    end

    def open_page(uri)
      Nokogiri::HTML(open(uri))
    end

    def article_list
      raise NotImplementedError
    end

    def article_list?
      article_list.any?
    end

    def article_link(_article)
      raise NotImplementedError
    end

    def next_page_link
      raise NotImplementedError
    end

    def crawl_article(_article)
      raise NotImplementedError
    end

    def to_docx(content)
      PandocRuby.html(content).to_docx
    end
  end
end
