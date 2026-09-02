extends Control

# Referências aos nós
@onready var tab_bar = $SuperiorMenu
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

var current_tab = 0  # 0=Lista, 1=Playlists, 2=Player
var focus_on_tabs = true  # true quando o foco está nos botões de aba, false quando está no conteúdo da tela

func _ready():
	# Configurar inicial
	update_tab_visibility()
	# Dar foco ao primeiro botão da tab bar
	tab_buttons[0].grab_focus()
	focus_on_tabs = true

func _input(event):
	# Navegação com L1/R1 (Left_Tab / Right_Tab)
	if event.is_action_pressed("Left_Tab"):
		# Só muda se estiver com foco nas abas, mas pode mudar sempre
		# Vamos permitir mudar a aba mesmo se estiver no conteúdo, mas sem perder o foco? 
		# Melhor: se estiver no conteúdo, ao mudar a aba, o foco volta para as abas.
		# Vamos implementar isso.
		switch_tab(-1)
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("Right_Tab"):
		switch_tab(1)
		get_viewport().set_input_as_handled()
	
	# Botão A (ui_accept): se foco nas abas, desce para o conteúdo da tela atual
	if event.is_action_pressed("ui_accept") and focus_on_tabs:
		# Move o foco para o primeiro elemento da tela atual (se houver)
		# Por enquanto, apenas mudamos o estado do foco para o conteúdo
		focus_on_tabs = false
		# Aqui podemos dar foco a algum nó dentro da tela, mas como ainda não temos,
		# vamos apenas liberar o foco para não ficar em nenhum botão.
		# Opcional: podemos desabilitar o foco dos botões?
		# Vamos colocar o foco em um nó dummy dentro da tela, ou simplesmente
		# perder o foco. Mas por enquanto, vamos apenas mostrar uma mensagem.
		print("Entrou na tela ", current_tab)
		get_viewport().set_input_as_handled()
	
	# Botão B (ui_cancel): se estiver no conteúdo, volta para as abas
	if event.is_action_pressed("ui_cancel") and not focus_on_tabs:
		focus_on_tabs = true
		tab_buttons[current_tab].grab_focus()
		print("Voltou para as abas")
		get_viewport().set_input_as_handled()

func switch_tab(delta):
	var new_tab = current_tab + delta
	if new_tab < 0 or new_tab > 2:
		return  # não wrappamos? Pode wrappar se quiser
	current_tab = new_tab
	update_tab_visibility()
	# Se o foco estiver nas abas, atualiza o botão focado
	if focus_on_tabs:
		tab_buttons[current_tab].grab_focus()
	else:
		# Se estiver no conteúdo, ao mudar de aba, forçamos o foco voltar para as abas
		focus_on_tabs = true
		tab_buttons[current_tab].grab_focus()

func update_tab_visibility():
	# Esconde todas as telas, mostra apenas a atual
	for i in range(screens.size()):
		screens[i].visible = (i == current_tab)
	# Atualiza o estilo dos botões (opcional)
	for i in range(tab_buttons.size()):
		tab_buttons[i].disabled = (i == current_tab)  # desabilita o botão ativo para não clicar nele?
		# Ou usa pressed? Melhor usar um tema diferente.
