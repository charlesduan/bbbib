module BBBib
  module CourtAbbreviator
    def lookup_court(court)
      case court
      when 'Supreme Court'
        return nil
      when 'Court of Appeals, Federal Circuit'
        return 'Fed. Cir.'
      when /^Court of Appeals, ([23])[rn]d Circuit$/
        return "#$1d Cir."
      when /^Court of Appeals, (\d+\w\w) Circuit$/
        return "#$1 Cir."
      when 'Court of Appeals, Dist. of Columbia Circuit'
        return 'D.C. Cir.'
      when /^Dist(?:\.|rict) Court, (\w)\.?D\.? (\w+)$/
        return collapse_space("#$1.D. #{lookup_state($2)}")
      when /^Dist(?:\.|rict) Court, (?:D\.? )?(\w+)$/
        return collapse_space("D. #{lookup_state($2)}")
      else
        return court
      end
    end

    def lookup_state(state)
      return {
        'Alabama' => 'Ala.',
        'American Samoa' => 'Am. Sam.',
        'Arizona' => 'Ariz.',
        'Arkansas' => 'Ark.',
        'Baltimore' => 'Balt.',
        'California' => 'Cal.',
        'Canal Zone' => 'C.Z.',
        'Chicago' => 'Chi.',
        'Colorado' => 'Colo.',
        'Connecticut' => 'Conn.',
        'Delaware' => 'Del.',
        'Dist. of Columbia' => 'D.C.',
        'Florida' => 'Fla.',
        'Georgia' => 'Ga.',
        'Hawaii' => 'Haw.',
        'Illinois' => 'Ill.',
        'Indiana' => 'Ind.',
        'Kansas' => 'Kan.',
        'Kentucky' => 'Ky.',
        'Los Angeles' => 'L.A.',
        'Louisiana' => 'La.',
        'Maine' => 'Me.',
        'Maryland' => 'Md.',
        'Massachusetts' => 'Mass.',
        'Michigan' => 'Mich.',
        'Minnesota' => 'Minn.',
        'Mississippi' => 'Miss.',
        'Missouri' => 'Mo.',
        'Montana' => 'Mont.',
        'Nebraska' => 'Neb.',
        'Nevada' => 'Nev.',
        'New Hampshire' => 'N.H.',
        'New Jersey' => 'N.J.',
        'New Mexico' => 'N.M.',
        'New York' => 'N.Y.',
        'North Carolina' => 'N.C.',
        'North Dakota' => 'N.D.',
        'Northern Mariana Islands' => 'N. Mar. I.',
        'Oklahoma' => 'Okla.',
        'Oregon' => 'Or.',
        'Pennsylvania' => 'Pa.',
        'Philadelphia' => 'Phila.',
        'Puerto Rico' => 'P.R.',
        'Rhode Island' => 'R.I.',
        'South Carolina' => 'S.C.',
        'South Dakota' => 'S.D.',
        'San Francisco' => 'S.F.',
        'Tennessee' => 'Tenn.',
        'Texas' => 'Tex.',
        'Vermont' => 'Vt.',
        'Virgin Islands' => 'V.I.',
        'West Virginia' => 'W. Va.',
        'Virginia' => 'Va.',
        'Washington' => 'Wash.',
        'Wisconsin' => 'Wis.',
        'Wyoming' => 'Wyo.',
      }[state]
    end

    def collapse_space(text)
      return text.gsub(/\b([A-Z]\.)\s+(?=\d|[A-Z]\.)/, '\1')
    end
  end
end

