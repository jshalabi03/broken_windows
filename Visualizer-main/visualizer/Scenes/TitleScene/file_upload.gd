extends FileDialog

# Code modified from https://github.com/Pukkah/HTML5-File-Exchange-for-Godot/
#  (linked addon only supports images... re-writing code to serve our purposes)

signal gamelog_ready
signal in_focus


func _notification(notification: int):
	if notification == MainLoop.NOTIFICATION_WM_FOCUS_IN:
		emit_signal("in_focus")


func _ready():
	if Global.use_js:
		_define_js()
	var _err = Global.connect("gamelog_check_completed",self,"_on_gamelog_valid")


var thread := Thread.new()
func _on_FileDialog_file_selected(path):
	Global.emit_signal("verify_gamelog_start")
	
	if thread.is_active():
		thread.wait_to_finish()
	
	thread.start(self, "_read_file", path)


func _on_FileDialog_files_selected(paths: PoolStringArray):
	var path: String = paths[0]
	paths.remove(0)
	Global.gamelog_paths = paths
	emit_signal("file_selected", path)


func _read_file(path):
	# Open and read file
	var file = File.new()
	file.open(path, file.READ)
	var json_result = JSON.parse(file.get_as_text())
	if json_result.error != OK:
		return null
	file.close()
	
	# Check validity
	var _gamelog = json_result.result
	if _gamelog == null:
		printerr("Invalid Game Log")
		set_title("Select a Valid Game Log")
	
	Global.valid_gamelog(_gamelog)


var default: Rect2
func popup(_rect: Rect2 = default):
	# If built for web, FileDialog won't work
	if Global.use_js:
		load_file()
	else:
		.popup()


func load_file():
	if not Global.use_js:
		return
	
	# Call our upload function
	JavaScript.eval("upload();", true)
	# Wait for prompt to close and for async data load 
	yield(self, "in_focus")
	while not (JavaScript.eval("done;", true)):
		yield(get_tree().create_timer(1), "timeout")
		# Check that upload wasn't canceled
		if JavaScript.eval("canceled;", true):
			return
			
	
	# Wait until full data has loaded
	var file_data: PoolByteArray
	while true:
		file_data = JavaScript.eval("fileData;", true)
		if file_data != null:
			break
		yield(get_tree().create_timer(1), "timeout")
	
	Global.emit_signal("verify_gamelog_start")
	
	yield(get_tree(), "idle_frame")
	
	# Optionally check file type
	#var file_type = JavaScript.eval("fileType;", true)
	
	var gamelog_file = JSON.parse(file_data.get_string_from_utf8())
	if gamelog_file.error != OK:
		return
	
	if gamelog_file.result == null:
		print("Invalid Game Log")
		Global.set_progress_text("Invalid Game Log")
		return
	
	Global.valid_gamelog(gamelog_file.result)
	


func _on_gamelog_valid():
	if !Global.gamelog: return
	emit_signal("gamelog_ready")



func _define_js():
	# Create global JS variables to store file upload state
	# Create input element to allow upload
	JavaScript.eval(
		"""
		var fileData;
		var fileType;
		var fileName;
		var canceled;
		var done;
		function upload(){
			fileData = null;
			fileType = null;
			fileName = null;
			canceled = false;
			done = false;
			var input = document.createElement('INPUT'); 
			input.setAttribute("type", "file");
			input.click();
			input.addEventListener('change', event => {
				if (event.target.files.length < 0){
					canceled = true;
				}
				var file = event.target.files[0];
				var reader = new FileReader();
				fileType = file.type;
				fileName = file.name;
				reader.readAsArrayBuffer(file);
				reader.onloadend = function (evt) {
					if (evt.target.readyState == FileReader.DONE) {
						fileData = evt.target.result;
						done = true;
					}
				}
			});
		}
		"""
	, true)


func _exit_tree():
	if thread.is_active():
		thread.wait_to_finish()
