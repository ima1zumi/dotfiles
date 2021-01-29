class String
  def each_codepoint16
    each_codepoint { |s| p s.to_s(16).upcase }
  end

  def ord16
    ord.to_s(16).upcase
  end
end
