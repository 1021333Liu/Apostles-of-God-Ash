class_name ProductShell
extends CanvasLayer

signal new_game_requested
signal continue_requested
signal resume_requested
signal return_to_title_requested
signal exit_requested
signal settings_changed(settings: Dictionary)

const TITLE_BACKGROUND_PATH: String = "res://assets/card_demo/backgrounds/bg_silent_casket_collector_intro.png"

enum Screen { CLOSED, TITLE, PAUSE, SETTINGS, CONFIRM }

var _screen: Screen = Screen.CLOSED
var _settings_origin: Screen = Screen.TITLE
var _confirm_origin: Screen = Screen.TITLE
var _confirm_action: String = ""
var _can_continue: bool = false
var _chapter_complete: bool = false
var _has_save: bool = false
var _focused_before_confirm: Control
var _settings: Dictionary = {
	"master_volume": 0.8,
	"sfx_volume": 0.85,
	"fullscreen": false
}
var _built: bool = false
var _audio_player: Variant
var _last_volume_preview_bucket: int = -1
var _last_sfx_preview_bucket: int = -1
var _silent_focus_target: Control

var _root: Control
var _title_background: TextureRect
var _backdrop: ColorRect
var _title_screen: Control
var _pause_screen: CenterContainer
var _settings_screen: CenterContainer
var _confirm_overlay: Control
var _continue_button: Button
var _new_game_button: Button
var _title_settings_button: Button
var _title_exit_button: Button
var _title_status_label: Label
var _resume_button: Button
var _pause_settings_button: Button
var _return_title_button: Button
var _pause_exit_button: Button
var _volume_slider: HSlider
var _volume_value_label: Label
var _sfx_slider: HSlider
var _sfx_value_label: Label
var _fullscreen_toggle: CheckButton
var _settings_status_label: Label
var _settings_back_button: Button
var _confirm_label: Label
var _confirm_cancel_button: Button
var _confirm_accept_button: Button


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	layer = 100
	_build_ui()
	hide_shell()


func _unhandled_input(event: InputEvent) -> void:
	if not is_open():
		return
	if event.is_action_pressed("pause_game") and is_pause_context():
		handle_pause_action()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("ui_cancel"):
		handle_back()
		get_viewport().set_input_as_handled()


func show_title(can_continue: bool, chapter_complete: bool = false, has_save: bool = false) -> void:
	_ensure_built()
	_can_continue = can_continue
	_chapter_complete = chapter_complete
	_has_save = has_save or can_continue or chapter_complete
	_screen = Screen.TITLE
	visible = true
	_root.mouse_filter = Control.MOUSE_FILTER_STOP
	_title_background.visible = true
	_backdrop.color = Color(0.018, 0.016, 0.014, 0.70)
	_show_only(_title_screen)
	_continue_button.disabled = not _can_continue
	_continue_button.text = "继续游戏" if _can_continue else "继续游戏（暂无存档）"
	_new_game_button.text = "重新开始章节" if _chapter_complete else "新游戏"
	_wire_vertical_focus(
		[_continue_button, _new_game_button, _title_settings_button, _title_exit_button]
		if _can_continue
		else [_new_game_button, _title_settings_button, _title_exit_button]
	)
	if _chapter_complete:
		_title_status_label.text = "第一章已完成。低语田野已归档。"
	elif _can_continue:
		_title_status_label.text = "将从最近的遭遇入口继续。"
	else:
		_title_status_label.text = "第一章 · 低语田野"
	_focus_later(_continue_button if _can_continue else _new_game_button)


func show_pause() -> void:
	_ensure_built()
	_screen = Screen.PAUSE
	visible = true
	_root.mouse_filter = Control.MOUSE_FILTER_STOP
	_title_background.visible = false
	_backdrop.color = Color(0.012, 0.011, 0.010, 0.84)
	_show_only(_pause_screen)
	_focus_later(_resume_button)


func hide_shell() -> void:
	_screen = Screen.CLOSED
	visible = false
	if _built:
		_root.mouse_filter = Control.MOUSE_FILTER_IGNORE


func is_open() -> bool:
	return _screen != Screen.CLOSED and visible


func is_title_open() -> bool:
	return _screen == Screen.TITLE and visible


