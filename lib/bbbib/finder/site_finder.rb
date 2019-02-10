module BBBib; class SiteFinder < Finder
  def param
    "journal"
  end

  def finders
    return [
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
    text = text.sub(/^./) { |x| x.upcase }.sub(/\.$/, '')
    unless text =~ /[a-z]/
      text = text.split(/\s+/).map { |x| x.capitalize }.join(" ")
    end
    text
  end
end; end


