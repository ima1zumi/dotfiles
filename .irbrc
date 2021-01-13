class String
  def each_codepoint16
    each_codepoint { |s| p s.to_s(16) }
  end

  def ord16
    ord.to_s(16)
  end
end
