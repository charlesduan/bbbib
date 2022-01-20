module BBBib; class FCCSource < Source

  def self.accepts?(doc, url)
    url.host.end_with?('fcc.gov') && \
      doc.at_xpath('//meta[@property="og:type"]/@content').to_s == 'article'
  end

  def source_type
    'govdoc'
  end

  def finders
    return [
      Finder.static('agency', 'Federal Communications Commission'),
      TitleFinder.with_finder(
        "//meta[@property='og:title']/@content",
        proc { |x| x.to_s.sub(/; .*/, '') }
      ),
      VolFinder.with_finder(
        '//ul[@class="edocs"]/li[strong="FCC Record Citation:"]/text()',
        proc { |x| x.to_s.sub(/^\s*(\d+) FCC Rcd.*/, "\\1") }
      ),
      Finder.static('journal', 'F.C.C. Rcd.'),
      PageFinder.with_finder(
        '//ul[@class="edocs"]/li[strong="FCC Record Citation:"]/text()',
        proc { |x| x.to_s.sub(/^.*FCC Rcd (\d+).*/, "\\1") }
      ),
      ParenFinder,
      DateFinder,
      OpturlFinder,
    ]
  end

  def ref_name
    [ @params['agency'] ].flatten.map { |a|
      a.gsub(/[^A-Z]+/, '').downcase
    }.join('-') + sprintf('%02d', @params['date'].split(' ').last.to_i % 100)
  end

  class ParenFinder < Finder
    def param
      'paren'
    end
    def finders
      return [
        [
          '//ul[@class="edocs"]/li[strong="Document Type(s):"]/text()',
          proc { |x| x.to_s.strip.downcase }
        ]
      ]
    end
  end

end end
