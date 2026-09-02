extends Control

@onready var scroll_container = $ScrollList
@onready var music_list = $ScrollList/MusicList

var active = false                 # true quando a tela está em foco
var music_paths = []               # lista de caminhos completos
var selected_index = -1            # índice do item selecionado

func _ready():
	scan_music_folder()
	populate_music_list()
	if music_paths.size() > 0:
		selected_index = 0
		update_selection()

# ---------- SCANNER ----------
func scan_music_folder():
	var folder_path = "res://Musics"
	var dir = DirAccess.open(folder_path)
	if not dir:
		var exe_dir = OS.get_executable_path().get_base_dir()
		folder_path = exe_dir + "/Musics"
		dir = DirAccess.open(folder_path)
		if not dir:
			folder_path = "user://Musics"
			dir = DirAccess.open(folder_path)
	if not dir:
		print("❌ Pasta de músicas não encontrada.")
		return

	music_paths.clear()
	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "":
		if not dir.current_is_dir() and _is_audio_file(file_name):
			music_paths.append(folder_path + "/" + file_name)
		file_name = dir.get_next()
	dir.list_dir_end()
	music_paths.sort()
	print("✅ ", music_paths.size(), " músicas encontradas.")

func _is_audio_file(filename: String) -> bool:
	var ext = filename.get_extension().to_lower()
	return ext in ["mp3", "ogg", "wav", "flac"]

# ---------- POPULAÇÃO ----------
func populate_music_list():
	for child in music_list.get_children():
		child.queue_free()

	if music_paths.size() == 0:
		var label = Label.new()
		label.text = "Nenhuma música encontrada.\nColoque arquivos na pasta 'Musics'."
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		music_list.add_child(label)
		return

	for path in music_paths:
		var display_name = path.get_file().get_basename()
		var btn = Button.new()
		btn.text = display_name
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		btn.custom_minimum_size = Vector2(0, 30)
		btn.set_meta("music_path", path)
		# Desativa o foco automático – controlamos tudo manualmente
		btn.focus_mode = Control.FOCUS_NONE
		music_list.add_child(btn)

	if music_paths.size() > 0:
		selected_index = 0
		update_selection()

# ---------- NAVEGAÇÃO ----------
func update_selection():
	for i in range(music_list.get_child_count()):
		var child = music_list.get_child(i)
		if child is Button:
			child.modulate = Color(1, 1, 0) if i == selected_index else Color(1, 1, 1)

func navigate(delta: int):
	if music_paths.size() == 0:
		return
	var new_index = selected_index + delta
	# Wrap‑around
	if new_index < 0:
		new_index = music_paths.size() - 1
	elif new_index >= music_paths.size():
		new_index = 0
	selected_index = new_index
	update_selection()
	_ensure_selected_visible()

func _ensure_selected_visible():
	if music_list.get_child_count() == 0:
		return
	var selected_button = music_list.get_child(selected_index)
	if selected_button:
		var vp_height = scroll_container.size.y
		var btn_pos = selected_button.position.y
		var btn_height = selected_button.size.y
		var current_scroll = scroll_container.scroll_vertical
		if btn_pos < current_scroll:
			scroll_container.scroll_vertical = btn_pos
		elif btn_pos + btn_height > current_scroll + vp_height:
			scroll_container.scroll_vertical = btn_pos + btn_height - vp_height

# ---------- INPUT (só ativo quando active == true) ----------
func _input(event):
	if not active:
		return

	# Navegação com setas
	if event.is_action_pressed("ui_down"):
		navigate(1)
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("ui_up"):
		navigate(-1)
		get_viewport().set_input_as_handled()

	# Seleção com A (ui_accept)
	if event.is_action_pressed("ui_accept"):
		if selected_index >= 0 and selected_index < music_paths.size():
			var path = music_paths[selected_index]
			print("🎵 Selecionada: ", path)
			# Aqui você chamará a reprodução e/ou mudará para a tela Player
		get_viewport().set_input_as_handled()

# ---------- CHAMADOS PELO MAIN ----------
func on_enter_screen():
	active = true
	update_selection()
	_ensure_selected_visible()

func on_exit_screen():
	active = false
