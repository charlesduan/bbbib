module BBBib
  class PubMedAuthorFinder < AuthorFinder
    def finders
      return [
        [
          "//header//div[@class='inline-authors']//a[@class='full-name']",
          proc { |x|
            x.content.gsub(/\b([A-Z]) /) { "#$1. " }
          }
        ],
      ]
    end
  end
  class PubMedTitleFinder < TitleFinder
    def finders
      return [ [ "//meta[@name=\"citation_title\"]/@content" ] ]
    end
  end
  class PubMedDateFinder < DateFinder
    def finders
      return [ [
        "//meta[@name=\"citation_date\"]/@content",
        proc { |x| x.to_s.gsub(/^.*(\d{4}).*$/) { $1 } }
      ] ]
    end
  end
  class PubMedIssueFinder < Finder
    def param
      "issue"
    end
    def finders
      return [ [
        "//meta[@name=\"citation_issue\"]/@content",
      ] ]
    end
  end
  class PubMedOpturlFinder < OpturlFinder
    def finders
      return [ [
        "//meta[@name=\"citation_abstract_html_url\"]/@content",
      ] ]
    end
  end
  class PubMedJournalFinder < Finder
    def param
      "journal"
    end
    def finders
      return [ [ "//meta[@name=\"citation_journal_title\"]/@content" ] ]
    end
    def postprocess(text)
      tc = TitleCap.new
      tc.aggressive = true
      tc.conversion = :tex
      return tc.recase(text)
    end
  end

  class PubMedPageFinder < Finder
    def param; "page" end
    def finders
      return [ [
        "//header//span[@class='cit']",
        proc { |x|
          x = x.to_s
          x =~ /\(\w+\):(\d+)/ ? $1 : nil
        }
      ] ]
    end
  end
end



module BBBib; class PubMedSource < Source
  def self.accepts?(doc, url)
    !doc.xpath('//meta[@name="ncbi_uid"]').empty?
  end

  def source_type
    'jrnart'
  end

  def pubmed_meta(name)
    @doc.at_xpath(
      "//meta[@name=\"citation_#{name}\"]/@content"
    ).to_s
  end

  def collect_page
    text = @doc.xpath("//header//span[@class='cit']").to_s
    return nil unless text =~ /\(\w+\):(\d+)/
    return $1
  end

#  def collect_params
#    @params['cite'] = [
#      pubmed_meta('volume'),
#      pubmed_meta('journal_title'),
#      collect_page
#    ].join(" ")
#  end

  def finders
    [
      PubMedAuthorFinder, PubMedTitleFinder, PubMedDateFinder,
      PubMedOpturlFinder, PubMedIssueFinder, VolFinder, PubMedJournalFinder,
      PubMedPageFinder,
    ]
  end

end; end

