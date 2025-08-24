extends Node

var fileExtension :String = ".sfsave"

func _ready():
	pass

func read_save(key): # returns dictionary or null
	if OS.has_feature('web'):
		var JSONstr = JavaScriptBridge.eval("window.localStorage.getItem('" + key + "');")
		if (JSONstr):
			return JSON.parse_string(JSONstr)
		return null
	else:
		var file = FileAccess.open("user://" + key + fileExtension, FileAccess.READ)
		if not file:
			return null
		var newData = JSON.parse_string(file.get_as_text())
		if newData == null: # assume parse failed, attept converting from bytes from web save instead
			print("JSON save file parse failed, attempting to convert from bytes instead.")
			var bytes = FileAccess.get_file_as_bytes("user://" + key + fileExtension)
			newData = JSON.parse_string(bytes_to_var(bytes))
			
		file.close()
		return newData

func write_save(key,data):
	if OS.has_feature('web'):
		JavaScriptBridge.eval("window.localStorage.setItem('" + key + "', '" + JSON.stringify(data) + "');")
	else:
		var file = FileAccess.open("user://" + key + fileExtension, FileAccess.WRITE)
		file.store_line(JSON.stringify(data,"\t"))
		file.close()

func clearSave(key):
	
	if OS.has_feature('web'):
		var JSONstr = JavaScriptBridge.eval("window.localStorage.getItem('" + key + "');")
		if (JSONstr):
			JavaScriptBridge.eval("window.localStorage.removeItem('" + key + "');")
		else:
			return null
	else:
		var file = FileAccess.open("user://" + key + fileExtension, FileAccess.READ)
		if not file:
			return null
		file.close()
		var dir = DirAccess.open("user://")
		dir.remove(key + fileExtension)
	
func open_site(url):
	OS.shell_open(url)

func has_save(key) ->bool:
	if OS.has_feature('web'):
		var JSONstr = JavaScriptBridge.eval("window.localStorage.getItem('" + key + "');")
		if (JSONstr):
			return true
		else:
			return false
	else:
		var file = FileAccess.open("user://" + key + fileExtension, FileAccess.READ)
		if not file:
			return false
		return true

func downloadSave(key) -> void:
	if OS.has_feature('web'):
		var data = read_save(key)
		JavaScriptBridge.download_buffer( var_to_bytes(JSON.stringify(data)), key + fileExtension )
