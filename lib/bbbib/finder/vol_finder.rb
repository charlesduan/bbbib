module BBBib; class VolFinder < Finder
  def param
    "vol"
  end
  def finders
    return [
      [ '//meta[@name="bepress_citation_volume"]/@content' ],
      [ '//meta[@name="citation_volume"]/@content' ],
    ]
  end

  def optional?
    true
  end

end; end
