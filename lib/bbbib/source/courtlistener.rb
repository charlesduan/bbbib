module BBBib; class CourtListenerSource < Source

  def self.accepts?(doc, url)
    return false unless url.host == 'www.courtlistener.com'
    puts doc
    return true
  end

  def source_type
    'case'
  end

  def finders
    [ PartiesFinder, CiteFinder, CourtFinder, YearFinder, OpturlFinder ]
  end

  class PartiesFinder < Finder
    def param
      "parties"
    end
    def finders
      return [ [ '//h1[@id="caption"]' ] ]
    end
    def postprocess(item)
      item = item.sub(/ – CourtListener\.com$/, '')
      return item
    end
  end

  class CourtFinder < Finder
    include CourtAbbreviator
    def param
      "court"
    end

    def finders
      return [ [ '//h4[@class="case-court"]' ] ]
    end
    def postprocess(court)
      return lookup_court(court)
    end
  end

  class YearFinder < Finder
    def param
      "year"
    end

    def finders
      return [ [ '//span[@class="case-date-new"]' ] ]
    end

    def postprocess(item)
      item.match(/\d{4}/) { |m| return m[0] }
      return item
    end
  end

  class CiteFinder < Finder
    def param
      "cite"
    end

    def finders
      return [ [ '//div[@class="case-details"]/ul/li', proc { |nodes|
        nodes.map { |node|
          if node.content =~ /Citations:/
            node.xpath('./span[@class="select-all"]').first&.content
          else
            nil
          end
        }.compact
      } ] ]
    end
  end


end end
