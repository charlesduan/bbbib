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

  def reconfigure_params
    if %w(vol journal page).all? { |x| @params[x] && @params[x] != '' }
      @params['cite'] = %w(vol journal page).map { |x|
        @params.delete(x)
      }.join(" ")
    end
  end

  def ref_name(val = @params['author'])
    case val
    when nil then return nil
    when Array then return val.map { |x| ref_name(x) }.join("-")
    when /^\{?(.+?)\}?$/
      authln = $1.sub(/ et al\./, '').split(/\s+/).last.downcase
      authln = nil unless authln =~ /^[\w-]+$/
      return authln
    end
  end

  def source_type
    if @params.include?('vol') or @params.include?('cite')
      return 'jrnart'
    elsif @params.include?('page')
      return 'magart'
    else
      return "website"
    end
  end

  def make_bib
    res = "\\def#{source_type}{#{ref_name}}{\n"
    @params.each do |k, v|
      [ v ].flatten.each do |av|
        av = "{#{av}}" if av =~ /[=,]/
        res << "#{k}=#{av},\n"
      end
    end
    res << "}"
    return res
  end

end; end
