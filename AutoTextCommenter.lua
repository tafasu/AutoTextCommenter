--[[ 
"AutoTextCommenter" -- Automatic Comment subtitle for convenience of quality control (QC).
* Designed to work for Aegisub 2.0 and above
* Contact: fb.com/tafasu, github.com/tafasu, tafasu.com

Copyright (c) 2016-2017 TAFASU

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and 
associated documentation files (the "Software"), to deal in the Software without restriction, 
including without limitation the rights to use, copy, modify, merge, publish, distribute, 
sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is 
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial 
portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT 
NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND 
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES 
OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN 
CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
]]
local tr = aegisub.gettext

script_name = tr"AutoTextCommenter"
script_description = tr"Automatic Comment subtitle for convenience of quality control (QC)."
script_author = "TAFASU.com"
script_version = "1.00"
script_modified = "28 October 2017"

function do_comment_tag(text)
	local t = {}
	local bracketStack = 0
	local useBracket = 0
	local ch = ''
    for i = 1, #text  do
		ch = text:sub(i,i)
		if ch == '{' then
			if useBracket == 1 then
				useBracket = 0
				table.insert(t,'}')
			end
			bracketStack = bracketStack + 1
		end
		if useBracket == 0 and bracketStack == 0 then
			table.insert(t,'{')
			useBracket = 1
		end
		if ch == '}' then
			bracketStack = bracketStack - 1
		end
		table.insert(t, ch)
    end
	if useBracket == 1 then
		table.insert(t,'}')
	end
    return table.concat(t,"")
end

function commenttags_subs(subtitles)
	local linescleaned = 0
	for i = 1, #subtitles do
		aegisub.progress.set(i * 100 / #subtitles)
		if subtitles[i].class == "dialogue" and not subtitles[i].comment and subtitles[i].text ~= "" then
			local newLine = subtitles[i]
			newLine.text = do_comment_tag(subtitles[i].text)
			subtitles[i] = newLine
			aegisub.progress.task(linescleaned .. " lines commented")
		end
	end
end

function commenttags_macro(subtitles, selected_lines, active_line)
	commenttags_subs(subtitles)
	aegisub.set_undo_point(script_name)
end

function commenttags_filter(subtitles, config)
	commenttags_subs(subtitles)
end

aegisub.register_macro(script_name, script_description, commenttags_macro)
aegisub.register_filter(script_name, script_description, 0, commenttags_filter)
