tool
extends Resource
class_name JsonScript


func get_as_text() -> String:
	var file = File.new()
	file.open(self.resource_path, File.READ)
	var text = file.get_as_text()
	file.close()
	return text


func set_as_text(text : String) -> void:
	var file = File.new()
	file.open(self.resource_path, File.WRITE)
	file.store_string(text)
	file.close()
	emit_changed()


func get_data():
	return parse_json(get_as_text()) if not get_as_text().empty() else null


func set_data(data) -> void:
	set_as_text(JSON.print(data, "\t"))
