tool
extends TextEdit


signal type(ch, backspace)


export(Array, Array, String) var regions
export(PoolStringArray) var filter_keys


const Colors = {
	"keyword" : Color(0.890196, 0.403922, 0.478431),
	"string" : Color(0.87451, 0.815686, 0.572549)
}


func _ready():
	add_keyword_color("true", Colors.keyword)
	add_keyword_color("false", Colors.keyword)
	add_color_region("\"", "\"", Colors.string)
	add_color_region("\'", "\'", Colors.string)


func can_drop_data(position, data):
	if data is Dictionary and data.has("files"):
		for item in data["files"]:
			if item.get_extension().to_upper() != "JSON":
				return false
		return true
	return false


func drop_data(position, data):
	for item in data["files"]:
		get_parent().open(item)


func _gui_input(event):
	if event is InputEventKey and event.pressed:
		var text = event.as_text()
		if text in filter_keys:
			return
		if "Control" in text:
			return
		if text != "BackSpace":
			yield(self, "text_changed")
		emit_signal("type", get_current_char(), text == "BackSpace")


func _on_type(ch, remove : bool):
	if ch == null:
		return
	for i in regions:
		if ch == i[0]:
			if remove == true:
				var line = get_line(cursor_get_line())
				if not (cursor_get_column() < line.length()):
					continue
				if line[cursor_get_column()] == i[1]:
					line.erase(cursor_get_column(), 1)
				set_line(cursor_get_line(), line)
			else:
				insert_text_at_cursor(i[1])
				cursor_set_column(cursor_get_column() - 1)


func get_word(from : int):
	var line = get_line(cursor_get_line())
	if from < 0 or from > line.length():
		return
	var begin : int = from
	var end : int = line.find(" ", from)
	while (begin >= 0):
		if line[begin] == " ":
			break
		begin -= 1
	if end == -1:
		end = line.length() - 1
	return line.substr(begin + 1, end - begin)


func get_current_char():
	var line := get_line(cursor_get_line())
	return line[cursor_get_column() - 1] if not line.empty() else null


# Line 88 ~ 118 by Raiix
# I just referenced his code
func get_current_pos(word:String):
	if text.empty():
		return Vector2.ZERO
	var line := cursor_get_line()
	var column := cursor_get_column()
	var line_text := get_line(line)
	var font : Font = get_font('font')
	var res = font.get_string_size(line_text.substr(0, column))
	var tab_size = 4
	var tab_count = 0
	for s in line_text:
		if s == '\t':
			tab_count += 1
	var tab_x = tab_size * tab_count * font.get_char_size(' '.ord_at(0)).x
	
	var line_number_w = 0
	var line_number = get_line_count() - 1
	while line_number:
		line_number_w += 1
		line_number /= 10
	line_number_w = (line_number_w + 1) * font.get_char_size('0'.ord_at(0)).x
	
	res.x += tab_x + line_number_w - font.get_string_size(word).x - 3 - scroll_horizontal
	res.y = (line + 1 - scroll_vertical) * get_font_height()
	return res


func get_font_height():
	return get_font("font").get_height() + get_constant("line_spacing")
