module BBBib; class TwitterSource < Source

  def self.accepts?(doc, url)
    url.host.end_with?('twitter.com')
  end

  def finders
    return [
      TitleFinder.subclass {
        def param ; "author" end
        def postprocess(text) ; text.gsub(/ on Twitter$/, '') end
      },
      Finder.subclass {
        def param ; "title" end
        def finders
          [ [
            '//meta[@property="og:description"]/@content',
            proc { |x|
              x.content.sub(/^\u201c/, '').sub(
                /(\s+https?:\/\/[^ ]*|\s+@\w+)*\u201d?$/, ''
              )
            }
          ] ]
        end
      },
      SiteFinder,
      DateFinder.with_finder(
        'div.permalink-tweet a.tweet-timestamp span._timestamp'
      ),
      UrlFinder,
    ]
  end

end; end
