module BBBib; class BepressSource < Source
  def self.accepts?(doc, url)
    !doc.xpath('//meta[@name="bepress_citation_journal_title"]').empty?
  end

  def source_type
    'jrnart'
  end

  def bepress_meta(name)
    "//meta[@name=\"bepress_citation_#{name}\"]/@content"
  end

  def finders
    [
      AuthorFinder.with_finder(bepress_meta('author'), proc { |x|
        x.to_s.sub(/^([^,]+), (.*)$/, "\\2 \\1")
      }),
      TitleFinder.with_finder(bepress_meta('title')),
      DateFinder.with_finder(bepress_meta('date')),
      VolFinder.with_finder(bepress_meta('volume')),
      IssueFinder.with_finder(bepress_meta('issue')),
      SiteFinder.with_finder(bepress_meta('journal_title')),
      PageFinder,
      OpturlFinder.with_finder(bepress_meta('abstract_html_url')),
    ]
  end


end; end
