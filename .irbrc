IRB.conf[:SAVE_HISTORY] = 100000
IRB.conf[:COMPLETOR] = :type
IRB.conf[:PROMPT_MODE] = :MY_PROMPT
IRB.conf[:PROMPT][:MY_PROMPT] = {
  :PROMPT_I => "%N(\e[34m%m\e[0m):%03n> ",
  :PROMPT_S => "%N(\e[34m%m\e[0m):%03n%l ",
  :PROMPT_C => "%N(\e[34m%m\e[0m):%03n* ",
  :RETURN => "%s\n"
}

if ENV['DEBUG'] != '1'
  begin
    require 'irb/theme/rk2025'
  rescue LoadError
  end
else
  Reline::Face.config(:completion_dialog) do |conf|
    conf.define(:default, foreground: "#f8f8f2", background: "#282a36")
    conf.define(:enhanced, foreground: "#f8f8f2", background: "#44475a")
    conf.define(:scrollbar, foreground: "#ffb86c", background: "#6272a4")
  end
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

# def Reline.debug_info
#   # return ['debug', 'info']
#   r = Reline.core.line_editor.instance_variable_get(:@past_lines).dup
#   r.map { a = _1.dup; a << Reline.core.line_editor.instance_variable_get(:@past_lines_index); a.inspect }
# end
#
# Reline.core.add_dialog_proc(:debug, ->{
#   contents = Reline.debug_info if Reline.respond_to?(:debug_info)
#   return if contents.nil? || contents.empty?
#   pos = Reline::CursorPos.new(screen_width, -cursor_pos.y - 1)
#   Reline::DialogRenderInfo.new(pos:, contents:, height: contents.size, face: :completion_dialog)
# }, nil)
