module BBBib; class FedRegSource < Source

  def self.accepts?(doc, url)
    url.host.end_with?('federalregister.gov') && \
      doc.at_xpath('//meta[@property="og:type"]/@content').to_s == 'article'
  end

  def source_type
    'govdoc'
  end

  def finders
    return [
      AgencyFinder,
      TitleFinder.with_finder(
        "//meta[@property='og:title']/@content",
        proc { |x| x.to_s.sub(/; .*/, '') }
      ),
      VolFinder.with_finder(
        "//dd[@id='document-citation']/@data-citation-vol"
      ),
      Finder.static('journal', 'Fed. Reg.'),
      PageFinder.with_finder(
        "//dd[@id='document-citation']",
        proc { |x| x.content.sub(/.* FR /, '') }
      ),
      DateFinder,
      OpturlFinder,
    ]
  end

  def ref_name
    [ @params['agency'] ].flatten.map { |a|
      a.gsub(/[^A-Z]+/, '').downcase
    }.join('-') + sprintf('%02d', @params['date'].split(' ').last.to_i % 100)
  end

  AgencyFinder = AuthorFinder.subclass do
    def param
      'agency'
    end
    def finders
      return [
        [
          '//span[@class="agencies"]', proc { |x|
            x.xpath('./a').map(&:content)
          }
        ]
      ]
    end
  end

end end
