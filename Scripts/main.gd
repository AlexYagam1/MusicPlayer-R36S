extends Control

@onready var tab_buttons = [
	$SuperiorMenu/TabButton_List,
	$SuperiorMenu/TabButton_Playlists,
	$SuperiorMenu/TabButton_Player
]
@onready var screens = [
	$TabContainer/Screen_List,
	$TabContainer/Screen_Playlists,
	$TabContainer/Screen_Player
]

var current_tab = 0
var focus_on_tabs = true   # true = foco nas abas, false = foco na tela atual

func _ready():
	# Desativa a navegação automática por setas entre os botões das abas
	for btn in tab_buttons:
		btn.focus_neighbor_left = NodePath()
		btn.focus_neighbor_right = NodePath()
		btn.focus_neighbor_top = NodePath()
		btn.focus_neighbor_bottom = NodePath()
		btn.focus_mode = Control.FOCUS_ALL

	update_tab_visibility()
	tab_buttons[0].grab_focus()
	focus_on_tabs = true

func _input(event):
	# Troca de abas com L1/R1
	if event.is_action_pressed("Left_Tab"):
		switch_tab(-1)
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("Right_Tab"):
		switch_tab(1)
		get_viewport().set_input_as_handled()

	# Bloqueia as setas quando o foco está nas abas
	if focus_on_tabs and (event.is_action_pressed("ui_up") or
						  event.is_action_pressed("ui_down") or
						  event.is_action_pressed("ui_left") or
						  event.is_action_pressed("ui_right")):
		get_viewport().set_input_as_handled()
		return

	# A: se foco nas abas → desce para a tela
	if event.is_action_pressed("ui_accept") and focus_on_tabs:
		focus_on_tabs = false
		var current_screen = screens[current_tab]
		if current_screen.has_method("on_enter_screen"):
			current_screen.on_enter_screen()
		get_viewport().set_input_as_handled()

	# B: se foco na tela → volta para as abas
	if event.is_action_pressed("ui_cancel") and not focus_on_tabs:
		focus_on_tabs = true
		var current_screen = screens[current_tab]
		if current_screen.has_method("on_exit_screen"):
			current_screen.on_exit_screen()
		tab_buttons[current_tab].grab_focus()
		get_viewport().set_input_as_handled()

func switch_tab(delta):
	var new_tab = current_tab + delta
	if new_tab < 0 or new_tab > 2:
		return
	current_tab = new_tab
	update_tab_visibility()

	if focus_on_tabs:
		tab_buttons[current_tab].grab_focus()
	else:
		# Se estava dentro de uma tela, ao trocar de aba, volta para as abas
		focus_on_tabs = true
		tab_buttons[current_tab].grab_focus()

func update_tab_visibility():
	# Mostra/esconde as telas
	for i in range(screens.size()):
		screens[i].visible = (i == current_tab)

	# Destaque visual da aba ativa
	for i in range(tab_buttons.size()):
		tab_buttons[i].modulate = Color(1, 1, 0) if i == current_tab else Color(1, 1, 1)
