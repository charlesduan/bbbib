module BBBib; class Source

  def self.inherited(subclass)
    @subclasses << subclass
  end
  @subclasses = []

  def self.for(doc, url)
    return @subclasses.find { |sc| sc.accepts?(doc, url) } || self
  end

  def initialize(doc, url)
    @url = url
    @doc = doc
    @params = {}
  end

  attr_reader :params

  def finders
    [
      AuthorFinder, TitleFinder, DateFinder, SiteFinder, UrlFinder,
      VolFinder, PageFinder
    ]
  end

  def collect_params
    finders.each do |fc|
      finder = fc.new(@doc, @url)
      next if @params.include?(finder.param) # Skip if already filled in
      item = finder.find
      next if finder.optional? && item.nil?
      @params[finder.param] = finder.make_param(item)
    end
  end

  def ref_name
    if @params['author'] && @params['author'] =~ /^\{?(.+?)\}?$/
      authln = $1.sub(/ et al\./, '').split(/\s+/).last.downcase
      authln = nil unless authln =~ /^[\w-]+$/
      return authln
    else
      return nil
    end
  end

  def source_type
    if @params.include?('vol')
      return 'jrnart'
    elsif @params.include?('page')
      return 'magart'
    else
      return "website"
    end
  end

  def make_bib
    "\\def#{source_type}{#{ref_name}}{\n" + \
      @params.map { |k, v| "#{k}=#{v}," }.join("\n") + \
      "\n}"
  end

end; end
