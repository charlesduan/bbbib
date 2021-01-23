module BBBib; class UrlFinder < Finder
  def param
    "url"
  end

  def default_item
    @url.to_s
  end

  def finders
    return [
      [ "//meta[@name=\"citation_abstract_html_url\"]/@content" ],
      [ '//link[@rel="canonical"]/@href' ],
      [ '//meta[@property="og:url"]/@content' ],
      [ '//meta[@name="sailthru:url"]/@content' ],
      [ '//script[@type="application/ld+json"]',
        proc { |x| JSON.parse(x.content)["url"] } ],
      [ '//meta[@name="parsely-page"]/@content',
        proc { |x| JSON.parse(x.content)["link"] } ]
    ]
  end

  def postprocess(item)
    if item =~ /^\//
      (@url + item).to_s
    else
      item
    end
  end

  def more_tex_escape(text)
    return text
  end
end; end


module BBBib; class OpturlFinder < UrlFinder
  def param
    "opturl"
  end
end; end