func is_pause_context() -> bool:
	if _screen == Screen.PAUSE:
		return true
	if _screen == Screen.SETTINGS:
		return _settings_origin == Screen.PAUSE
	if _screen == Screen.CONFIRM:
		return _confirm_origin == Screen.PAUSE or (_confirm_origin == Screen.SETTINGS and _settings_origin == Screen.PAUSE)
	return false


func set_settings(settings: Dictionary) -> void:
	_settings = {
		"master_volume": clampf(float(settings.get("master_volume", 0.8)), 0.0, 1.0),
		"sfx_volume": clampf(float(settings.get("sfx_volume", 0.85)), 0.0, 1.0),
		"fullscreen": bool(settings.get("fullscreen", false))
	}
	if not _built:
		return
	_volume_slider.set_value_no_signal(float(_settings["master_volume"]) * 100.0)
	_sfx_slider.set_value_no_signal(float(_settings["sfx_volume"]) * 100.0)
	_fullscreen_toggle.set_pressed_no_signal(bool(_settings["fullscreen"]))
	_update_volume_value(float(_volume_slider.value))
	_update_sfx_value(float(_sfx_slider.value))
	_last_volume_preview_bucket = int(_volume_slider.value / 10.0)
	_last_sfx_preview_bucket = int(_sfx_slider.value / 10.0)


func set_audio_player(audio_player: Node) -> void:
	_audio_player = audio_player


func show_status(message: String) -> void:
	_ensure_built()
	_title_status_label.text = message


func show_settings_status(message: String, is_error: bool = false) -> void:
	_ensure_built()
	_settings_status_label.text = message
	_settings_status_label.add_theme_color_override(
		"font_color",
		Color(1.0, 0.54, 0.42, 1.0) if is_error else Color(0.62, 0.72, 0.54, 1.0)
	)


func handle_back() -> void:
	match _screen:
		Screen.CONFIRM:
			_play_ui_cue("ui_cancel")
			_close_confirmation()
		Screen.SETTINGS:
			_play_ui_cue("ui_cancel")
			_close_settings()
		Screen.PAUSE:
			_play_ui_cue("ui_cancel")
			resume_requested.emit()
		Screen.TITLE:
			_open_confirmation("exit", "退出《神烬使徒》？\n最近检查点之后的进度不会保留。", "退出游戏")
		_:
			pass


func handle_pause_action() -> void:
	if is_pause_context():
		handle_back()


func _ensure_built() -> void:
	if not _built:
		_build_ui()


func _build_ui() -> void:
	if _built:
		return
	_built = true

	_root = Control.new()
	_root.name = "ProductShellRoot"
	_root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_root.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(_root)

	_title_background = TextureRect.new()
	_title_background.name = "TitleBackground"
	_title_background.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_title_background.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	_title_background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_title_background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var background_resource := ResourceLoader.load(TITLE_BACKGROUND_PATH)
	if background_resource is Texture2D:
		_title_background.texture = background_resource as Texture2D
	_root.add_child(_title_background)

	_backdrop = ColorRect.new()
	_backdrop.name = "Backdrop"
	_backdrop.color = Color(0.018, 0.016, 0.014, 0.70)
	_backdrop.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_root.add_child(_backdrop)

	_build_title_screen()
	_build_pause_screen()
	_build_settings_screen()
	_build_confirmation_overlay()
	set_settings(_settings)


