module BBBib; class NYTSource < Source

  def self.accepts?(doc, url)
    url.host.end_with?('nytimes.com')
  end

  def initialize(doc, url)
    super(doc, url)
    @params['journal'] = 'The New York Times'
  end

end; end
