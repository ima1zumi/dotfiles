IRB.conf[:SAVE_HISTORY] = 100000
IRB.conf[:COMPLETOR] = :type

Reline::Face.config(:completion_dialog) do |conf|
  conf.define(:default, foreground: "#f8f8f2", background: "#282a36")
  conf.define(:enhanced, foreground: "#f8f8f2", background: "#44475a")
  conf.define(:scrollbar, foreground: "#ffb86c", background: "#6272a4")
end

if ENV['KT'] == '1'
  require 'katakata_irb' rescue nil
  puts 'Running on katakata_irb'
end

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