func _build_title_screen() -> void:
	_title_screen = Control.new()
	_title_screen.name = "TitleScreen"
	_title_screen.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_root.add_child(_title_screen)

	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 72)
	margin.add_theme_constant_override("margin_top", 46)
	margin.add_theme_constant_override("margin_right", 54)
	margin.add_theme_constant_override("margin_bottom", 46)
	_title_screen.add_child(margin)

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 36)
	margin.add_child(row)

	var column := VBoxContainer.new()
	column.custom_minimum_size = Vector2(440.0, 0.0)
	column.size_flags_vertical = Control.SIZE_EXPAND_FILL
	column.add_theme_constant_override("separation", 9)
	row.add_child(column)

	var top_spacer := Control.new()
	top_spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	column.add_child(top_spacer)

	var eyebrow := Label.new()
	eyebrow.text = "APOSTLES OF GOD-ASH"
	eyebrow.add_theme_font_size_override("font_size", 17)
	eyebrow.add_theme_color_override("font_color", Color(0.72, 0.64, 0.49, 1.0))
	column.add_child(eyebrow)

	var title := Label.new()
	title.text = "神烬使徒"
	title.add_theme_font_size_override("font_size", 46)
	title.add_theme_color_override("font_color", Color(0.96, 0.88, 0.68, 1.0))
	title.add_theme_color_override("font_outline_color", Color(0.02, 0.015, 0.012, 0.96))
	title.add_theme_constant_override("outline_size", 7)
	column.add_child(title)

	var subtitle := Label.new()
	subtitle.text = "一具无名空壳，替诸神收殓余烬。"
	subtitle.add_theme_font_size_override("font_size", 18)
	subtitle.add_theme_color_override("font_color", Color(0.84, 0.79, 0.68, 1.0))
	column.add_child(subtitle)

	var separator := HSeparator.new()
	separator.custom_minimum_size = Vector2(0.0, 20.0)
	column.add_child(separator)

	_continue_button = _new_menu_button("继续游戏")
	_new_game_button = _new_menu_button("新游戏", "")
	_title_settings_button = _new_menu_button("设置")
	_title_exit_button = _new_menu_button("退出游戏", "")
	for button: Button in [_continue_button, _new_game_button, _title_settings_button, _title_exit_button]:
		column.add_child(button)
	_wire_vertical_focus([_continue_button, _new_game_button, _title_settings_button, _title_exit_button])

	_title_status_label = Label.new()
	_title_status_label.custom_minimum_size = Vector2(0.0, 42.0)
	_title_status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_title_status_label.add_theme_font_size_override("font_size", 15)
	_title_status_label.add_theme_color_override("font_color", Color(0.71, 0.67, 0.59, 1.0))
	column.add_child(_title_status_label)

	var bottom_spacer := Control.new()
	bottom_spacer.custom_minimum_size = Vector2(0.0, 10.0)
	column.add_child(bottom_spacer)

	var side_spacer := Control.new()
	side_spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(side_spacer)

	_continue_button.pressed.connect(func() -> void: continue_requested.emit())
	_new_game_button.pressed.connect(_on_new_game_pressed)
	_title_settings_button.pressed.connect(func() -> void: _open_settings(Screen.TITLE))
	_title_exit_button.pressed.connect(func() -> void: _open_confirmation("exit", "退出《神烬使徒》？\n最近检查点之后的进度不会保留。", "退出游戏"))


func _build_pause_screen() -> void:
	_pause_screen = CenterContainer.new()
	_pause_screen.name = "PauseScreen"
	_pause_screen.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_root.add_child(_pause_screen)

	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(420.0, 0.0)
	panel.add_theme_stylebox_override("panel", _panel_style())
	_pause_screen.add_child(panel)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 34)
	margin.add_theme_constant_override("margin_top", 28)
	margin.add_theme_constant_override("margin_right", 34)
	margin.add_theme_constant_override("margin_bottom", 30)
	panel.add_child(margin)

	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 10)
	margin.add_child(column)

	var title := Label.new()
	title.text = "已暂停"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 30)
	title.add_theme_color_override("font_color", Color(0.95, 0.87, 0.68, 1.0))
	column.add_child(title)

	var chapter := Label.new()
	chapter.text = "第一章 · 低语田野"
	chapter.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	chapter.add_theme_font_size_override("font_size", 15)
	chapter.add_theme_color_override("font_color", Color(0.65, 0.61, 0.54, 1.0))
	column.add_child(chapter)

	var separator := HSeparator.new()
	separator.custom_minimum_size = Vector2(0.0, 18.0)
	column.add_child(separator)

	_resume_button = _new_menu_button("恢复游戏")
	_pause_settings_button = _new_menu_button("设置")
	_return_title_button = _new_menu_button("返回标题", "")
	_pause_exit_button = _new_menu_button("退出游戏", "")
	for button: Button in [_resume_button, _pause_settings_button, _return_title_button, _pause_exit_button]:
		column.add_child(button)
	_wire_vertical_focus([_resume_button, _pause_settings_button, _return_title_button, _pause_exit_button])

	_resume_button.pressed.connect(func() -> void: resume_requested.emit())
	_pause_settings_button.pressed.connect(func() -> void: _open_settings(Screen.PAUSE))
	_return_title_button.pressed.connect(func() -> void: _open_confirmation("title", "返回标题画面？\n当前遭遇将从入口检查点重新开始。", "返回标题"))
	_pause_exit_button.pressed.connect(func() -> void: _open_confirmation("exit", "退出《神烬使徒》？\n当前遭遇将从入口检查点重新开始。", "退出游戏"))


