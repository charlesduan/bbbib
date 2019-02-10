module BBBib; class PageFinder < Finder
  def param
    "page"
  end
  def finders
    return [
      [ '//meta[@name="bepress_citation_firstpage"]/@content' ],
    ]
  end

  def optional?
    true
  end

end; end


