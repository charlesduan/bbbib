module BBBib; class BepressSource < Source
  def self.accepts?(doc, url)
    !doc.xpath('//meta[@name="bepress_citation_journal_title"]').empty?
  end

  def source_type
    'jrnart'
  end

  def bepress_meta(name)
    @doc.at_xpath(
      "//meta[@name=\"bepress_citation_#{name}\"]/@content"
    )
  end

  def collect_params
    @params['opturl'] = bepress_meta('abstract_html_url')
    @params['name'] = bepress_meta('title')
    @params['cite'] = [
      bepress_meta('volume'),
      bepress_meta('journal_title'),
      bepress_meta('firstpage')
    ].join(" ")
    @params['year'] = bepress_meta('date')
    @params['issue'] = bepress_meta('issue')
    authors = @doc.xpath(
      "//meta[@name=\"bepress_citation_author\"]/@content"
    ).map { |x|
      x.to_s.sub(/^([^,]+), (.*)$/, "\\2 \\1")
    }
    case authors.count
    when 0 then ;
    when 1 then @params['author'] = authors[0]
    when 2 then @params['author'] = authors
    else        @params['author'] = "#{authors[0]} et al."
    end
  end

  def finders
    [
      AuthorFinder, TitleFinder, DateFinder, SiteFinder, OpturlFinder,
      VolFinder, PageFinder
    ]
  end


end; end