func _build_settings_screen() -> void:
	_settings_screen = CenterContainer.new()
	_settings_screen.name = "SettingsScreen"
	_settings_screen.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_root.add_child(_settings_screen)

	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(520.0, 0.0)
	panel.add_theme_stylebox_override("panel", _panel_style())
	_settings_screen.add_child(panel)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 36)
	margin.add_theme_constant_override("margin_top", 30)
	margin.add_theme_constant_override("margin_right", 36)
	margin.add_theme_constant_override("margin_bottom", 30)
	panel.add_child(margin)

	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 14)
	margin.add_child(column)

	var title := Label.new()
	title.text = "设置"
	title.add_theme_font_size_override("font_size", 30)
	title.add_theme_color_override("font_color", Color(0.95, 0.87, 0.68, 1.0))
	column.add_child(title)

	var separator := HSeparator.new()
	separator.custom_minimum_size = Vector2(0.0, 18.0)
	column.add_child(separator)

	var volume_row := HBoxContainer.new()
	volume_row.add_theme_constant_override("separation", 12)
	column.add_child(volume_row)

	var volume_label := Label.new()
	volume_label.text = "主音量"
	volume_label.custom_minimum_size = Vector2(92.0, 0.0)
	volume_label.add_theme_font_size_override("font_size", 18)
	volume_label.add_theme_color_override("font_color", Color(0.88, 0.82, 0.70, 1.0))
	volume_row.add_child(volume_label)

	_volume_slider = HSlider.new()
	_volume_slider.name = "MasterVolumeSlider"
	_volume_slider.min_value = 0.0
	_volume_slider.max_value = 100.0
	_volume_slider.step = 1.0
	_volume_slider.custom_minimum_size = Vector2(260.0, 44.0)
	_volume_slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_volume_slider.focus_mode = Control.FOCUS_ALL
	volume_row.add_child(_volume_slider)

	_volume_value_label = Label.new()
	_volume_value_label.custom_minimum_size = Vector2(54.0, 0.0)
	_volume_value_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_volume_value_label.add_theme_font_size_override("font_size", 17)
	_volume_value_label.add_theme_color_override("font_color", Color(0.78, 0.72, 0.61, 1.0))
	volume_row.add_child(_volume_value_label)

	var sfx_row := HBoxContainer.new()
	sfx_row.add_theme_constant_override("separation", 12)
	column.add_child(sfx_row)

	var sfx_label := Label.new()
	sfx_label.text = "音效音量"
	sfx_label.custom_minimum_size = Vector2(92.0, 0.0)
	sfx_label.add_theme_font_size_override("font_size", 18)
	sfx_label.add_theme_color_override("font_color", Color(0.88, 0.82, 0.70, 1.0))
	sfx_row.add_child(sfx_label)

	_sfx_slider = HSlider.new()
	_sfx_slider.name = "SfxVolumeSlider"
	_sfx_slider.min_value = 0.0
	_sfx_slider.max_value = 100.0
	_sfx_slider.step = 1.0
	_sfx_slider.custom_minimum_size = Vector2(260.0, 44.0)
	_sfx_slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_sfx_slider.focus_mode = Control.FOCUS_ALL
	sfx_row.add_child(_sfx_slider)

	_sfx_value_label = Label.new()
	_sfx_value_label.custom_minimum_size = Vector2(54.0, 0.0)
	_sfx_value_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_sfx_value_label.add_theme_font_size_override("font_size", 17)
	_sfx_value_label.add_theme_color_override("font_color", Color(0.78, 0.72, 0.61, 1.0))
	sfx_row.add_child(_sfx_value_label)

	_fullscreen_toggle = CheckButton.new()
	_fullscreen_toggle.name = "FullscreenToggle"
	_fullscreen_toggle.text = "全屏显示"
	_fullscreen_toggle.custom_minimum_size = Vector2(0.0, 48.0)
	_fullscreen_toggle.focus_mode = Control.FOCUS_ALL
	_fullscreen_toggle.add_theme_font_size_override("font_size", 18)
	column.add_child(_fullscreen_toggle)

	_settings_status_label = Label.new()
	_settings_status_label.text = "设置会自动保存。"
	_settings_status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_settings_status_label.add_theme_font_size_override("font_size", 14)
	_settings_status_label.add_theme_color_override("font_color", Color(0.62, 0.58, 0.51, 1.0))
	column.add_child(_settings_status_label)

	_settings_back_button = _new_menu_button("返回", "ui_cancel")
	column.add_child(_settings_back_button)
	_wire_vertical_focus([_volume_slider, _sfx_slider, _fullscreen_toggle, _settings_back_button])

	_volume_slider.value_changed.connect(_on_volume_changed)
	_sfx_slider.value_changed.connect(_on_sfx_volume_changed)
	_fullscreen_toggle.toggled.connect(_on_fullscreen_toggled)
	_settings_back_button.pressed.connect(_close_settings)
	for control: Control in [_volume_slider, _sfx_slider, _fullscreen_toggle]:
		control.focus_entered.connect(_on_control_focus_entered.bind(control))


