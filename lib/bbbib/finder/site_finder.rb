module BBBib; class SiteFinder < Finder
  def param
    "journal"
  end

  def finders
    return [
      [ "//meta[@name=\"citation_journal_title\"]/@content" ],
      [ '//script[@type="application/ld+json"]',
        proc { |x|
          obj = JSON.parse(x.content)
          if obj['publisher'] && obj['publisher']['name']
            obj['publisher']['name']
          else
            nil
          end
        }
      ],
      [ '//meta[@property="og:site_name"]/@content' ],
      [ '//meta[@name="cre"]/@content' ],
      [ '//meta[@name="application-name"]/@content' ],
      [ '//div[@class="reference-info"]/p/a' ],
    ]
  end
  def postprocess(text)
    text = text.sub(/\.$/, '')
    tc = TitleCap.new
    tc.aggressive = true
    tc.conversion = :tex
    return tc.recase(text)
  end
end; end


