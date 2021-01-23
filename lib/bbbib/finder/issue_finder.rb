module BBBib; class IssueFinder < Finder
  def param
    "issue"
  end
  def finders
    return [
      [ "//meta[@name=\"citation_issue\"]/@content" ],
    ]
  end

  def optional?
    true
  end

end; end