func _build_confirmation_overlay() -> void:
	_confirm_overlay = Control.new()
	_confirm_overlay.name = "ConfirmationOverlay"
	_confirm_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_root.add_child(_confirm_overlay)

	var shade := ColorRect.new()
	shade.color = Color(0.0, 0.0, 0.0, 0.62)
	shade.mouse_filter = Control.MOUSE_FILTER_STOP
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_confirm_overlay.add_child(shade)

	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_confirm_overlay.add_child(center)

	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(470.0, 0.0)
	panel.add_theme_stylebox_override("panel", _panel_style(Color(0.075, 0.064, 0.052, 0.99)))
	center.add_child(panel)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 34)
	margin.add_theme_constant_override("margin_top", 28)
	margin.add_theme_constant_override("margin_right", 34)
	margin.add_theme_constant_override("margin_bottom", 28)
	panel.add_child(margin)

	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 18)
	margin.add_child(column)

	_confirm_label = Label.new()
	_confirm_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_confirm_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_confirm_label.add_theme_font_size_override("font_size", 19)
	_confirm_label.add_theme_color_override("font_color", Color(0.91, 0.85, 0.72, 1.0))
	column.add_child(_confirm_label)

	var buttons := HBoxContainer.new()
	buttons.alignment = BoxContainer.ALIGNMENT_CENTER
	buttons.add_theme_constant_override("separation", 12)
	column.add_child(buttons)

	_confirm_cancel_button = _new_menu_button("取消", "ui_cancel")
	_confirm_cancel_button.custom_minimum_size = Vector2(150.0, 50.0)
	_confirm_accept_button = _new_menu_button("确认")
	_confirm_accept_button.custom_minimum_size = Vector2(150.0, 50.0)
	buttons.add_child(_confirm_cancel_button)
	buttons.add_child(_confirm_accept_button)
	_confirm_cancel_button.focus_neighbor_left = _confirm_cancel_button.get_path_to(_confirm_accept_button)
	_confirm_cancel_button.focus_neighbor_right = _confirm_cancel_button.get_path_to(_confirm_accept_button)
	_confirm_cancel_button.focus_neighbor_top = _confirm_cancel_button.get_path_to(_confirm_accept_button)
	_confirm_cancel_button.focus_neighbor_bottom = _confirm_cancel_button.get_path_to(_confirm_accept_button)
	_confirm_cancel_button.focus_next = _confirm_cancel_button.get_path_to(_confirm_accept_button)
	_confirm_cancel_button.focus_previous = _confirm_cancel_button.get_path_to(_confirm_accept_button)
	_confirm_accept_button.focus_neighbor_left = _confirm_accept_button.get_path_to(_confirm_cancel_button)
	_confirm_accept_button.focus_neighbor_right = _confirm_accept_button.get_path_to(_confirm_cancel_button)
	_confirm_accept_button.focus_neighbor_top = _confirm_accept_button.get_path_to(_confirm_cancel_button)
	_confirm_accept_button.focus_neighbor_bottom = _confirm_accept_button.get_path_to(_confirm_cancel_button)
	_confirm_accept_button.focus_next = _confirm_accept_button.get_path_to(_confirm_cancel_button)
	_confirm_accept_button.focus_previous = _confirm_accept_button.get_path_to(_confirm_cancel_button)

	_confirm_cancel_button.pressed.connect(_close_confirmation)
	_confirm_accept_button.pressed.connect(_accept_confirmation)


