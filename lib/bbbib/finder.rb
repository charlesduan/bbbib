#
# A class for finding information in an HTML page. This class should be
# subclassed, filling in the methods under API Methods below.
#
module BBBib; class Finder


  ########################################################################
  #
  # INHERITANCE HELPERS
  #
  ########################################################################

  #
  # Creates a subclass of this Finder. The given block may contain method
  # definitions for the subclass; the block is given to Class.new.
  #
  def self.subclass(&block)
    return Class.new(self, &block)
  end

  #
  # Creates a subclass of this Finder, replacing just the +finders+ method with
  # one that returns a single finder structure as given in the parameters to
  # this method.
  #
  def self.with_finder(*args)
    cls = Class.new(self)
    cls.send(:define_method, :finders) do
      return [ args ]
    end
    return cls
  end

  def self.static(param, val)
    cls = Class.new(self)
    cls.send(:define_method, :finders) do
      return []
    end
    cls.send(:define_method, :param) do
      return param
    end
    cls.send(:define_method, :default_item) do
      return val
    end
    return cls
  end

  ########################################################################
  #
  # API METHODS
  #
  # These methods are to be implemented by subclasses.
  #
  ########################################################################

  #
  # The name of the parameter to be found.
  #
  def param
    raise "Must give parameter name"
  end

  #
  # The list of finder specifications for this object. This method should return
  # an array of arrays, with each sub-array representing one pattern to match.
  # Specifically, the sub-arrays should contain the following items:
  #
  # - An xpath for where the data of interest will be found.
  #
  # - Optionally, a procedure for post-processing the result. Note that the
  #   procedure will be given a single XML node for processing, and should
  #   return a string or array of strings.
  #
  def finders
    raise "Must give finders"
  end

  #
  #
  # The default item to return for this finder if no match is found.
  #
  def default_item
    nil
  end

  #
  # A postprocessing step to be run on the found item. This should put the
  # output into its final common format, which will later be modified for the
  # particular output style such as TeX.
  #
  def postprocess(item)
    return item
  end

  #
  # If this returns true, then the parameter will not be included in the output
  # if its value is nil.
  #
  def optional?
    false
  end



  ########################################################################
  #
  # USAGE OF THE FINDER
  #
  ########################################################################

  #
  # Creates a new finder for a given document and URL.
  #
  def initialize(doc, url)
    @doc = doc
    raise ArgumentError, "URL is not a URI object" unless url.is_a?(URI)
    @url = url
  end

  #
  # For debugging
  #
  def msg(message)
  end

  #
  # Executes each of the finders. For the first one that returns results, run
  # +process_items+ on the finder's results (after processing with any procedure
  # in the finder) and return the output. If nothing is found, return
  # +default_item+.
  #
  def find
    msg("Finding for #{param}...")
    finders.each do |xpath, postproc|
      if xpath =~ /\//
        res = @doc.xpath(xpath)
      else
        res = @doc.css(xpath)
      end
      next if res.empty?
      msg("  Matched #{xpath}...")
      begin
        items = res.to_a.map { |x|
          postproc ? postproc.call(x) : x.content
        }.flatten
      rescue
        warn("For #{param}, finder #{xpath} failed: #$!")
        next
      end

      res = process_items(items)
      return res if res
    end
    return default_item
  end

  #
  # Process a list of items found. This method finds the first non-empty item,
  # runs postprocess on it, and returns it. Otherwise it returns nil.
  #
  def process_items(items)
    items.each do |item|
      next if item.nil? or item == ''
      msg("    Found item #{item}...")
      item = postprocess(item)
      next if item.nil? or item == ''

      msg("      Matched as #{item}")
      return item
    end
    return nil
  end

  def make_param(text)
    return text
  end

end; end


