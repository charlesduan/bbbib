module BBBib
  class PubMedPageFinder < Finder
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

  def finders
    [
      AuthorFinder.subclass {
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
      },
      TitleFinder.subclass {
        def finders
          return [ [ "//meta[@name=\"citation_title\"]/@content" ] ]
        end
      },
      DateFinder.subclass {
        def finders
          return [ [
            "//meta[@name=\"citation_date\"]/@content",
            proc { |x| x.to_s.gsub(/^.*(\d{4}).*$/) { $1 } }
          ] ]
        end
      },
      VolFinder, IssueFinder, SiteFinder,
      Finder.subclass {
        def param; "page" end
        def finders
          return [ [
            "//header//span[@class='cit']",
            proc { |x|
              x = x.to_s
              x =~ /\d+(?:\(\w+\))?:(\d+)/ ? $1 : nil
            }
          ] ]
        end
      },
      OpturlFinder,
    ]
  end

end; end

