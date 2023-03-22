IRB.conf[:SAVE_HISTORY] = 100000

class String
  def each_codepoint16
    each_codepoint { |s| p s.to_s(16).upcase }
  end

  def ord16
    ord.to_s(16).upcase
  end
end

def showkey
  STDIN.raw{10.times.map{STDIN.getbyte}}
end
