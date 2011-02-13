module ModFilter
  def mod_by(input, operand)
    to_number(input) % to_number(operand)
  end

  private

  def to_number(obj)
    case obj
    when Numeric
      obj
    when String
      (obj.strip =~ /^\d+\.\d+$/) ? obj.to_f : obj.to_i
    else
    0
    end
  end
end

Liquid::Template.register_filter(ModFilter)