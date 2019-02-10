module BBBib; class TwitterSource < Source

  def self.accepts?(doc, url)
    url.host.end_with?('twitter.com')
  end

  def collect_params
    super
    @params['author'] = @params['title'].gsub(/ on Twitter$/, '')
    @params['date'] = DateTime.parse(@doc.at_css(
      'div.permalink-tweet a.tweet-timestamp span._timestamp'
    ).content).strftime("%b %-d %Y")
    @params['title'] = @doc.at_xpath(
      '//meta[@property="og:description"]/@content'
    ).content.sub(/^\u201c/, '').sub(
      /(\s+https?:\/\/[^ ]*|\s+@\w+)*\u201d?$/, ''
    )
  end

end; end
