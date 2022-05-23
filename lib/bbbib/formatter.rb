module BBBib
  class Formatter
    def self.inherited(subclass)
      FORMATTERS.push(subclass)
    end
    FORMATTERS = []

    def format(source)
      macro = "format_#{source.source_type}".to_sym
      if respond_to?(macro)
        send(macro, source)
      else
        format_default(source)
      end
    end
  end

  class TeXFormatter < Formatter

    def self.name
      "tex"
    end

    def format_default(source)
      res = "\\def#{source.source_type}{#{source.ref_name}}{\n"
      source.params.each do |k, v|
        [ v ].flatten.each do |av|
          av = tex_value(k, av)
          res << "#{k}=#{av},\n"
        end
      end
      res << "}"
      return res
    end
    def tex_value(key, value)
      value = tex_escape(value)
      unless key =~ /url/
        value = more_tex_escape(value)
      end
      value = "{#{value}}" if value =~ /[=,]/
      while value =~ /^[^\n]{72}/ && value =~ /^([^\n]{1,72}) /
        value = "#$1\n#$'"
      end
      return value
    end

    def tex_escape(text, strip: true)
      text = "" if text.nil?
      unless text.is_a?(String)
        warn("Unexpected value to be escaped: #{text.class} #{text.inspect}")
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

  end

  class TextFormatter < Formatter

    def self.name
      "text"
    end

    def format_default(source)
      res = []
      params = source.params
      if params['author']
        as = params['author']
        if as.instance_of?(Array)
          case as.count
          when 1 then res << fmt(as.first)
          when 2 then res << fmt(as.join(' & '))
          else res << fmt(as[0..-2].join(', ') + ' & ' + as.last)
          end
        else
          res << fmt(as)
        end
      end
      res << fmt(params['title']) if params['title']
      if params['cite']
        res << fmt(params['cite'])
      elsif params['journal']
        res << fmt([
          params['vol'], params['journal'], params['page']
        ].compact.join(' '))
      end
      res = res.join(", ")
      if params['date']
        res << " (#{fmt_date(params['date'])})"
      end
      if params['url']
        res << ", " << params['url']
      end
      return res
    end

    def fmt(val)
      val.strip
    end

    def fmt_date(val)
      if val =~ /^(Jan|Feb|Mar|Apr|Aug|Sept?|Oct|Nov|Dec) (\d+) /
        return "#$1. #$2, #$'"
      elsif val =~ /(\d+) (\d+)$/
        return "#$`#$1, #$2"
      else
        return val
      end
    end
  end

  class BibtexFormatter < TeXFormatter

    def self.name
      "bibtex"
    end

    def format_default(source)
      res = "@#{source.source_type}{#{source.ref_name},\n"
      source.params.each do |k, v|
        vtext = [ v ].flatten.map {
          |av| "{#{tex_value(k, av)}}"
        }
        if vtext.count > 1
          warn("Unexpected multivalue parameter #{k}") unless k == 'author'
          vtext = "{#{vtext.join(" and ")}}"
        elsif k == 'author' && vtext.first =~ / and /
          vtext = "{#{vtext.first}}"
        else
          vtext = vtext.first
        end
        res << "    #{k}=#{vtext},\n"
      end
      res << "}"
      return res
    end

  end

end


