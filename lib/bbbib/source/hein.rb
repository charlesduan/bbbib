module BBBib; class HeinSource < Source

  def self.accepts?(doc, url)
    url.host.end_with?('heinonline.org')
  end

  def source_type
    'jrnart'
  end

  def finders
    return [
      AuthorFinder.with_finder(HEIN_SPAN, proc { |x| hein_author(x) }),
      TitleFinder.with_finder(HEIN_SPAN, proc { |x| hein_span('atitle', x) }),
      DateFinder.with_finder(HEIN_SPAN, proc { |x| hein_span('date', x) }),
      VolFinder.with_finder(HEIN_SPAN, proc { |x| hein_span('volume', x) }),
      SiteFinder.with_finder(HEIN_SPAN, proc { |x| hein_span('title', x) }),
      PageFinder.with_finder(HEIN_SPAN, proc { |x| hein_span('spage', x) }),
    ]
  end

  HEIN_SPAN = "//span[@class='Z3988']/@title"

  def hein_span(param, node)
    URI.decode_www_form(node.content).to_h["rft.#{param}"]
  end

  def hein_author(node)
    URI.decode_www_form(node.content).select { |k, v|
      k == 'rft.au'
    }.map { |k, a|
      if a =~ /, /
        l, f = $`, $'
        if l =~ / /
          "#{f} <<{>>#{l}<<}>>"
        else
          "#{f} #{l}"
        end
      else
        a
      end
    }
  end

end; end
