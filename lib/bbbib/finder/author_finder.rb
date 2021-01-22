module BBBib; class AuthorFinder < Finder
  def param
    "author"
  end
  def finders
    return [
      [ '//meta[@name="citation_author"]/@content',
        proc { |x|
          x = x.content
          x = "#$' #$`" if x =~ /, /
          x
        }
      ],
      [ '//meta[@name="author"]/@content' ],
      [ '//meta[@name="Author"]/@content' ],
      [ '//meta[@property="author"]/@content' ],
      [ '//meta[@name="byl"]/@content' ],
      [ '//meta[@name="sailthru.author"]/@content' ],
      [ '//meta[@property="article:author"]/@content' ],
      [ '//meta[@name="parsely-author"]/@content' ],
      [ '//script[@type="application/ld+json"]',
        proc { |x|
          c = JSON.parse(x.content)
          [ c ].flatten.map { |ci|
            if !ci.is_a?(Hash)
              nil
            elsif ci['creator']
              [ ci['creator'] ].flatten.map { |cr| cr['name'] || cr.to_s }
            elsif ci['author']
              [ ci['author'] ].flatten.map { |cr| cr['name'] || cr.to_s }
            else
              nil
            end
          }.compact
        }
      ],
      [ '//meta[@name="parsely-page"]/@content',
        proc { |x|
          c = JSON.parse(x.content)
          c.is_a?(Hash) ? [ c["author"] ].flatten.join(", ") : c.to_s
        }
      ],
      [ '//*[@itemprop="author"]' ],
      [ '//script[contains(text(), "wp_meta_data.author")]',
        proc { |x|
          if x.content =~ /wp_meta_data\.author\s*=\s*/
            JSON.parse($'.split(/[;\n]/, 2)[0])
          end
        }
      ],
      [ '//*[contains(@class, "author")]' ],
      [ '//*[contains(@class, "byline")]' ],
      [ '//*/@data-authorname' ],
      [ '//a[@rel="author"]' ],
    ]
  end

  def process_items(items)
    msg("    Found items #{items.inspect}...")

    # Some tests to discard invalid authors
    items = items.compact.flatten.map { |item|
      item = item['name'] || item.to_s if item.is_a?(Hash)
      item = $' if item =~ /(^| )by /i
      unless item =~ /[a-z]/
        item = item.split(/\s+/).map { |x| x.capitalize }.join(" ")
      end
      if item =~ /, /
        item = item.split(/, /)
      end
      item
    }.flatten.select { |item|
      return nil if item.scan(/ /).count > 5
      item && item.include?(' ')
    }.uniq

    msg("      Matched as #{items.inspect}")

    return etal_return(items)
  end

  def etal_return(items)
    case items.count
    when 0 then return nil
    when 1 then return items[0]
    when 2 then return items
    else return "#{items[0]} et al."
    end
  end

end; end

