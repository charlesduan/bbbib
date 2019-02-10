module BBBib; class WikipediaSource < Source

  def self.accepts?(doc, url)
    url.host.end_with?('wikipedia.org')
  end

  def initialize(doc, url)
    super(doc, url)
    @params['journal'] = 'Wikipedia'
  end

  def finders
    super - [ AuthorFinder, DateFinder ] + [ WikiDateFinder ]
  end

  class WikiDateFinder < DateFinder

    def find
      date = @doc.at_css('li#footer-info-lastmod').content
      if date =~ /last edited on (\d.*), at/
        date = DateTime.parse($1).strftime("%b %-d %Y")
        return "last edited #{date}"
      end
    end

  end

  def ref_name
    @params['title'].split(/\s+/)[0, 2].join("-").downcase
  end

end; end

