require 'json'

module BBBib; class CaseLawSource < Source

  def self.transform_url(url)
    if url =~ /^(\d+) [\w. ]+ (\d+)$/
      return "https://api.case.law/v1/cases/?" +
        URI.encode_www_form(:cite => url)
    else
      return nil
    end
  end

  def self.accepts?(doc, url)
    if url.host == 'api.case.law'
      if JSON.parse(doc.content)['count'] == 0
        raise 'No case data for that citation was found'
      elsif JSON.parse(doc.content)['count'] > 1
        warn('Multiple cases for that citation were found; using the first')
      end
      return true
    else
      return false
    end
  end

  def source_type
    'case'
  end

  def finders
    [
      PartiesFinder, CiteFinder, ParallelCiteFinder, CourtFinder, YearFinder,
      OptUrlFinder
    ]
  end

  def ref_name
    @params['parties'].sub(/^in re /i, '').split(/\s/).first.downcase
  end

  class OptUrlFinder < Finder
    def param
      "opturl"
    end

    def find
      JSON.parse(@doc.content)['results'][0]['frontend_url']
    end
  end

  class PartiesFinder < Finder
    def param
      "parties"
    end

    def find
      JSON.parse(@doc.content)['results'][0]['name_abbreviation']
    end
  end

  class CourtFinder < Finder
    def param
      'court'
    end

    def find
      court = JSON.parse(
        @doc.content
      )['results'][0]['court']['name_abbreviation']
      jurisdiction = JSON.parse(
        @doc.content
      )['results'][0]['jurisdiction']['name']

      if jurisdiction == 'U.S.'
        # Federal jurisdictions. Include court iff it is not SCOTUS.
        if court == 'U.S.'
          return nil
        else
          return court
        end
      else
        #
        # State jurisdictions. First, we need to get the reporter.
        #
        cite = JSON.parse(@doc.content)['results'][0]['citations'].find { |c|
          c['type'] == 'official'
        }['cite']
        reporter = cite.sub(/^\d+\s+/, '').sub(/\s+\d+$/, '')

        # Set court and jurisdiction to nil if they are duplicative.
        court = nil if court == jurisdiction
        jurisdiction = nil if reporter.include?(jurisdiction)

        # Now choose what to return. First deal with the easy case, where one or
        # more of them is nil.
        return court || jurisdiction unless court && jurisdiction

        # If both court and jurisdiction are set, we must join them, but to do
        # so we must determine whether to insert a space.
        if jurisdiction =~ /\b\w\.$/ && court =~ /^\w\./
          return jurisdiction + court
        else
          return jurisdiction + ' ' + court
        end
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

    def find
      JSON.parse(@doc.content)['results'][0]['decision_date'].split('-')[0]
    end
  end

  class CiteFinder < Finder
    def param
      "cite"
    end

    def find
      JSON.parse(@doc.content)['results'][0]['citations'].find { |c|
        c['type'] == 'official'
      }['cite']
    end
  end

  class ParallelCiteFinder < Finder
    def param
      "%cite"
    end

    def find
      JSON.parse(@doc.content)['results'][0]['citations'].select { |c|
        c['type'] != 'official'
      }.map { |x| x['cite'] }
    end
  end

end; end