func _new_menu_button(label_text: String, pressed_cue: String = "ui_confirm") -> Button:
	var button := Button.new()
	button.text = label_text
	button.custom_minimum_size = Vector2(0.0, 52.0)
	button.focus_mode = Control.FOCUS_ALL
	button.alignment = HORIZONTAL_ALIGNMENT_LEFT
	button.add_theme_font_size_override("font_size", 18)
	button.add_theme_color_override("font_color", Color(0.87, 0.81, 0.69, 1.0))
	button.add_theme_color_override("font_hover_color", Color(1.0, 0.91, 0.65, 1.0))
	button.add_theme_color_override("font_focus_color", Color(1.0, 0.91, 0.65, 1.0))
	button.add_theme_color_override("font_disabled_color", Color(0.42, 0.39, 0.34, 1.0))
	button.add_theme_stylebox_override("normal", _button_style(Color(0.055, 0.048, 0.041, 0.88), Color(0.30, 0.26, 0.20, 0.90)))
	button.add_theme_stylebox_override("hover", _button_style(Color(0.13, 0.105, 0.072, 0.96), Color(0.66, 0.52, 0.27, 1.0)))
	button.add_theme_stylebox_override("pressed", _button_style(Color(0.18, 0.13, 0.075, 1.0), Color(0.80, 0.62, 0.30, 1.0)))
	button.add_theme_stylebox_override("focus", _button_style(Color(0.11, 0.09, 0.064, 0.98), Color(0.86, 0.68, 0.34, 1.0), 2))
	button.add_theme_stylebox_override("disabled", _button_style(Color(0.035, 0.032, 0.029, 0.80), Color(0.16, 0.15, 0.13, 0.75)))
	button.focus_entered.connect(_on_control_focus_entered.bind(button))
	button.mouse_entered.connect(_play_ui_focus)
	if pressed_cue == "ui_cancel":
		button.pressed.connect(_play_ui_cancel)
	elif not pressed_cue.is_empty():
		button.pressed.connect(_play_ui_confirm)
	return button


func _button_style(fill: Color, border: Color, border_width: int = 1) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = fill
	style.border_color = border
	style.set_border_width_all(border_width)
	style.set_corner_radius_all(4)
	style.content_margin_left = 18.0
	style.content_margin_right = 18.0
	style.content_margin_top = 10.0
	style.content_margin_bottom = 10.0
	return style


func _panel_style(fill: Color = Color(0.055, 0.049, 0.043, 0.98)) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = fill
	style.border_color = Color(0.45, 0.36, 0.22, 0.92)
	style.set_border_width_all(1)
	style.set_corner_radius_all(6)
	return style


func _wire_vertical_focus(controls: Array) -> void:
	if controls.is_empty():
		return
	for i: int in range(controls.size()):
		var current: Control = controls[i]
		var previous: Control = controls[wrapi(i - 1, 0, controls.size())]
		var next: Control = controls[wrapi(i + 1, 0, controls.size())]
		current.focus_neighbor_top = current.get_path_to(previous)
		current.focus_neighbor_bottom = current.get_path_to(next)


func _show_only(screen: Control) -> void:
	_title_screen.visible = screen == _title_screen
	_pause_screen.visible = screen == _pause_screen
	_settings_screen.visible = screen == _settings_screen
	_confirm_overlay.visible = false


func _focus_later(control: Control) -> void:
	if control != null and not control.is_queued_for_deletion():
		call_deferred("_grab_focus_without_cue", control)


func _grab_focus_without_cue(control: Control) -> void:
	if control == null or not is_instance_valid(control) or control.is_queued_for_deletion():
		return
	_silent_focus_target = control
	control.grab_focus()
	if _silent_focus_target == control:
		_silent_focus_target = null


