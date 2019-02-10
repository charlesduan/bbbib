module BBBib; class TitleFinder < Finder
  def param
    "title"
  end
  def finders
    return [
      [ '//meta[@name="citation_title"]/@content' ],
      [ '//meta[@property="og:title"]/@content' ],
      [ '//meta[@name="title"]/@content' ],
      [ '//meta[@name="twitter:title"]/@content' ],
      [ '//meta[@name="sailthru:title"]/@content' ],
      [ '//meta[@name="hdl"]/@content' ],
      [ '//script[@type="application/ld+json"]',
        proc { |x| JSON.parse(x.content)["name"] } ],
      [ '//script[@type="application/ld+json"]',
        proc { |x| JSON.parse(x.content)["headline"] } ],
      [ '//meta[@name="parsely-page"]/@content',
        proc { |x| JSON.parse(x.content)["title"] } ],
      [ '//title' ],
    ]
  end

  def postprocess(text)
    if text =~ /\s+[-|]\s+/
      first, last = $`, $'
      first_count, last_count = first.scan(/ /).count, last.scan(/ /).count
      if (first_count - last_count).abs >= 4
        text = first_count > last_count ? first : last
      end
    end
    text.gsub!(/\.$/, "")
    return text
  end
end; end


