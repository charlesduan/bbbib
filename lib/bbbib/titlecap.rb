class TitleCap

  LCWORDS = %w(
      a an and as at but by down for from if in into like near nor of on onto or
      out over past per plus so than the till to unto up upon via when with yet
  )

  QUOTE_TABLE = {
      "\u2018" => :rsquo,
      "\u2019" => :lsquo,
      "\u201c" => :rdquo,
      "\u201d" => :ldquo,
      "\u2013" => :ndash,
      "\u2014" => :mdash,
  }

  CONVERSIONS = {
    :tex => {
      :rsquo => '`',
      :lsquo => "'",
      :rdquo => '``',
      :ldquo => "''",
      :ndash => '--',
      :mdash => '---',
      '&' => '\&',
      '%' => '\%',
    },
    :unicode => {
      :rsquo => "\u2018",
      :lsquo => "\u2019",
      :rdquo => "\u201c",
      :ldquo => "\u201d",
      :ndash => "\u2013",
      :mdash => "\u2014",
    },
  }

  def initialize
    @aggressive = false
    @conversion = :tex
  end

  attr_accessor :aggressive, :conversion

  # Changes the case of the given text.
  def recase(text)
    unless CONVERSIONS.include?(@conversion)
      raise "No text conversion table #{@conversion}"
    end
    conv = CONVERSIONS[@conversion]

    # If the text is all uppercase, make it lowercase. Otherwise we assume that
    # the cases are approximately correct, to avoid accidentally lowercasing
    # acronyms.
    text = text.downcase unless text =~ /[a-z]/

    # Extract words, spaces, and punctuation.
    words = text.scan(/\w+(?:['\u2019]\w+)?|\s+|[^\w\s]/)

    # This is the position of the last word, which is relevant because the last
    # word must be capitalized.
    last_word_index = words.rindex { |x| x =~ /\w/ }

    res = []
    next_must_upper = true
    words.each_with_index do |word, idx|
      case word
      when /\s/
        res.push(' ')
      when /\w/
        must_upper = false
        must_upper = true if next_must_upper
        must_upper = true if last_word_index == idx
        res.push(recase_word(word, must_upper))
        next_must_upper = false

      when /[:;?!.]/
        # After these punctuation, always use uppercase. TODO: distinguish
        # periods for abbreviations
        next_must_upper = true
        res.push(word)

      when /["']/
        # No change to next_must_upper after quotation marks
        res.push(word)
      when proc { |x| QUOTE_TABLE.include?(x) }
        res.push(QUOTE_TABLE[word])
      else
        res.push(word)
        next_must_upper = false
      end
    end

    res = gsub_array(res, /0[123]+0|[23]+|11+/, ' ', '-', :ndash, :mdash) {
      :mdash
    }
    res = res.map { |x| conv.include?(x) ? conv[x] : x }.join
    return res
  end

  def recase_word(word, must_upper)
    # First determine if the word should be left alone, which will be the case
    # if the second letter is uppercase (e.g., eBay or ACLU).
    return word if word.length >= 2 && word[1].upcase == word[1]
    word = word.gsub(/\u2019/, "'")

    if must_upper
      return ucfirst(word)
    elsif LCWORDS.include?(lcfirst(word))
      return @aggressive ? lcfirst(word) : word
    else
      return ucfirst(word)
    end
  end

  def ucfirst(word)
    return word[0].upcase + word[1..-1]
  end

  def lcfirst(word)
    return word[0].downcase + word[1..-1]
  end

  #
  # Performs a regexp-like match against an array, by first substituting
  # elements of the array with numbers based on a substitution list and then
  # peforming matches against a regexp of numbers. So, for example:
  #
  #   gsub_array(x, /01+0/, ' ', '-')
  #
  # would search x for patterns of ' ' followed by one or more '-' followed by a
  # space, because the digit 0 corresponds to ' ' and the digit 1 corresponds to
  # '-'.
  #
  def gsub_array(array, pattern, *subs)
    raise "Too many substitutions" if subs.count > 10

    # Convert the array to a string where a digit corresponds to an element that
    # matched one of subs, and a space represents an unmatching element.
    representation = array.map { |x| subs.index(x) || ' ' }.join
    replacements = []

    # For each match, save it to replacements and replace the text with an
    # equal-length string starting with an exclamation point and followed by
    # dashes.
    representation = representation.gsub(pattern) do |m|
      raise "Can't match empty pattern" if m == ""
      replacements.push(yield(m.split.map { |x| subs[x.to_i] }))
      "!#{'-' * (m.length - 1)}"
    end
    replacements = replacements.map { |x| x.is_a?(Array) ? x : [ x ] }

    # Now recompose the updated array by iterating through the representation,
    # replacing exclamation marks with elements from replacements, dashes with
    # nothing, and anything else (space or digit) with the corresponding array
    # element.
    raise "Rep is wrong length" if representation.length != array.count
    res = []
    representation.chars.zip(array).each do |rep_elt, array_elt|
      case rep_elt
      when '-'
      when '!' then res.push(*replacements.shift)
      else res.push(array_elt)
      end
    end
    return res
  end

end


