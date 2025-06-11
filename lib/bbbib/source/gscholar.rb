module BBBib; class GScholarSource < Source

  def self.accepts?(doc, url)
    url.host.end_with?('scholar.google.com')
  end

  def source_type
    'case'
  end

  def finders
    [ PartiesFinder, CiteFinder, CourtFinder, YearFinder ]
  end

  def ref_name
    @params['parties'].sub(/^in re /i, '').split(/[,\s]+/).first.downcase
  end

  HEADER_REGEX = /^(.*), \d+ [\w. ]+ \d+ - ([\w.:, ]+) \d{4}$/

  class PartiesFinder < Finder
    def param
      "parties"
    end

    def finders
      return [ [ '//div[@id="gs_hdr_md"]/h1' ] ]
    end

    def postprocess(item)
      if item =~ HEADER_REGEX
        return $1
      else
        return '???'
      end
    end
  end

  class CourtFinder < Finder

    include CourtAbbreviator

    def param
      "court"
    end

    def finders
      return [ [ '//div[@id="gs_hdr_md"]/h1' ] ]
    end

    def postprocess(item)
      if item =~ HEADER_REGEX
        court = $2
        msg("      Found court #$2...")
        return lookup_court(court)
      else
        return nil
      end
    end

    def optional?
      true
    end

  end


  class YearFinder < Finder
    def param
      "year"
    end

    def finders
      return [ [ '//div[@id="gs_hdr_md"]/h1' ] ]
    end

    def postprocess(item)
      return $1 if item =~ /(\d{4})\s*$/
      return nil
    end
  end

  class CiteFinder < Finder
    def param
      "cite"
    end

    def finders
      return [ [ '//div[@id="gs_opinion"]/center/b' ] ]
    end

    def postprocess(item)
      if item =~ /^\s*(\d+) ([A-Z][\w.\s]+) (\d+)/
        vol, rep, pg = $1, $2, $3
        return "#{vol} #{proc_rep(rep)} #{pg}"
      else
        return nil
      end
    end

    def proc_rep(rep)
      rep = rep.gsub(/\b([A-Z]\.)\s+(?=\d|[A-Z]\.)/, '\1')
      rep = rep.gsub(/(\w\w\.)(\w)/, '\1 \2')
      rep = rep.gsub(/(\w\.)([A-Za-z]\w)/, '\1 \2')
      return rep
    end
  end

end; end
