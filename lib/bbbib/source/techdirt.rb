module BBBib; class TechdirtSource < Source

  def self.accepts?(doc, url)
    url.host.end_with?('techdirt.com')
  end

  def collect_params
    super
    @params['author'].gsub!(/^.*\u2014\?/, '')
  end

end; end