func _on_control_focus_entered(control: Control) -> void:
	if control == _silent_focus_target:
		_silent_focus_target = null
		return
	_play_ui_focus()


func _on_new_game_pressed() -> void:
	if _has_save:
		_open_confirmation("new_game", "开始新游戏将覆盖当前章节进度。\n确定要重新进入低语田野吗？", "开始新游戏")
		return
	_play_ui_confirm()
	new_game_requested.emit()


func _open_settings(origin: Screen) -> void:
	_settings_origin = origin
	_screen = Screen.SETTINGS
	_title_background.visible = origin == Screen.TITLE
	_backdrop.color = Color(0.018, 0.016, 0.014, 0.78) if origin == Screen.TITLE else Color(0.012, 0.011, 0.010, 0.84)
	_show_only(_settings_screen)
	_focus_later(_volume_slider)


func _close_settings() -> void:
	if _settings_origin == Screen.PAUSE:
		show_pause()
	else:
		show_title(_can_continue, _chapter_complete, _has_save)


func _open_confirmation(action: String, message: String, confirm_text: String) -> void:
	_play_ui_cue("ui_warning", -2.0)
	_focused_before_confirm = get_viewport().gui_get_focus_owner()
	_confirm_origin = _screen
	_confirm_action = action
	_screen = Screen.CONFIRM
	_confirm_label.text = message
	_confirm_accept_button.text = confirm_text
	_confirm_overlay.visible = true
	_focus_later(_confirm_cancel_button)


func _close_confirmation() -> void:
	_confirm_overlay.visible = false
	_screen = _confirm_origin
	if _focused_before_confirm != null and is_instance_valid(_focused_before_confirm) and _focused_before_confirm.visible and _focused_before_confirm.focus_mode != Control.FOCUS_NONE:
		_focus_later(_focused_before_confirm)
		_focused_before_confirm = null
		_confirm_action = ""
		return
	match _screen:
		Screen.TITLE:
			_focus_later(_continue_button if _can_continue else _new_game_button)
		Screen.PAUSE:
			_focus_later(_resume_button)
		Screen.SETTINGS:
			_focus_later(_settings_back_button)
		_:
			pass
	_focused_before_confirm = null
	_confirm_action = ""


func _accept_confirmation() -> void:
	var action := _confirm_action
	_confirm_action = ""
	_confirm_overlay.visible = false
	match action:
		"new_game":
			new_game_requested.emit()
		"title":
			return_to_title_requested.emit()
		"exit":
			exit_requested.emit()
		_:
			_close_confirmation()


func _on_volume_changed(value: float) -> void:
	_update_volume_value(value)
	_settings["master_volume"] = clampf(value / 100.0, 0.0, 1.0)
	settings_changed.emit(_settings.duplicate(true))
	var bucket := int(value / 10.0)
	if bucket != _last_volume_preview_bucket:
		_last_volume_preview_bucket = bucket
		_play_ui_focus()


func _update_volume_value(value: float) -> void:
	_volume_value_label.text = "%d%%" % int(round(value))


func _on_sfx_volume_changed(value: float) -> void:
	_update_sfx_value(value)
	_settings["sfx_volume"] = clampf(value / 100.0, 0.0, 1.0)
	settings_changed.emit(_settings.duplicate(true))
	var bucket := int(value / 10.0)
	if bucket != _last_sfx_preview_bucket:
		_last_sfx_preview_bucket = bucket
		_play_ui_focus()


func _update_sfx_value(value: float) -> void:
	_sfx_value_label.text = "%d%%" % int(round(value))


func _on_fullscreen_toggled(enabled: bool) -> void:
	_settings["fullscreen"] = enabled
	settings_changed.emit(_settings.duplicate(true))
	_play_ui_confirm()


func _play_ui_focus() -> void:
	_play_ui_cue("ui_focus", -4.0)


func _play_ui_confirm() -> void:
	_play_ui_cue("ui_confirm", -2.0)


func _play_ui_cancel() -> void:
	_play_ui_cue("ui_cancel")


func _play_ui_cue(cue: String, volume_db: float = 0.0) -> void:
	if _audio_player != null and is_instance_valid(_audio_player):
		_audio_player.call("play_ui_cue", cue, volume_db)
