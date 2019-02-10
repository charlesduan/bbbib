module BBBib; class DateFinder < Finder
  def param
    "date"
  end
  def finders
    return [
      [ '//meta[@name="bepress_citation_date"]/@content' ],
      [ '//meta[@name="citation_publication_date"]/@content' ],
      [ '//meta[@property="article:published_time"]/@content' ],
      [ '//meta[@property="article.published"]/@content' ],
      [ '//meta[@property="DisplayDate"]/@content' ],
      [ '//meta[@name="pubdate"]/@content' ],
      [ '//meta[@name="date_published"]/@content' ],
      [ '//meta[@name="DC.date.issued"]/@content' ],
      [ '//script[@type="application/ld+json"]',
        proc { |x|
          [ JSON.parse(x.content) ].flatten.map { |i|
            [ i["datePublished"], i['dateCreated'] ] if i.is_a?(Hash)
          }.flatten.compact[0]
        }
      ],
      [ '//meta[@name="parsely-page"]/@content',
        proc { |x| JSON.parse(x.content)["pub_date"] } ],
      [ '//time/@datetime' ],
      [ '//time' ],
      [ '//meta[@name="date"]/@content' ],
      [ '//span[@class="pub_date"]' ],
    ]
  end
  def postprocess(item)
    return item if item =~ /^\d{4}$/
    DateTime.parse(item).strftime("%b %-d %Y") rescue nil
  end
end; end


