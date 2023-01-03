module BBBib; class ACMSource < Source
  def self.accepts?(doc, url)
    text = doc.xpath('//meta[@property="og:url"]')
    text && text.to_s =~ /dl\.acm\.org/
  end

  def source_type
    'jrnart'
  end

  def finders
    res = [
      AuthorFinder.with_finder(
        '//span[@class="loa__author-name"]'
      ),
      TitleFinder.with_finder('//h1[@class="citation__title"]'),
      DateFinder.with_finder('//span[@class="epub-section__date"]'),
      #VolFinder.with_finder(bepress_meta('volume')),
      #IssueFinder.with_finder(bepress_meta('issue')),
      SiteFinder.with_finder('//span[@class="epub-section__title"]'),
      PageFinder.with_finder(
        '//span[@class="epub-section__pagerange"]',
        proc { |x| x.sub(/Pages (\d+).*/, '\1') }
      ),
      OpturlFinder,
    ]
    return res
  end


end; end
