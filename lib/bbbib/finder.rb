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
    cls.define_method(:finders) do
      return [ args ]
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

  #
  # Converts a text of this finder to the desired output format. TODO: This
  # should be moved to a separate system.
  #
  def make_param(text)
    return "" unless text
    return text.map { |x| make_param(x) } if text.is_a?(Array)
    text = tex_escape(text)
    while text =~ /^[^\n]{72}/ && text =~ /^([^\n]{1,72}) /
      text = "#$1\n#$'"
    end
    return text
  end

  def tex_escape(text, strip: true)
    unless text.is_a?(String)
      warn("Unexpected value to be tex escaped: #{text.class} #{text.inspect}")
      text = text.to_s
    end
    if (m = /<<([^>]+)>>/.match(text))
      return tex_escape(m.pre_match, strip: false) +
        m[1] + tex_escape(m.post_match, strip: false)
    end
    text = text.strip if strip
    text = text.gsub('&amp;', '&')
    text = text.gsub(/[^[:print:]]/, "?")
    text = text.gsub(/\s\s+/, " ")
    text = text.gsub(/\\/, "\\textbackslash")
    text = text.gsub(/[%{}]/) { "\\#$&" }
    text = more_tex_escape(text)
    return text
  end
  def more_tex_escape(text)
    text = text.gsub(/[#\$^&_]/) { "\\#$&" }
    text = text.gsub(/~/, "\\textasciitilde")
    return text
  end

end; end


