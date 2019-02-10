module BBBib; class Finder
  def initialize(doc, url)
    @doc = doc
    raise ArgumentError, "URL is not a URI object" unless url.is_a?(URI)
    @url = url
  end

  def msg(message)
  end

  def find
    msg("Finding for #{param}...")
    finders.each do |xpath, postproc, procall=false|
      res = @doc.xpath(xpath)
      next if res.empty?
      msg("  Matched #{xpath}...")
      begin
        if procall
          items = [ postproc.call(res) ].flatten
        else
          items = res.to_a.map { |x|
            postproc ? postproc.call(x) : x.content
          }
        end
      rescue
        warn("For #{param}, finder #{xpath} failed: #$!")
        next
      end

      res = process_items(items)
      return res if res
    end
    return default_item
  end

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

  def default_item
    nil
  end

  def postprocess(item)
    return item
  end

  def make_param(text)
    return "" unless text
    text = tex_escape(text)
    while text =~ /^[^\n]{72}/ && text =~ /^([^\n]{1,72}) /
      text = "#$1\n#$'"
    end
    return text
  end

  def tex_escape(text)
    unless text.is_a?(String)
      warn("Unexpected value to be tex escaped: #{text.class} #{text.inspect}")
      text = text.to_s
    end
    text = text.strip
    text = text.gsub('&amp;', '&')
    text = text.gsub(/[^[:print:]]/, "?")
    text = text.gsub(/\s\s+/, " ")
    text = text.gsub(/\\/, "\\textbackslash")
    text = text.gsub(/%{}/) { "\\#$&" }
    text = more_tex_escape(text)
    text = text.gsub("AMPERSAND", "&")
    text = "{#{text}}" if text =~ /[,=]/
    return text
  end
  def more_tex_escape(text)
    text = text.gsub(/[#\$^&_]/) { "\\#$&" }
    text = text.gsub(/~/, "\\textasciitilde")
    return text
  end

  def optional?
    false
  end

end; end


