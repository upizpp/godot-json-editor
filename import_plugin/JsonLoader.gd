tool
extends ResourceFormatLoader
class_name JsonScriptLoader

func get_recognized_extensions() -> PoolStringArray:
	var res : PoolStringArray
	res.push_back("json")
	return res

func get_resource_type(path: String) -> String:
	return "Resource"

func handles_type(typename: String) -> bool:
	return typename == "Resource"

func load(path: String, original_path: String):
	var res = JsonScript.new()
	
	var file = File.new()
	var err = file.open(path, File.READ)
	if err != OK:
		printerr('Can\'t open "%s", code: %d' % [path, err])
		return err
	
	return res

