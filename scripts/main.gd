extends Node3D

enum GameMode { MENU, BIRTHDAY, CHALLENGE }

const BIRTHDAY_CANDLES: int = 8
const CHALLENGE_CANDLES: int = 25
const CHALLENGE_SECONDS: float = 10.0
const CALIBRATION_SECONDS: float = 0.85

const SFX_HOVER: AudioStream = preload("res://assets/audio/ui_hover.wav")
const SFX_CONFIRM: AudioStream = preload("res://assets/audio/ui_confirm.wav")
const SFX_EXTINGUISH: AudioStream = preload("res://assets/audio/extinguish.wav")
const SFX_SUCCESS: AudioStream = preload("res://assets/audio/success.wav")
const SFX_COUNT: AudioStream = preload("res://assets/audio/count.wav")
const SFX_WHOOSH: AudioStream = preload("res://assets/audio/whoosh.wav")
const SFX_APPLAUSE: AudioStream = preload("res://assets/audio/applause.wav")
const SFX_CHEER: AudioStream = preload("res://assets/audio/cheer.wav")
const SFX_BITE: AudioStream = preload("res://assets/audio/bite.wav")
const SFX_PLATE: AudioStream = preload("res://assets/audio/plate.wav")
const BGM_AMBIENCE: AudioStream = preload("res://assets/audio/melancholy.wav")
const CUSTOM_AUDIO_DIR: String = "res://assets/audio/custom"

var custom_title_bgm: AudioStream
var custom_menu_bgm: AudioStream
var custom_candle_out: AudioStream
var custom_applause: AudioStream
var custom_eat: AudioStream

var mode: GameMode = GameMode.MENU
var world_root: Node3D
var camera: Camera3D
var cake_root: Node3D
var candle_root: Node3D
var banner_name: Label3D
var candles: Array[Dictionary] = []
var party_people: Array[Dictionary] = []

var ui_layer: CanvasLayer
var menu_root: Control
var hud_root: Control
var result_root: Control
var name_edit: LineEdit
var sensitivity_slider: HSlider
var sensitivity_value_label: Label
var center_message: Label
var mode_label: Label
var timer_label: Label
var score_label: Label
var mic_label: Label
var mic_meter: ProgressBar
var analysis_label: Label
var result_title: Label
var result_subtitle: Label

var mic_player: AudioStreamPlayer
var capture: AudioEffectCapture
var mic_rms: float = 0.0
var mic_zcr: float = 0.0
var mic_roughness: float = 0.0
var mic_periodicity: float = 0.0
var mic_noise_floor: float = 0.004
var mic_threshold: float = 0.018
var calibration_left: float = CALIBRATION_SECONDS
var blow_strength: float = 0.0
var blow_smoothed: float = 0.0
var was_blowing: bool = false
var test_blow_left: float = 0.0

var challenge_countdown: float = 0.0
var challenge_time_left: float = 0.0
var challenge_active: bool = false
var challenge_score: int = 0
var last_count_second: int = -1
var finished: bool = false
var birthday_name: String = "YOU"
var celebrating: bool = false

var elapsed: float = 0.0
var camera_home: Vector3 = Vector3.ZERO


var ui_font: SystemFont
var ui_theme: Theme
var bgm_player: AudioStreamPlayer
var title_bgm_player: AudioStreamPlayer
var menu_bgm_player: AudioStreamPlayer
var fade_layer: ColorRect
var intro_root: Control
var intro_title: Label
var intro_subtitle: Label
var intro_skip_button: Button
var title_intro_finished: bool = false
var ending_in_progress: bool = false
var horror_shadow: Node3D
var horror_overlay: ColorRect
var horror_timer: float = 14.0
var horror_shadow_left: float = 0.0
var horror_flicker_left: float = 0.0

var settings_root: Control
var settings_title: Label
var settings_language_label: Label
var language_option: OptionButton
var settings_mic_title: Label
var settings_mic_device_label: Label
var mic_device_option: OptionButton
var settings_refresh_devices_button: Button
var settings_sensitivity_label: Label
var settings_auto_button: Button
var settings_test_button: Button
var settings_mic_status: Label
var settings_mic_meter: ProgressBar
var settings_close_button: Button
var settings_display_title: Label
var fullscreen_toggle: CheckButton
var menu_title_label: Label
var menu_subtitle_label: Label
var birthday_button_ref: Button
var challenge_button_ref: Button
var settings_button_ref: Button
var back_button_ref: Button
var replay_button_ref: Button
var result_menu_button_ref: Button
var eat_done_button: Button
var eat_hint_label: Label
var eat_controls_panel: PanelContainer
var eat_controls_label: Label
var eat_mouth_zone: PanelContainer
var eat_mouth_label: Label
var banner_title: Label3D
var party_phrase_labels: Array[Label3D] = []

var current_language: String = "en"
var saved_sensitivity: float = 0.90
var saved_input_device: String = "Default"
var saved_fullscreen: bool = true
var mic_test_active: bool = false
var mic_test_success_time: float = 0.0

var eating_mode: bool = false
var cake_piece_areas: Array[Area3D] = []
var held_piece: Area3D
var eat_cooldown: float = 0.0
var pieces_eaten: int = 0

const TRANSLATIONS: Dictionary = {
	"ja": {
		"banner": "お誕生日おめでとう",
		"subtitle": "ひとりの夜でも、ここではちゃんと祝うよ。",
		"intro_subtitle": "A little birthday, just for you.",
		"skip_intro": "スキップ",
		"wish_prompt": "お願いごと、した？",
		"congrats_soft": "……おめでとう。",
		"cake_soft": "ケーキも食べて。",
		"ending_thanks": "今日は来てくれてありがとう。",
		"ending_next": "また来年。",
		"name_placeholder": "名前",
		"birthday": "誕生日を祝う",
		"challenge": "ろうそくチャレンジ",
		"settings": "設定",
		"language": "言語",
		"microphone": "マイク",
		"input_device": "入力マイク",
		"refresh_devices": "マイク一覧を更新",
		"display": "表示",
		"fullscreen": "フルスクリーン",
		"device_ready": "選択中: %s",
		"device_failed": "このマイクを開始できなかったみたい",
		"sensitivity": "感度",
		"auto_adjust": "自動調整",
		"mic_test": "マイクをテスト",
		"close": "閉じる",
		"back": "← メニュー",
		"replay": "もう一度",
		"menu": "メニュー",
		"calibrating": "周りの音を測ってる…少しだけ静かにしてね",
		"listening": "息を待ってる",
		"breath": "息を検出したよ。そのままゆっくり",
		"voice": "声みたい。叫ぶより、フーッと吹いてみて",
		"almost": "もう少しだけマイクに近づいて",
		"no_mic": "マイクの音が届いてないみたい",
		"make_wish": "%s、お願いごとをして。\nみんな待ってるよ。",
		"keep_blowing": "そのまま…あと %d 本",
		"challenge_ready": "少し近づいて、息を整えて",
		"challenge_go": "吹いて",
		"challenge_mode": "ろうそくチャレンジ",
		"birthday_mode": "誕生日",
		"cake_intro": "消えたね。\n今度は、ケーキを食べよう。",
		"cake_hint": "ケーキを食べよう",
		"cake_controls": "① ケーキの上で左クリックを押しっぱなしにする\n② 押したまま画面下中央へドラッグ\n③ 『ここまで運ぶ』で少し待つと一口食べる\n※つかめるとケーキが少し浮く。途中で離すと皿に戻る",
		"mouth_here": "ここまで運ぶ",
		"cake_done": "ごちそうさま",
		"bite": "おいしい？",
		"all_eaten": "全部食べたね。",
		"birthday_result": "%sへ",
		"birthday_result_sub": "今日は来てくれてありがとう。\nまた来年も、ここで祝えたらいいね。",
		"challenge_result": "%d / %d",
		"rank_perfect": "全部消えた。",
		"rank_high": "かなり遠くまで息が届いた。",
		"rank_mid": "いい感じ。もう少し。",
		"rank_low": "小さな風だった。",
		"mic_test_wait": "フーッと息を吹いてみて",
		"mic_test_ok": "ちゃんと息を検出できたよ",
		"auto_done": "環境音を測り直してるよ",
		"party_1": "おめでとう",
		"party_2": "お願いごと、した？",
		"party_3": "今日はここにいていいよ",
		"party_4": "ゆっくりで大丈夫",
		"party_5": "ちゃんと見てるよ"
	},
	"en": {
		"banner": "HAPPY BIRTHDAY",
		"subtitle": "Even on a quiet night, we'll still celebrate you.",
		"intro_subtitle": "A little birthday, just for you.",
		"skip_intro": "Skip",
		"wish_prompt": "Did you make a wish?",
		"congrats_soft": "…Happy birthday.",
		"cake_soft": "Have some cake, too.",
		"ending_thanks": "Thanks for coming tonight.",
		"ending_next": "See you next year.",
		"name_placeholder": "Your name",
		"birthday": "Celebrate my birthday",
		"challenge": "Candle challenge",
		"settings": "Settings",
		"language": "Language",
		"microphone": "Microphone",
		"input_device": "Input microphone",
		"refresh_devices": "Refresh microphones",
		"display": "Display",
		"fullscreen": "Fullscreen",
		"device_ready": "Selected: %s",
		"device_failed": "Could not start this microphone",
		"sensitivity": "Sensitivity",
		"auto_adjust": "Auto adjust",
		"mic_test": "Test microphone",
		"close": "Close",
		"back": "← Menu",
		"replay": "Again",
		"menu": "Menu",
		"calibrating": "Listening to the room… stay quiet for a moment",
		"listening": "Waiting for your breath",
		"breath": "I can hear your breath. Keep it gentle.",
		"voice": "That sounds like a voice. Try a steady breath instead.",
		"almost": "A little closer to the microphone",
		"no_mic": "No microphone signal is reaching the game",
		"make_wish": "%s, make a wish.\nEveryone's waiting.",
		"keep_blowing": "Keep going… %d left",
		"challenge_ready": "Come a little closer and take a breath",
		"challenge_go": "Blow",
		"challenge_mode": "Candle challenge",
		"birthday_mode": "Birthday",
		"cake_intro": "They're all out.\nNow let's have some cake.",
		"cake_hint": "Let's have some cake",
		"cake_controls": "1. Press and HOLD left-click directly over the cake\n2. Keep holding and drag toward the bottom center\n3. Wait over 'Bring it here' to take a bite\nThe cake lifts when grabbed; release early to put it back",
		"mouth_here": "Bring it here",
		"cake_done": "I'm full",
		"bite": "Is it good?",
		"all_eaten": "You ate it all.",
		"birthday_result": "For %s",
		"birthday_result_sub": "Thanks for coming tonight.\nMaybe we can celebrate here again next year.",
		"challenge_result": "%d / %d",
		"rank_perfect": "Every candle went out.",
		"rank_high": "Your breath reached almost all the way across.",
		"rank_mid": "That was close. One more try.",
		"rank_low": "A small, gentle breeze.",
		"mic_test_wait": "Blow gently toward the microphone",
		"mic_test_ok": "Your breath was detected",
		"auto_done": "Recalibrating to the room",
		"party_1": "Happy birthday",
		"party_2": "Did you make a wish?",
		"party_3": "You can stay here tonight",
		"party_4": "Take your time",
		"party_5": "We're watching"
	},
	"zh": {
		"banner": "生日快乐",
		"subtitle": "就算今晚很安静，这里也会认真为你庆祝。",
		"intro_subtitle": "A little birthday, just for you.",
		"skip_intro": "跳过",
		"wish_prompt": "许好愿了吗？",
		"congrats_soft": "……生日快乐。",
		"cake_soft": "也吃点蛋糕吧。",
		"ending_thanks": "谢谢你今晚来到这里。",
		"ending_next": "明年再见。",
		"name_placeholder": "你的名字",
		"birthday": "庆祝生日",
		"challenge": "蜡烛挑战",
		"settings": "设置",
		"language": "语言",
		"microphone": "麦克风",
		"input_device": "输入麦克风",
		"refresh_devices": "刷新麦克风列表",
		"display": "显示",
		"fullscreen": "全屏",
		"device_ready": "已选择：%s",
		"device_failed": "无法启动这个麦克风",
		"sensitivity": "灵敏度",
		"auto_adjust": "自动调整",
		"mic_test": "测试麦克风",
		"close": "关闭",
		"back": "← 菜单",
		"replay": "再来一次",
		"menu": "菜单",
		"calibrating": "正在听环境声音……请安静一下",
		"listening": "正在等你的呼吸",
		"breath": "检测到呼吸了，继续轻轻吹",
		"voice": "听起来像说话声。试着慢慢吹气",
		"almost": "再靠近麦克风一点",
		"no_mic": "没有收到麦克风声音",
		"make_wish": "%s，许个愿吧。\n大家都在等你。",
		"keep_blowing": "继续……还剩 %d 根",
		"challenge_ready": "靠近一点，准备好呼吸",
		"challenge_go": "吹吧",
		"challenge_mode": "蜡烛挑战",
		"birthday_mode": "生日",
		"cake_intro": "都熄灭了。\n现在来吃蛋糕吧。",
		"cake_hint": "来吃蛋糕吧",
		"cake_controls": "① 在蛋糕上按住鼠标左键不要松开\n② 保持按住并拖到画面下方中央\n③ 在“拖到这里”停一下就会吃一口\n抓住后蛋糕会浮起来；中途松开会放回盘子",
		"mouth_here": "拖到这里",
		"cake_done": "我吃饱了",
		"bite": "好吃吗？",
		"all_eaten": "全都吃完了。",
		"birthday_result": "给 %s",
		"birthday_result_sub": "谢谢你今晚来到这里。\n希望明年还能在这里为你庆祝。",
		"challenge_result": "%d / %d",
		"rank_perfect": "全部熄灭了。",
		"rank_high": "你的气息吹到了很远。",
		"rank_mid": "很接近了，再试一次。",
		"rank_low": "是一阵很轻的风。",
		"mic_test_wait": "对着麦克风轻轻吹气",
		"mic_test_ok": "已经检测到你的呼吸",
		"auto_done": "正在重新测量环境声音",
		"party_1": "生日快乐",
		"party_2": "许愿了吗？",
		"party_3": "今晚可以待在这里",
		"party_4": "慢慢来就好",
		"party_5": "我们都在看着你"
	},
	"ko": {
		"banner": "생일 축하해",
		"subtitle": "조용한 밤이어도, 여기서는 제대로 축하해 줄게.",
		"intro_subtitle": "A little birthday, just for you.",
		"skip_intro": "건너뛰기",
		"wish_prompt": "소원은 빌었어?",
		"congrats_soft": "……생일 축하해.",
		"cake_soft": "케이크도 먹어.",
		"ending_thanks": "오늘 와 줘서 고마워.",
		"ending_next": "내년에 또 보자.",
		"name_placeholder": "이름",
		"birthday": "생일 축하받기",
		"challenge": "촛불 챌린지",
		"settings": "설정",
		"language": "언어",
		"microphone": "마이크",
		"input_device": "입력 마이크",
		"refresh_devices": "마이크 목록 새로고침",
		"display": "화면",
		"fullscreen": "전체 화면",
		"device_ready": "선택됨: %s",
		"device_failed": "이 마이크를 시작하지 못했어",
		"sensitivity": "감도",
		"auto_adjust": "자동 조정",
		"mic_test": "마이크 테스트",
		"close": "닫기",
		"back": "← 메뉴",
		"replay": "다시",
		"menu": "메뉴",
		"calibrating": "주변 소리를 듣는 중… 잠깐만 조용히 있어 줘",
		"listening": "숨을 기다리는 중",
		"breath": "숨을 감지했어. 그대로 천천히",
		"voice": "목소리 같아. 소리치지 말고 후- 하고 불어 봐",
		"almost": "마이크에 조금만 더 가까이",
		"no_mic": "마이크 소리가 들어오지 않아",
		"make_wish": "%s, 소원을 빌어.\n모두 기다리고 있어.",
		"keep_blowing": "그대로… %d개 남았어",
		"challenge_ready": "조금 가까이 와서 숨을 고르고",
		"challenge_go": "불어",
		"challenge_mode": "촛불 챌린지",
		"birthday_mode": "생일",
		"cake_intro": "다 꺼졌네.\n이제 케이크를 먹자.",
		"cake_hint": "케이크를 먹자",
		"cake_controls": "① 케이크 위에서 왼쪽 클릭을 계속 누르기\n② 누른 채 화면 아래 중앙으로 드래그\n③ '여기까지 가져오기'에서 잠깐 기다리면 한입 먹기\n잡히면 케이크가 살짝 뜨고, 중간에 놓으면 접시로 돌아가",
		"mouth_here": "여기까지 가져오기",
		"cake_done": "잘 먹었습니다",
		"bite": "맛있어?",
		"all_eaten": "다 먹었네.",
		"birthday_result": "%s에게",
		"birthday_result_sub": "오늘 와 줘서 고마워.\n내년에도 여기서 축하할 수 있으면 좋겠다.",
		"challenge_result": "%d / %d",
		"rank_perfect": "전부 꺼졌어.",
		"rank_high": "숨이 꽤 멀리까지 닿았어.",
		"rank_mid": "거의 다 왔어. 한 번 더.",
		"rank_low": "작고 조용한 바람이었어.",
		"mic_test_wait": "마이크 쪽으로 후- 하고 불어 봐",
		"mic_test_ok": "숨을 제대로 감지했어",
		"auto_done": "주변 소리를 다시 측정하는 중",
		"party_1": "생일 축하해",
		"party_2": "소원 빌었어?",
		"party_3": "오늘은 여기 있어도 돼",
		"party_4": "천천히 해도 괜찮아",
		"party_5": "우리가 보고 있어"
	}
}

func _ready() -> void:
	randomize()
	ui_font = _create_system_font()
	ui_theme = Theme.new()
	ui_theme.default_font = ui_font
	_load_settings()
	_load_custom_audio()
	_build_world()
	_build_ui()
	_apply_window_mode()
	_setup_microphone()
	_setup_music_players()
	_apply_language()
	_show_title_intro()

func _process(delta: float) -> void:
	elapsed += delta
	_update_microphone(delta)
	_update_candles(delta)
	_update_party_people(delta)
	_update_challenge(delta)
	_update_camera(delta)
	_update_eating(delta)
	_update_mic_test(delta)
	_update_horror(delta)

	if eat_cooldown > 0.0:
		eat_cooldown -= delta

	if mode != GameMode.MENU and Input.is_action_just_pressed("ui_cancel") and not eating_mode:
		_show_menu()

func _input(event: InputEvent) -> void:
	var mouse_event: InputEventMouseButton = event as InputEventMouseButton
	if mouse_event != null and eating_mode and mouse_event.button_index == MOUSE_BUTTON_LEFT:
		if mouse_event.pressed:
			_pick_cake_piece(mouse_event.position)
		else:
			_release_held_piece()
		get_viewport().set_input_as_handled()
		return

	var key_event: InputEventKey = event as InputEventKey
	if key_event == null:
		return
	if key_event.pressed and not key_event.echo and key_event.keycode == KEY_SPACE:
		if mode != GameMode.MENU and not finished:
			test_blow_left = 0.95
			_play_sound(SFX_WHOOSH, -18.0)

func _create_system_font() -> SystemFont:
	var font: SystemFont = SystemFont.new()
	font.font_names = PackedStringArray([
		"Hiragino Sans",
		"Yu Gothic",
		"Meiryo",
		"Noto Sans CJK JP",
		"Noto Sans CJK SC",
		"Apple SD Gothic Neo",
		"Arial Unicode MS",
		"Arial"
	])
	font.font_weight = 400
	return font

func _t(key: String) -> String:
	var lang_key: String = current_language if TRANSLATIONS.has(current_language) else "en"
	var lang_dict: Dictionary = TRANSLATIONS[lang_key]
	return String(lang_dict.get(key, key))

func _load_settings() -> void:
	var config: ConfigFile = ConfigFile.new()
	var err: Error = config.load("user://settings.cfg")
	if err == OK:
		current_language = String(config.get_value("general", "language", ""))
		saved_sensitivity = float(config.get_value("microphone", "sensitivity", 0.90))
		saved_input_device = String(config.get_value("microphone", "device", "Default"))
		# This version migrates the old small-window default to fullscreen.
		saved_fullscreen = true

	if current_language.is_empty():
		var locale: String = OS.get_locale_language().to_lower()
		if locale.begins_with("ja"):
			current_language = "ja"
		elif locale.begins_with("zh"):
			current_language = "zh"
		elif locale.begins_with("ko"):
			current_language = "ko"
		else:
			current_language = "en"

	if not TRANSLATIONS.has(current_language):
		current_language = "en"

func _save_settings() -> void:
	var config: ConfigFile = ConfigFile.new()
	config.set_value("general", "language", current_language)
	var sensitivity_value: float = saved_sensitivity
	if sensitivity_slider != null:
		sensitivity_value = float(sensitivity_slider.value)
	config.set_value("microphone", "sensitivity", sensitivity_value)
	config.set_value("microphone", "device", saved_input_device)
	config.set_value("display", "fullscreen", saved_fullscreen)
	config.save("user://settings.cfg")

func _load_first_audio(base_name: String) -> AudioStream:
	var candidates: Array[String] = [
		CUSTOM_AUDIO_DIR + "/" + base_name + ".mp3",
		CUSTOM_AUDIO_DIR + "/" + base_name + ".wav",
		CUSTOM_AUDIO_DIR + "/" + base_name + ".ogg"
	]
	for path in candidates:
		if ResourceLoader.exists(path):
			var resource: Resource = ResourceLoader.load(path)
			var stream: AudioStream = resource as AudioStream
			if stream != null:
				return stream
	return null

func _load_custom_audio() -> void:
	custom_title_bgm = _load_first_audio("title")
	# Title and menu intentionally share the same track.
	# Keeping one stream/player prevents the BGM from restarting or overlapping.
	custom_menu_bgm = custom_title_bgm
	custom_candle_out = _load_first_audio("candle_out")
	custom_applause = _load_first_audio("applause")
	custom_eat = _load_first_audio("eat")

func _setup_music_players() -> void:
	# One front-end player is shared by the title intro and the main menu.
	title_bgm_player = AudioStreamPlayer.new()
	title_bgm_player.volume_db = -80.0
	add_child(title_bgm_player)

	# Kept as null for compatibility with older code; no second menu track is played.
	menu_bgm_player = null

	bgm_player = AudioStreamPlayer.new()
	bgm_player.stream = BGM_AMBIENCE
	bgm_player.volume_db = -28.0
	add_child(bgm_player)

func _fade_player(player: AudioStreamPlayer, target_db: float, duration: float, stop_after: bool = false) -> void:
	if player == null:
		return
	var tween: Tween = create_tween()
	tween.tween_property(player, "volume_db", target_db, duration)
	if stop_after:
		tween.finished.connect(player.stop)

func _play_title_music() -> void:
	if title_bgm_player == null:
		return
	title_bgm_player.stream = custom_title_bgm if custom_title_bgm != null else BGM_AMBIENCE
	if not title_bgm_player.playing:
		title_bgm_player.volume_db = -34.0
		title_bgm_player.play()
	_fade_player(title_bgm_player, -13.0, 1.8)

func _play_menu_music() -> void:
	if title_bgm_player == null:
		return

	# Do not restart the song when the title fades into the menu.
	# It simply continues from the current playback position.
	if not title_bgm_player.playing:
		title_bgm_player.stream = custom_title_bgm if custom_title_bgm != null else BGM_AMBIENCE
		title_bgm_player.volume_db = -34.0
		title_bgm_player.play()

	_fade_player(title_bgm_player, -15.0, 0.9)

func _transition_to_game_audio() -> void:
	if title_bgm_player != null and title_bgm_player.playing:
		_fade_player(title_bgm_player, -80.0, 1.3, true)
	if bgm_player != null:
		bgm_player.volume_db = -80.0
		if not bgm_player.playing:
			bgm_player.play()
		_fade_player(bgm_player, -28.0, 1.6)

func _soften_game_music_for_candles() -> void:
	if bgm_player != null and bgm_player.playing:
		_fade_player(bgm_player, -36.0, 1.2)

func _restore_game_music() -> void:
	if bgm_player != null and bgm_player.playing:
		_fade_player(bgm_player, -27.0, 1.0)

func _apply_window_mode() -> void:
	if saved_fullscreen:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_MAXIMIZED)

	# Keep the intended 16:9 composition instead of cropping UI/3D on 16:10 displays.
	get_window().content_scale_size = Vector2i(1280, 720)
	get_window().content_scale_mode = Window.CONTENT_SCALE_MODE_CANVAS_ITEMS
	get_window().content_scale_aspect = Window.CONTENT_SCALE_ASPECT_KEEP

func _on_fullscreen_toggled(enabled: bool) -> void:
	saved_fullscreen = enabled
	_apply_window_mode()
	_save_settings()

func _build_world() -> void:
	world_root = Node3D.new()
	world_root.name = "World"
	add_child(world_root)

	var world_env: WorldEnvironment = WorldEnvironment.new()
	var env: Environment = Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color("#06060b")
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color("#2b2638")
	env.ambient_light_energy = 0.33
	env.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	world_env.environment = env
	world_root.add_child(world_env)

	var moon: DirectionalLight3D = DirectionalLight3D.new()
	moon.rotation_degrees = Vector3(-46.0, -30.0, 0.0)
	moon.light_color = Color("#747ca8")
	moon.light_energy = 0.30
	moon.shadow_enabled = true
	world_root.add_child(moon)

	var warm_fill: OmniLight3D = OmniLight3D.new()
	warm_fill.position = Vector3(-2.8, 2.8, 1.7)
	warm_fill.light_color = Color("#7d2e34")
	warm_fill.light_energy = 0.95
	warm_fill.omni_range = 8.0
	world_root.add_child(warm_fill)

	camera = Camera3D.new()
	camera.position = Vector3(0.0, 2.55, 7.45)
	camera_home = camera.position
	camera.fov = 47.0
	camera.current = true
	world_root.add_child(camera)
	camera.look_at(Vector3(0.0, 0.72, 0.0), Vector3.UP)

	var floor: MeshInstance3D = MeshInstance3D.new()
	var floor_mesh: PlaneMesh = PlaneMesh.new()
	floor_mesh.size = Vector2(16.0, 16.0)
	floor.mesh = floor_mesh
	floor.position.y = -0.35
	floor.material_override = _material(Color("#0e0d13"), 0.98)
	world_root.add_child(floor)

	var wall: MeshInstance3D = MeshInstance3D.new()
	var wall_mesh: BoxMesh = BoxMesh.new()
	wall_mesh.size = Vector3(12.0, 6.0, 0.25)
	wall.mesh = wall_mesh
	wall.position = Vector3(0.0, 2.65, -3.4)
	wall.material_override = _material(Color("#111019"), 0.92)
	world_root.add_child(wall)

	var table: MeshInstance3D = MeshInstance3D.new()
	var table_mesh: BoxMesh = BoxMesh.new()
	table_mesh.size = Vector3(6.9, 0.32, 4.6)
	table.mesh = table_mesh
	table.position = Vector3(0.0, -0.16, 0.0)
	table.material_override = _material(Color("#2a120a"), 0.78)
	world_root.add_child(table)

	var cloth: MeshInstance3D = MeshInstance3D.new()
	var cloth_mesh: BoxMesh = BoxMesh.new()
	cloth_mesh.size = Vector3(5.9, 0.045, 3.8)
	cloth.mesh = cloth_mesh
	cloth.position = Vector3(0.0, 0.025, 0.0)
	cloth.material_override = _material(Color("#491c2d"), 0.88)
	world_root.add_child(cloth)

	_build_decorations()
	_build_wall_banner()
	_build_party_people()
	_build_horror_details()

	cake_root = Node3D.new()
	cake_root.name = "Cake"
	world_root.add_child(cake_root)
	_build_cake()

func _build_decorations() -> void:
	var balloon_positions: Array[Vector3] = [
		Vector3(-3.2, 3.25, -2.9), Vector3(-2.55, 3.82, -3.0),
		Vector3(3.2, 3.42, -2.9), Vector3(2.55, 3.95, -3.0)
	]
	var balloon_colors: Array[Color] = [
		Color("#a75d72"), Color("#d7b45c"), Color("#6e789f"), Color("#b3789b")
	]
	for i in range(balloon_positions.size()):
		var balloon: MeshInstance3D = MeshInstance3D.new()
		var sphere: SphereMesh = SphereMesh.new()
		sphere.radius = 0.34
		sphere.height = 0.90
		balloon.mesh = sphere
		balloon.position = balloon_positions[i]
		balloon.scale = Vector3(0.82, 1.12, 0.82)
		balloon.material_override = _material(balloon_colors[i], 0.42)
		world_root.add_child(balloon)

	var flag_colors: Array[Color] = [Color("#8b4158"), Color("#c09a4d"), Color("#566386")]
	for i in range(11):
		var flag: MeshInstance3D = MeshInstance3D.new()
		var flag_mesh: BoxMesh = BoxMesh.new()
		flag_mesh.size = Vector3(0.38, 0.34, 0.035)
		flag.mesh = flag_mesh
		flag.position = Vector3(-2.2 + float(i) * 0.44, 4.25 + sin(float(i) * 0.65) * 0.12, -3.2)
		flag.rotation_degrees.z = -4.0 + sin(float(i) * 1.8) * 6.0
		flag.material_override = _material(flag_colors[i % flag_colors.size()], 0.76)
		world_root.add_child(flag)

	for side in [-1.0, 1.0]:
		var chair: MeshInstance3D = MeshInstance3D.new()
		var chair_mesh: BoxMesh = BoxMesh.new()
		chair_mesh.size = Vector3(0.85, 1.25, 0.60)
		chair.mesh = chair_mesh
		chair.position = Vector3(float(side) * 2.6, 0.4, 1.25)
		chair.material_override = _material(Color("#17141b"), 0.90)
		world_root.add_child(chair)

func _build_wall_banner() -> void:
	banner_title = Label3D.new()
	banner_title.text = _t("banner")
	banner_title.font = ui_font
	banner_title.font_size = 66
	banner_title.outline_size = 8
	banner_title.modulate = Color("#ead4aa")
	banner_title.outline_modulate = Color("#241923")
	banner_title.position = Vector3(0.0, 4.48, -3.26)
	world_root.add_child(banner_title)

	banner_name = Label3D.new()
	banner_name.text = "YOU"
	banner_name.font = ui_font
	banner_name.font_size = 40
	banner_name.outline_size = 6
	banner_name.modulate = Color("#d9a9b8")
	banner_name.outline_modulate = Color("#241923")
	banner_name.position = Vector3(0.0, 3.90, -3.24)
	world_root.add_child(banner_name)

func _build_party_people() -> void:
	var positions: Array[Vector3] = [
		Vector3(-3.0, 0.08, -1.60),
		Vector3(-2.20, 0.08, -2.20),
		Vector3(3.0, 0.08, -1.60),
		Vector3(2.20, 0.08, -2.20),
		Vector3(0.0, 0.08, -2.72)
	]
	var colors: Array[Color] = [
		Color("#647da4"), Color("#a35b75"), Color("#708e68"),
		Color("#987448"), Color("#725b8d")
	]
	party_phrase_labels.clear()

	for i in range(positions.size()):
		var person: Dictionary = _create_party_person(positions[i], colors[i], float(i) * 1.2)
		party_people.append(person)

		var phrase: Label3D = Label3D.new()
		phrase.font = ui_font
		phrase.text = _t("party_%d" % (i + 1))
		phrase.font_size = 21
		phrase.outline_size = 4
		phrase.modulate = Color(0.90, 0.86, 0.89, 0.72)
		phrase.outline_modulate = Color("#18131b")
		phrase.position = positions[i] + Vector3(0.0, 2.00, 0.0)
		world_root.add_child(phrase)
		party_phrase_labels.append(phrase)

func _create_party_person(pos: Vector3, body_color: Color, phase: float) -> Dictionary:
	var root: Node3D = Node3D.new()
	root.position = pos
	world_root.add_child(root)

	var body: MeshInstance3D = MeshInstance3D.new()
	var body_mesh: CapsuleMesh = CapsuleMesh.new()
	body_mesh.radius = 0.24
	body_mesh.height = 0.90
	body_mesh.radial_segments = 18
	body_mesh.rings = 8
	body.mesh = body_mesh
	body.position.y = 0.82
	body.material_override = _material(body_color, 0.78)
	root.add_child(body)

	var head: MeshInstance3D = MeshInstance3D.new()
	var head_mesh: SphereMesh = SphereMesh.new()
	head_mesh.radius = 0.25
	head_mesh.height = 0.50
	head.mesh = head_mesh
	head.position.y = 1.55
	head.material_override = _material(Color("#d5b29d"), 0.74)
	root.add_child(head)

	var hair: MeshInstance3D = MeshInstance3D.new()
	var hair_mesh: SphereMesh = SphereMesh.new()
	hair_mesh.radius = 0.255
	hair_mesh.height = 0.30
	hair.mesh = hair_mesh
	hair.position = Vector3(0.0, 1.72, -0.03)
	hair.scale = Vector3(1.02, 0.72, 1.02)
	hair.material_override = _material(Color("#241c22"), 0.92)
	root.add_child(hair)

	var left_arm: Node3D = _create_party_arm(root, Vector3(-0.34, 1.02, 0.0), body_color, -18.0)
	var right_arm: Node3D = _create_party_arm(root, Vector3(0.34, 1.02, 0.0), body_color, 18.0)

	return {
		"root": root,
		"left_arm": left_arm,
		"right_arm": right_arm,
		"base_y": root.position.y,
		"phase": phase
	}

func _create_party_arm(parent_node: Node3D, pos: Vector3, color: Color, rotation_z: float) -> Node3D:
	var pivot: Node3D = Node3D.new()
	pivot.position = pos
	pivot.rotation_degrees.z = rotation_z
	parent_node.add_child(pivot)

	var arm: MeshInstance3D = MeshInstance3D.new()
	var arm_mesh: CylinderMesh = CylinderMesh.new()
	arm_mesh.top_radius = 0.075
	arm_mesh.bottom_radius = 0.075
	arm_mesh.height = 0.70
	arm_mesh.radial_segments = 12
	arm.mesh = arm_mesh
	arm.position.y = -0.33
	arm.material_override = _material(color, 0.78)
	pivot.add_child(arm)
	return pivot

func _build_horror_details() -> void:
	# A barely-visible extra "guest" near the edge of the room.
	# It only appears for a fraction of a second from time to time.
	horror_shadow = Node3D.new()
	horror_shadow.name = "QuietShadow"
	horror_shadow.position = Vector3(4.15, 0.02, -3.05)
	horror_shadow.scale = Vector3(0.76, 1.22, 0.76)
	horror_shadow.visible = false
	world_root.add_child(horror_shadow)

	var shadow_body: MeshInstance3D = MeshInstance3D.new()
	var body_mesh: CapsuleMesh = CapsuleMesh.new()
	body_mesh.radius = 0.23
	body_mesh.height = 1.15
	body_mesh.radial_segments = 12
	body_mesh.rings = 6
	shadow_body.mesh = body_mesh
	shadow_body.position.y = 0.88
	shadow_body.material_override = _material(Color("#08070a"), 0.98)
	horror_shadow.add_child(shadow_body)

	var shadow_head: MeshInstance3D = MeshInstance3D.new()
	var head_mesh: SphereMesh = SphereMesh.new()
	head_mesh.radius = 0.22
	head_mesh.height = 0.46
	shadow_head.mesh = head_mesh
	shadow_head.position = Vector3(0.0, 1.72, 0.0)
	shadow_head.scale = Vector3(0.82, 1.08, 0.82)
	shadow_head.material_override = _material(Color("#070609"), 0.98)
	horror_shadow.add_child(shadow_head)

func _build_cake() -> void:
	candles.clear()
	for child in cake_root.get_children():
		child.queue_free()

	var plate: MeshInstance3D = MeshInstance3D.new()
	var plate_mesh: CylinderMesh = CylinderMesh.new()
	plate_mesh.top_radius = 1.82
	plate_mesh.bottom_radius = 1.82
	plate_mesh.height = 0.09
	plate_mesh.radial_segments = 64
	plate.mesh = plate_mesh
	plate.position.y = -0.01
	plate.material_override = _material(Color("#d7d2cf"), 0.50)
	cake_root.add_child(plate)

	var cake: MeshInstance3D = MeshInstance3D.new()
	var cake_mesh: CylinderMesh = CylinderMesh.new()
	cake_mesh.top_radius = 1.44
	cake_mesh.bottom_radius = 1.44
	cake_mesh.height = 0.78
	cake_mesh.radial_segments = 64
	cake.mesh = cake_mesh
	cake.position.y = 0.40
	cake.material_override = _material(Color("#b66e83"), 0.78)
	cake_root.add_child(cake)

	var cream: MeshInstance3D = MeshInstance3D.new()
	var cream_mesh: CylinderMesh = CylinderMesh.new()
	cream_mesh.top_radius = 1.50
	cream_mesh.bottom_radius = 1.50
	cream_mesh.height = 0.13
	cream_mesh.radial_segments = 64
	cream.mesh = cream_mesh
	cream.position.y = 0.86
	cream.material_override = _material(Color("#fff0cf"), 0.95)
	cake_root.add_child(cream)

	for i in range(14):
		var angle: float = TAU * float(i) / 14.0
		var dollop: MeshInstance3D = MeshInstance3D.new()
		var dollop_mesh: SphereMesh = SphereMesh.new()
		dollop_mesh.radius = 0.12
		dollop_mesh.height = 0.19
		dollop.mesh = dollop_mesh
		dollop.position = Vector3(cos(angle) * 1.25, 0.98, sin(angle) * 1.25)
		dollop.scale = Vector3(1.0, 0.70, 1.0)
		dollop.material_override = _material(Color("#fff4dc"), 0.95)
		cake_root.add_child(dollop)

	for i in range(6):
		var angle: float = TAU * float(i) / 6.0 + 0.35
		var berry: MeshInstance3D = MeshInstance3D.new()
		var berry_mesh: SphereMesh = SphereMesh.new()
		berry_mesh.radius = 0.12
		berry_mesh.height = 0.24
		berry.mesh = berry_mesh
		berry.position = Vector3(cos(angle) * 0.82, 1.04, sin(angle) * 0.82)
		berry.scale = Vector3(0.80, 1.15, 0.80)
		berry.material_override = _material(Color("#9f2638"), 0.50)
		cake_root.add_child(berry)

	candle_root = Node3D.new()
	candle_root.name = "Candles"
	cake_root.add_child(candle_root)

func _material(color: Color, roughness: float = 0.7, emission: Color = Color(0, 0, 0, 1), emission_energy: float = 0.0, transparent: bool = false) -> StandardMaterial3D:
	var mat: StandardMaterial3D = StandardMaterial3D.new()
	mat.albedo_color = color
	mat.roughness = roughness
	if transparent:
		mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	if emission_energy > 0.0:
		mat.emission_enabled = true
		mat.emission = emission
		mat.emission_energy_multiplier = emission_energy
	return mat

func _build_ui() -> void:
	ui_layer = CanvasLayer.new()
	add_child(ui_layer)

	menu_root = Control.new()
	menu_root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	menu_root.theme = ui_theme
	ui_layer.add_child(menu_root)

	var shade: ColorRect = ColorRect.new()
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	shade.color = Color(0.004, 0.004, 0.009, 0.30)
	shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	menu_root.add_child(shade)

	var menu_box: VBoxContainer = VBoxContainer.new()
	menu_box.set_anchors_preset(Control.PRESET_CENTER)
	menu_box.position = Vector2(-260, -175)
	menu_box.size = Vector2(520, 350)
	menu_box.add_theme_constant_override("separation", 11)
	menu_root.add_child(menu_box)

	menu_title_label = Label.new()
	menu_title_label.text = "Birthday Boy You"
	menu_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	menu_title_label.add_theme_font_size_override("font_size", 48)
	menu_title_label.modulate = Color("#eee5e4")
	menu_box.add_child(menu_title_label)

	menu_subtitle_label = Label.new()
	menu_subtitle_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	menu_subtitle_label.add_theme_font_size_override("font_size", 16)
	menu_subtitle_label.modulate = Color(0.78, 0.72, 0.76, 0.90)
	menu_box.add_child(menu_subtitle_label)

	var spacer: Control = Control.new()
	spacer.custom_minimum_size.y = 16
	menu_box.add_child(spacer)

	name_edit = LineEdit.new()
	name_edit.text = "YOU"
	name_edit.alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_edit.custom_minimum_size = Vector2(410, 46)
	name_edit.add_theme_font_size_override("font_size", 18)
	menu_box.add_child(name_edit)

	birthday_button_ref = _make_button("")
	birthday_button_ref.pressed.connect(_on_birthday_pressed)
	menu_box.add_child(birthday_button_ref)

	challenge_button_ref = _make_button("")
	challenge_button_ref.pressed.connect(_on_challenge_pressed)
	menu_box.add_child(challenge_button_ref)

	settings_button_ref = _make_button("", 220, 38, 15)
	settings_button_ref.pressed.connect(_open_settings)
	menu_box.add_child(settings_button_ref)

	hud_root = Control.new()
	hud_root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	hud_root.theme = ui_theme
	ui_layer.add_child(hud_root)

	mode_label = Label.new()
	mode_label.position = Vector2(26, 22)
	mode_label.add_theme_font_size_override("font_size", 18)
	mode_label.modulate = Color(0.88, 0.83, 0.86, 0.88)
	hud_root.add_child(mode_label)

	timer_label = Label.new()
	timer_label.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	timer_label.position = Vector2(-250, 22)
	timer_label.size = Vector2(220, 46)
	timer_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	timer_label.add_theme_font_size_override("font_size", 27)
	hud_root.add_child(timer_label)

	score_label = Label.new()
	score_label.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	score_label.position = Vector2(-255, 66)
	score_label.size = Vector2(225, 38)
	score_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	score_label.add_theme_font_size_override("font_size", 16)
	hud_root.add_child(score_label)

	center_message = Label.new()
	center_message.set_anchors_preset(Control.PRESET_CENTER_TOP)
	center_message.position = Vector2(-420, 38)
	center_message.size = Vector2(840, 112)
	center_message.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	center_message.add_theme_font_size_override("font_size", 22)
	center_message.modulate = Color("#eee6e5")
	hud_root.add_child(center_message)

	var mic_box: VBoxContainer = VBoxContainer.new()
	mic_box.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	mic_box.position = Vector2(-250, -82)
	mic_box.size = Vector2(500, 58)
	mic_box.add_theme_constant_override("separation", 3)
	hud_root.add_child(mic_box)

	mic_label = Label.new()
	mic_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	mic_label.add_theme_font_size_override("font_size", 13)
	mic_label.modulate = Color(0.78, 0.73, 0.77, 0.90)
	mic_box.add_child(mic_label)

	mic_meter = ProgressBar.new()
	mic_meter.min_value = 0.0
	mic_meter.max_value = 100.0
	mic_meter.value = 0.0
	mic_meter.show_percentage = false
	mic_meter.custom_minimum_size.y = 7
	mic_box.add_child(mic_meter)

	analysis_label = Label.new()
	analysis_label.visible = false
	mic_box.add_child(analysis_label)

	back_button_ref = _make_button("", 150, 36, 14)
	back_button_ref.position = Vector2(20, 62)
	back_button_ref.pressed.connect(_show_menu)
	hud_root.add_child(back_button_ref)

	eat_hint_label = Label.new()
	eat_hint_label.set_anchors_preset(Control.PRESET_CENTER_TOP)
	eat_hint_label.position = Vector2(-360, 120)
	eat_hint_label.size = Vector2(720, 48)
	eat_hint_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	eat_hint_label.add_theme_font_size_override("font_size", 20)
	eat_hint_label.modulate = Color(0.94, 0.88, 0.89, 0.96)
	eat_hint_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	eat_hint_label.visible = false
	hud_root.add_child(eat_hint_label)

	eat_controls_panel = PanelContainer.new()
	eat_controls_panel.set_anchors_preset(Control.PRESET_BOTTOM_LEFT)
	eat_controls_panel.position = Vector2(28, -205)
	eat_controls_panel.size = Vector2(430, 160)
	var eat_controls_style: StyleBoxFlat = StyleBoxFlat.new()
	eat_controls_style.bg_color = Color(0.025, 0.020, 0.030, 0.82)
	eat_controls_style.border_color = Color(0.45, 0.34, 0.42, 0.55)
	eat_controls_style.set_border_width_all(1)
	eat_controls_style.corner_radius_top_left = 12
	eat_controls_style.corner_radius_top_right = 12
	eat_controls_style.corner_radius_bottom_left = 12
	eat_controls_style.corner_radius_bottom_right = 12
	eat_controls_style.content_margin_left = 16
	eat_controls_style.content_margin_right = 16
	eat_controls_style.content_margin_top = 12
	eat_controls_style.content_margin_bottom = 12
	eat_controls_panel.add_theme_stylebox_override("panel", eat_controls_style)
	hud_root.add_child(eat_controls_panel)

	eat_controls_label = Label.new()
	eat_controls_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	eat_controls_label.add_theme_font_size_override("font_size", 14)
	eat_controls_label.modulate = Color(0.90, 0.86, 0.88, 0.96)
	eat_controls_panel.add_child(eat_controls_label)
	eat_controls_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	eat_controls_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	eat_controls_panel.visible = false

	eat_mouth_zone = PanelContainer.new()
	eat_mouth_zone.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	eat_mouth_zone.position = Vector2(-180, -92)
	eat_mouth_zone.size = Vector2(360, 62)
	var mouth_style: StyleBoxFlat = StyleBoxFlat.new()
	mouth_style.bg_color = Color(0.20, 0.10, 0.15, 0.20)
	mouth_style.border_color = Color(0.88, 0.62, 0.72, 0.66)
	mouth_style.set_border_width_all(1)
	mouth_style.corner_radius_top_left = 18
	mouth_style.corner_radius_top_right = 18
	mouth_style.corner_radius_bottom_left = 18
	mouth_style.corner_radius_bottom_right = 18
	eat_mouth_zone.add_theme_stylebox_override("panel", mouth_style)
	hud_root.add_child(eat_mouth_zone)

	eat_mouth_label = Label.new()
	eat_mouth_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	eat_mouth_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	eat_mouth_label.add_theme_font_size_override("font_size", 15)
	eat_mouth_label.modulate = Color(0.94, 0.82, 0.86, 0.96)
	eat_mouth_zone.add_child(eat_mouth_label)
	eat_mouth_zone.mouse_filter = Control.MOUSE_FILTER_IGNORE
	eat_mouth_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	eat_mouth_zone.visible = false

	eat_done_button = _make_button("", 210, 40, 15)
	eat_done_button.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
	eat_done_button.position = Vector2(-240, -62)
	eat_done_button.pressed.connect(_finish_eating)
	eat_done_button.visible = false
	hud_root.add_child(eat_done_button)

	result_root = Control.new()
	result_root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	result_root.theme = ui_theme
	ui_layer.add_child(result_root)

	var result_dim: ColorRect = ColorRect.new()
	result_dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	result_dim.color = Color(0.004, 0.004, 0.009, 0.72)
	result_root.add_child(result_dim)

	var result_box: VBoxContainer = VBoxContainer.new()
	result_box.set_anchors_preset(Control.PRESET_CENTER)
	result_box.position = Vector2(-300, -150)
	result_box.size = Vector2(600, 300)
	result_box.add_theme_constant_override("separation", 14)
	result_root.add_child(result_box)

	result_title = Label.new()
	result_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	result_title.add_theme_font_size_override("font_size", 38)
	result_title.modulate = Color("#eee6e5")
	result_box.add_child(result_title)

	result_subtitle = Label.new()
	result_subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	result_subtitle.add_theme_font_size_override("font_size", 18)
	result_subtitle.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	result_subtitle.modulate = Color(0.80, 0.75, 0.78, 0.95)
	result_box.add_child(result_subtitle)

	replay_button_ref = _make_button("")
	replay_button_ref.pressed.connect(_restart_current_mode)
	result_box.add_child(replay_button_ref)

	result_menu_button_ref = _make_button("")
	result_menu_button_ref.pressed.connect(_show_menu)
	result_box.add_child(result_menu_button_ref)

	settings_root = Control.new()
	settings_root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	settings_root.theme = ui_theme
	ui_layer.add_child(settings_root)

	var settings_dim: ColorRect = ColorRect.new()
	settings_dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	settings_dim.color = Color(0.005, 0.004, 0.010, 0.86)
	settings_root.add_child(settings_dim)

	var settings_panel: PanelContainer = PanelContainer.new()
	settings_panel.set_anchors_preset(Control.PRESET_CENTER)
	settings_panel.position = Vector2(-295, -255)
	settings_panel.size = Vector2(590, 510)
	var settings_style: StyleBoxFlat = StyleBoxFlat.new()
	settings_style.bg_color = Color(0.055, 0.045, 0.065, 0.96)
	settings_style.border_color = Color(0.35, 0.27, 0.34, 0.85)
	settings_style.set_border_width_all(1)
	settings_style.corner_radius_top_left = 14
	settings_style.corner_radius_top_right = 14
	settings_style.corner_radius_bottom_left = 14
	settings_style.corner_radius_bottom_right = 14
	settings_style.content_margin_left = 34
	settings_style.content_margin_right = 34
	settings_style.content_margin_top = 20
	settings_style.content_margin_bottom = 20
	settings_panel.add_theme_stylebox_override("panel", settings_style)
	settings_root.add_child(settings_panel)

	var settings_box: VBoxContainer = VBoxContainer.new()
	settings_box.add_theme_constant_override("separation", 14)
	settings_panel.add_child(settings_box)

	settings_title = Label.new()
	settings_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	settings_title.add_theme_font_size_override("font_size", 30)
	settings_box.add_child(settings_title)

	settings_language_label = Label.new()
	settings_language_label.add_theme_font_size_override("font_size", 15)
	settings_box.add_child(settings_language_label)

	language_option = OptionButton.new()
	language_option.add_item("日本語")
	language_option.add_item("English")
	language_option.add_item("简体中文")
	language_option.add_item("한국어")
	language_option.item_selected.connect(_on_language_selected)
	settings_box.add_child(language_option)

	settings_mic_title = Label.new()
	settings_mic_title.add_theme_font_size_override("font_size", 19)
	settings_box.add_child(settings_mic_title)

	settings_mic_device_label = Label.new()
	settings_mic_device_label.add_theme_font_size_override("font_size", 14)
	settings_box.add_child(settings_mic_device_label)

	var mic_device_row: HBoxContainer = HBoxContainer.new()
	mic_device_row.add_theme_constant_override("separation", 10)
	settings_box.add_child(mic_device_row)

	mic_device_option = OptionButton.new()
	mic_device_option.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	mic_device_option.item_selected.connect(_on_mic_device_selected)
	mic_device_row.add_child(mic_device_option)

	settings_refresh_devices_button = _make_button("", 145, 36, 13)
	settings_refresh_devices_button.pressed.connect(_refresh_input_devices)
	mic_device_row.add_child(settings_refresh_devices_button)

	settings_sensitivity_label = Label.new()
	settings_sensitivity_label.add_theme_font_size_override("font_size", 14)
	settings_box.add_child(settings_sensitivity_label)

	sensitivity_slider = HSlider.new()
	sensitivity_slider.min_value = 0.0
	sensitivity_slider.max_value = 1.0
	sensitivity_slider.step = 0.05
	sensitivity_slider.value = saved_sensitivity
	sensitivity_slider.value_changed.connect(_on_sensitivity_changed)
	settings_box.add_child(sensitivity_slider)

	sensitivity_value_label = Label.new()
	sensitivity_value_label.text = "%d%%" % int(round(saved_sensitivity * 100.0))
	settings_box.add_child(sensitivity_value_label)

	settings_mic_meter = ProgressBar.new()
	settings_mic_meter.min_value = 0.0
	settings_mic_meter.max_value = 100.0
	settings_mic_meter.show_percentage = false
	settings_mic_meter.custom_minimum_size.y = 9
	settings_box.add_child(settings_mic_meter)

	settings_mic_status = Label.new()
	settings_mic_status.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	settings_mic_status.add_theme_font_size_override("font_size", 14)
	settings_mic_status.custom_minimum_size.y = 40
	settings_box.add_child(settings_mic_status)

	var settings_buttons: HBoxContainer = HBoxContainer.new()
	settings_buttons.alignment = BoxContainer.ALIGNMENT_CENTER
	settings_buttons.add_theme_constant_override("separation", 12)
	settings_box.add_child(settings_buttons)

	settings_auto_button = _make_button("", 190, 42, 15)
	settings_auto_button.pressed.connect(_auto_adjust_microphone)
	settings_buttons.add_child(settings_auto_button)

	settings_test_button = _make_button("", 190, 42, 15)
	settings_test_button.pressed.connect(_start_mic_test)
	settings_buttons.add_child(settings_test_button)

	settings_display_title = Label.new()
	settings_display_title.add_theme_font_size_override("font_size", 19)
	settings_box.add_child(settings_display_title)

	fullscreen_toggle = CheckButton.new()
	fullscreen_toggle.button_pressed = saved_fullscreen
	fullscreen_toggle.toggled.connect(_on_fullscreen_toggled)
	settings_box.add_child(fullscreen_toggle)

	settings_close_button = _make_button("", 200, 42, 15)
	settings_close_button.pressed.connect(_close_settings)
	settings_box.add_child(settings_close_button)

	settings_root.visible = false

	intro_root = Control.new()
	intro_root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	intro_root.theme = ui_theme
	ui_layer.add_child(intro_root)

	var intro_bg: ColorRect = ColorRect.new()
	intro_bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	intro_bg.color = Color(0.004, 0.003, 0.008, 1.0)
	intro_root.add_child(intro_bg)

	var intro_box: VBoxContainer = VBoxContainer.new()
	intro_box.set_anchors_preset(Control.PRESET_CENTER)
	intro_box.position = Vector2(-360, -110)
	intro_box.size = Vector2(720, 220)
	intro_box.add_theme_constant_override("separation", 18)
	intro_root.add_child(intro_box)

	intro_title = Label.new()
	intro_title.text = "Birthday Boy You"
	intro_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	intro_title.add_theme_font_size_override("font_size", 54)
	intro_title.modulate = Color(0.94, 0.90, 0.91, 0.0)
	intro_box.add_child(intro_title)

	intro_subtitle = Label.new()
	intro_subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	intro_subtitle.add_theme_font_size_override("font_size", 17)
	intro_subtitle.modulate = Color(0.78, 0.72, 0.76, 0.0)
	intro_box.add_child(intro_subtitle)

	intro_skip_button = _make_button("", 150, 34, 13)
	intro_skip_button.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
	intro_skip_button.position = Vector2(-175, -52)
	intro_skip_button.pressed.connect(_finish_title_intro)
	intro_root.add_child(intro_skip_button)

	fade_layer = ColorRect.new()
	fade_layer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	fade_layer.color = Color(0.0, 0.0, 0.0, 0.0)
	fade_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ui_layer.add_child(fade_layer)

	horror_overlay = ColorRect.new()
	horror_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	horror_overlay.color = Color(0.015, 0.0, 0.025, 0.0)
	horror_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ui_layer.add_child(horror_overlay)

func _make_button(text_value: String, width: int = 450, height: int = 54, font_size: int = 19) -> Button:
	var button: Button = Button.new()
	button.text = text_value
	button.custom_minimum_size = Vector2(width, height)
	button.add_theme_font_size_override("font_size", font_size)

	var normal: StyleBoxFlat = StyleBoxFlat.new()
	normal.bg_color = Color(0.05, 0.04, 0.06, 0.18)
	normal.border_color = Color(0.55, 0.43, 0.52, 0.30)
	normal.border_width_bottom = 1
	normal.corner_radius_top_left = 6
	normal.corner_radius_top_right = 6
	normal.corner_radius_bottom_left = 6
	normal.corner_radius_bottom_right = 6

	var hover: StyleBoxFlat = normal.duplicate() as StyleBoxFlat
	hover.bg_color = Color(0.20, 0.13, 0.19, 0.36)
	hover.border_color = Color(0.82, 0.62, 0.70, 0.70)
	var pressed: StyleBoxFlat = normal.duplicate() as StyleBoxFlat
	pressed.bg_color = Color(0.08, 0.06, 0.09, 0.55)

	button.add_theme_stylebox_override("normal", normal)
	button.add_theme_stylebox_override("hover", hover)
	button.add_theme_stylebox_override("pressed", pressed)
	button.mouse_entered.connect(_on_button_hover)
	return button


func _setup_microphone() -> void:
	_refresh_input_devices()

	var devices: PackedStringArray = AudioServer.get_input_device_list()
	var selected_device: String = saved_input_device
	if selected_device != "Default" and not devices.has(selected_device):
		selected_device = "Default"
		saved_input_device = "Default"

	AudioServer.set_input_device_active(false)
	AudioServer.input_device = selected_device
	var input_error: Error = AudioServer.set_input_device_active(true)

	if input_error == OK:
		if settings_mic_status != null:
			settings_mic_status.text = _t("device_ready") % AudioServer.input_device
	else:
		if settings_mic_status != null:
			settings_mic_status.text = _t("device_failed")

	_reset_mic_calibration()

func _refresh_input_devices() -> void:
	if mic_device_option == null:
		return

	var current_name: String = saved_input_device
	mic_device_option.clear()
	mic_device_option.add_item("Default")

	var devices: PackedStringArray = AudioServer.get_input_device_list()
	for device_name in devices:
		if device_name != "Default":
			mic_device_option.add_item(device_name)

	var selected_index: int = 0
	for i in range(mic_device_option.item_count):
		if mic_device_option.get_item_text(i) == current_name:
			selected_index = i
			break
	mic_device_option.select(selected_index)

func _on_mic_device_selected(index: int) -> void:
	if mic_device_option == null:
		return

	var device_name: String = mic_device_option.get_item_text(index)
	AudioServer.set_input_device_active(false)
	AudioServer.input_device = device_name
	var input_error: Error = AudioServer.set_input_device_active(true)

	saved_input_device = AudioServer.input_device
	_save_settings()
	_reset_mic_calibration()

	if settings_mic_status != null:
		if input_error == OK:
			settings_mic_status.text = _t("device_ready") % saved_input_device
		else:
			settings_mic_status.text = _t("device_failed")

func _update_microphone(delta: float) -> void:
	var available: int = AudioServer.get_input_frames_available()

	if available <= 0:
		blow_strength = move_toward(blow_strength, 0.0, delta * 2.2)
		blow_smoothed = lerpf(blow_smoothed, blow_strength, minf(delta * 10.0, 1.0))
		if mic_meter != null:
			mic_meter.value = blow_smoothed * 100.0
		if settings_mic_meter != null:
			settings_mic_meter.value = blow_smoothed * 100.0
		if mode != GameMode.MENU and mic_label != null:
			mic_label.text = _t("no_mic")
		return

	var frames_to_read: int = mini(available, 4096)
	var buffer: PackedVector2Array = AudioServer.get_input_frames(frames_to_read)
	if buffer.is_empty():
		return

	var count: int = buffer.size()
	var mono: PackedFloat32Array = PackedFloat32Array()
	mono.resize(count)

	var energy: float = 0.0
	var diff_energy: float = 0.0
	var previous: float = 0.0

	for i in range(count):
		var sample: float = (buffer[i].x + buffer[i].y) * 0.5
		mono[i] = sample
		energy += sample * sample

		if i > 0:
			var difference: float = sample - previous
			diff_energy += difference * difference

		previous = sample

	mic_rms = sqrt(energy / maxf(float(count), 1.0))
	mic_roughness = sqrt(diff_energy / maxf(energy, 0.000000001))
	mic_periodicity = _estimate_periodicity(mono)

	if calibration_left > 0.0:
		calibration_left -= delta
		if mic_rms > 0.00002 and mic_rms < 0.020:
			mic_noise_floor = lerpf(mic_noise_floor, mic_rms, 0.10)

		if mic_label != null:
			mic_label.text = _t("calibrating")
		if settings_mic_status != null and settings_root.visible:
			settings_mic_status.text = _t("calibrating")
		if mic_meter != null:
			mic_meter.value = 0.0
		if settings_mic_meter != null:
			settings_mic_meter.value = 0.0
		return

	var sensitivity: float = saved_sensitivity
	if sensitivity_slider != null:
		sensitivity = float(sensitivity_slider.value)

	var threshold_multiplier: float = lerpf(3.2, 1.10, sensitivity)
	mic_threshold = clampf(mic_noise_floor * threshold_multiplier, 0.0030, 0.0160)

	var loudness_score: float = clampf((mic_rms - mic_threshold) / 0.032, 0.0, 1.0)
	var roughness_score: float = clampf((mic_roughness - 0.16) / 0.90, 0.0, 1.0)
	var unvoiced_score: float = clampf((0.84 - mic_periodicity) / 0.64, 0.0, 1.0)
	var breath_character: float = maxf(roughness_score, unvoiced_score)
	var candidate: float = loudness_score * lerpf(0.82, 1.12, breath_character)

	var looks_like_voice: bool = mic_periodicity > 0.80 and mic_roughness < 0.38
	if looks_like_voice:
		candidate *= 0.45

	if mic_rms > mic_threshold * 2.0:
		candidate = maxf(candidate, 0.30)
	if mic_rms > mic_threshold * 3.5:
		candidate = maxf(candidate, 0.52)

	if mic_rms < mic_threshold:
		candidate = 0.0

	if test_blow_left > 0.0:
		test_blow_left -= delta
		candidate = maxf(candidate, 0.88)

	candidate = clampf(candidate, 0.0, 1.0)

	var attack_speed: float = 24.0 if candidate > blow_strength else 7.0
	blow_strength = lerpf(blow_strength, candidate, minf(delta * attack_speed, 1.0))
	blow_smoothed = lerpf(blow_smoothed, blow_strength, minf(delta * 13.0, 1.0))

	if mic_meter != null:
		mic_meter.value = blow_smoothed * 100.0
	if settings_mic_meter != null:
		settings_mic_meter.value = blow_smoothed * 100.0

	var is_blowing: bool = blow_smoothed > 0.10
	if is_blowing and not was_blowing:
		_play_sound(SFX_WHOOSH, -20.0)
	was_blowing = is_blowing

	var status_text: String = _t("listening")
	if is_blowing:
		status_text = _t("breath")
	elif looks_like_voice and mic_rms > mic_threshold:
		status_text = _t("voice")
	elif mic_rms > mic_threshold * 0.70:
		status_text = _t("almost")

	if mic_label != null:
		mic_label.text = status_text

	if settings_mic_status != null and settings_root.visible and not mic_test_active:
		settings_mic_status.text = status_text

	if analysis_label != null:
		analysis_label.text = "Level %.3f   Wind %.0f%%   Voice %.2f   Th %.3f" % [mic_rms, blow_smoothed * 100.0, mic_periodicity, mic_threshold]

func _estimate_periodicity(samples: PackedFloat32Array) -> float:
	var n: int = samples.size()
	if n < 700:
		return 0.0

	var rate: float = float(AudioServer.get_mix_rate())
	var min_lag: int = maxi(1, int(rate / 360.0))
	var max_lag: int = mini(n / 2, int(rate / 85.0))
	var span: int = maxi(1, max_lag - min_lag)
	var step: int = maxi(2, int(float(span) / 18.0))
	var best: float = 0.0

	var lag: int = min_lag
	while lag <= max_lag:
		var corr: float = 0.0
		var e1: float = 0.0
		var e2: float = 0.0
		var usable: int = n - lag
		var i: int = 0
		while i < usable:
			var a: float = samples[i]
			var b: float = samples[i + lag]
			corr += a * b
			e1 += a * a
			e2 += b * b
			i += 3
		var denom: float = sqrt(maxf(e1 * e2, 0.0000000001))
		var normalized: float = corr / denom
		best = maxf(best, normalized)
		lag += step

	return clampf(best, 0.0, 1.0)

func _update_candles(delta: float) -> void:
	var now: float = float(Time.get_ticks_msec()) / 1000.0

	for index in range(candles.size()):
		var data: Dictionary = candles[index]
		if not bool(data["lit"]) or bool(data.get("extinguishing", false)):
			continue

		var root: Node3D = data["root"] as Node3D
		var flame: Node3D = data["flame"] as Node3D
		var light: OmniLight3D = data["light"] as OmniLight3D
		var phase: float = float(data["phase"])
		var heat: float = float(data["heat"])

		var wave: float = sin(now * 7.0 + phase)
		var wave2: float = sin(now * 12.0 + phase * 1.73)
		var exposure: float = _candle_exposure(root.position)
		var effective_blow: float = blow_smoothed * exposure

		if mode == GameMode.CHALLENGE and not challenge_active:
			effective_blow = 0.0

		if effective_blow > 0.07:
			# A steady real breath should extinguish a front candle in roughly
			# 0.5–1.5 seconds depending on strength and position.
			heat -= delta * (0.50 + effective_blow * 1.80)
		else:
			heat += delta * 0.08
		heat = clampf(heat, 0.0, 1.0)
		data["heat"] = heat
		candles[index] = data

		var lean: float = -effective_blow * 58.0
		flame.rotation_degrees.z = lean + wave2 * 3.0
		flame.position.x = effective_blow * -0.10
		flame.scale = Vector3(
			0.72 + wave2 * 0.025 + effective_blow * 0.08,
			maxf(0.18, (1.05 + wave * 0.07) * (0.35 + heat * 0.65)),
			0.72 + wave2 * 0.025
		)
		light.light_energy = maxf(0.08, (1.05 + wave * 0.18) * (0.20 + heat * 0.80))

		if heat <= 0.06:
			_extinguish(index)

	if mode == GameMode.CHALLENGE and challenge_active and not finished:
		challenge_score = candles.size() - _lit_candle_indices().size()
		score_label.text = "%d / %d OUT" % [challenge_score, CHALLENGE_CANDLES]

	if mode == GameMode.BIRTHDAY and not finished and not candles.is_empty():
		var remaining: int = _lit_candle_indices().size()
		if remaining == 0:
			_finish_birthday()
		elif blow_smoothed > 0.10:
			center_message.text = _t("keep_blowing") % remaining

func _candle_exposure(pos: Vector3) -> float:
	var depth: float = clampf((pos.z + 1.25) / 2.5, 0.0, 1.0)
	var center_factor: float = 1.0 - clampf(absf(pos.x) / 1.65, 0.0, 0.55)
	var front_factor: float = 0.62 + depth * 0.48
	return clampf(center_factor * front_factor, 0.35, 1.10)

func _extinguish(index: int) -> void:
	if index < 0 or index >= candles.size():
		return

	var data: Dictionary = candles[index]
	if not bool(data["lit"]) or bool(data.get("extinguishing", false)):
		return

	data["extinguishing"] = true
	candles[index] = data

	var flame: Node3D = data["flame"] as Node3D
	var light: OmniLight3D = data["light"] as OmniLight3D
	var root: Node3D = data["root"] as Node3D

	# First the flame gets pushed almost flat and pinches down.
	var bend: Tween = create_tween()
	bend.set_parallel(true)
	bend.tween_property(flame, "rotation_degrees:z", -82.0, 0.12).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	bend.tween_property(flame, "scale", Vector3(0.78, 0.16, 0.78), 0.12).set_trans(Tween.TRANS_QUAD)
	bend.tween_property(light, "light_energy", 0.20, 0.12)
	await bend.finished

	# Tiny final flicker instead of instantly disappearing.
	var pinch: Tween = create_tween()
	pinch.set_parallel(true)
	pinch.tween_property(flame, "scale", Vector3(0.30, 0.035, 0.30), 0.11).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	pinch.tween_property(light, "light_energy", 0.0, 0.13)
	await pinch.finished

	flame.hide()
	data = candles[index]
	data["lit"] = false
	data["extinguishing"] = false
	candles[index] = data
	_spawn_smoke(root)
	_play_sound(custom_candle_out if custom_candle_out != null else SFX_EXTINGUISH, -13.0)

func _spawn_smoke(candle: Node3D) -> void:
	for i in range(3):
		var puff: MeshInstance3D = MeshInstance3D.new()
		var mesh: SphereMesh = SphereMesh.new()
		mesh.radius = 0.055 + float(i) * 0.012
		mesh.height = 0.11 + float(i) * 0.018
		puff.mesh = mesh
		var alpha: float = 0.34 - float(i) * 0.06
		puff.material_override = _material(Color(0.62, 0.62, 0.66, alpha), 1.0, Color(0,0,0,1), 0.0, true)
		puff.position = candle.global_position + Vector3(randf_range(-0.025, 0.025), 1.02 + float(i) * 0.06, randf_range(-0.02, 0.02))
		world_root.add_child(puff)

		var end_pos: Vector3 = puff.position + Vector3(randf_range(-0.10, 0.10), 0.65 + float(i) * 0.18, randf_range(-0.04, 0.04))
		var end_scale: Vector3 = Vector3.ONE * (1.8 + float(i) * 0.35)
		var tw: Tween = create_tween()
		tw.set_parallel(true)
		tw.tween_property(puff, "position", end_pos, 0.80 + float(i) * 0.18).set_trans(Tween.TRANS_SINE)
		tw.tween_property(puff, "scale", end_scale, 0.80 + float(i) * 0.18)
		tw.finished.connect(puff.queue_free)

func _update_party_people(delta: float) -> void:
	for data in party_people:
		var root: Node3D = data["root"] as Node3D
		var left_arm: Node3D = data["left_arm"] as Node3D
		var right_arm: Node3D = data["right_arm"] as Node3D
		var base_y: float = float(data["base_y"])
		var phase: float = float(data["phase"])

		var idle_bob: float = sin(elapsed * 1.7 + phase) * 0.015
		var cheer_amount: float = 1.0 if celebrating else 0.0
		var cheer_bob: float = absf(sin(elapsed * 7.0 + phase)) * 0.09 * cheer_amount
		root.position.y = lerpf(root.position.y, base_y + idle_bob + cheer_bob, minf(delta * 8.0, 1.0))

		var idle_left: float = -18.0 + sin(elapsed * 1.5 + phase) * 4.0
		var idle_right: float = 18.0 - sin(elapsed * 1.5 + phase) * 4.0
		var cheer_left: float = -145.0 + sin(elapsed * 8.0 + phase) * 18.0
		var cheer_right: float = 145.0 - sin(elapsed * 8.0 + phase) * 18.0
		left_arm.rotation_degrees.z = lerpf(idle_left, cheer_left, cheer_amount)
		right_arm.rotation_degrees.z = lerpf(idle_right, cheer_right, cheer_amount)

func _update_horror(delta: float) -> void:
	if horror_shadow == null or horror_overlay == null:
		return

	# Challenge mode stays clean and game-like. The uncanny details belong to the
	# quiet birthday/menu atmosphere.
	if mode == GameMode.CHALLENGE:
		horror_shadow.visible = false
		horror_overlay.color.a = 0.0
		return

	horror_timer -= delta

	if horror_shadow_left > 0.0:
		horror_shadow_left -= delta
		if horror_shadow_left <= 0.0:
			horror_shadow.visible = false

	if horror_flicker_left > 0.0:
		horror_flicker_left -= delta
		var pulse: float = clampf(horror_flicker_left / 0.20, 0.0, 1.0)
		horror_overlay.color.a = pulse * 0.075
	else:
		horror_overlay.color.a = 0.0

	if horror_timer <= 0.0:
		horror_timer = randf_range(13.0, 27.0)

		# Most events are only a tiny lighting dip. Sometimes the extra guest is
		# visible at the edge of the frame for less than a second.
		horror_flicker_left = 0.20
		if randf() < 0.42 and not eating_mode:
			horror_shadow.visible = true
			horror_shadow_left = randf_range(0.28, 0.62)

func _update_challenge(delta: float) -> void:
	if mode != GameMode.CHALLENGE or finished:
		return

	if challenge_countdown > 0.0:
		var old_second: int = int(ceil(challenge_countdown))
		challenge_countdown -= delta
		var new_second: int = int(ceil(maxf(challenge_countdown, 0.0)))
		timer_label.text = "READY  %d" % maxi(new_second, 1)
		center_message.text = _t("challenge_ready")
		if new_second != old_second and new_second > 0 and new_second != last_count_second:
			last_count_second = new_second
			_play_sound(SFX_COUNT, -8.0)
		if challenge_countdown <= 0.0:
			challenge_active = true
			timer_label.text = "GO!"
			center_message.text = _t("challenge_go")
			_play_sound(SFX_CONFIRM, -5.0)
		return

	if challenge_active:
		challenge_time_left -= delta
		timer_label.text = "%.1f s" % maxf(challenge_time_left, 0.0)
		if challenge_time_left <= 0.0 or _lit_candle_indices().is_empty():
			_finish_challenge()

func _update_camera(delta: float) -> void:
	if camera == null:
		return
	var sway: float = sin(elapsed * 0.45) * 0.035
	var target: Vector3 = camera_home + Vector3(sway, 0.0, 0.0)
	camera.position = camera.position.lerp(target, minf(delta * 2.0, 1.0))
	camera.look_at(Vector3(0.0, 0.72, 0.0), Vector3.UP)

func _spawn_candles(count: int) -> void:
	for child in candle_root.get_children():
		child.queue_free()
	candles.clear()

	for i in range(count):
		var pos: Vector3 = Vector3.ZERO
		if count <= 10:
			var angle: float = TAU * float(i) / float(count)
			pos = Vector3(cos(angle) * 0.90, 0.91, sin(angle) * 0.66)
		else:
			if i < 10:
				var outer_angle: float = TAU * float(i) / 10.0
				pos = Vector3(cos(outer_angle) * 1.10, 0.91, sin(outer_angle) * 0.78)
			else:
				var inner_count: int = count - 10
				var inner_angle: float = TAU * float(i - 10) / float(inner_count)
				pos = Vector3(cos(inner_angle) * 0.62, 0.91, sin(inner_angle) * 0.44)
		_create_candle(pos, i)

func _create_candle(pos: Vector3, index: int) -> void:
	var root: Node3D = Node3D.new()
	root.name = "Candle%d" % (index + 1)
	root.position = pos
	candle_root.add_child(root)

	var height: float = 0.62 if mode == GameMode.CHALLENGE else 0.72
	var radius: float = 0.048 if mode == GameMode.CHALLENGE else 0.062

	var body: MeshInstance3D = MeshInstance3D.new()
	var body_mesh: CylinderMesh = CylinderMesh.new()
	body_mesh.top_radius = radius
	body_mesh.bottom_radius = radius
	body_mesh.height = height
	body_mesh.radial_segments = 18
	body.mesh = body_mesh
	body.position.y = height * 0.5
	var colors: Array[Color] = [Color("#f7c75a"), Color("#dc758f"), Color("#78b996"), Color("#74a5d7"), Color("#b18ac7")]
	body.material_override = _material(colors[index % colors.size()], 0.62)
	root.add_child(body)

	var wick: MeshInstance3D = MeshInstance3D.new()
	var wick_mesh: CylinderMesh = CylinderMesh.new()
	wick_mesh.top_radius = 0.008
	wick_mesh.bottom_radius = 0.008
	wick_mesh.height = 0.08
	wick_mesh.radial_segments = 8
	wick.mesh = wick_mesh
	wick.position.y = height + 0.04
	wick.material_override = _material(Color("#161110"), 1.0)
	root.add_child(wick)

	var flame: Node3D = Node3D.new()
	flame.position.y = height + 0.16
	root.add_child(flame)

	var outer: MeshInstance3D = MeshInstance3D.new()
	var outer_mesh: CapsuleMesh = CapsuleMesh.new()
	outer_mesh.radius = 0.075 if mode == GameMode.CHALLENGE else 0.09
	outer_mesh.height = 0.20 if mode == GameMode.CHALLENGE else 0.24
	outer_mesh.radial_segments = 18
	outer_mesh.rings = 8
	outer.mesh = outer_mesh
	outer.material_override = _material(Color("#ffb02e"), 0.22, Color("#ff5a00"), 4.0)
	flame.add_child(outer)

	var inner: MeshInstance3D = MeshInstance3D.new()
	var inner_mesh: CapsuleMesh = CapsuleMesh.new()
	inner_mesh.radius = 0.038 if mode == GameMode.CHALLENGE else 0.045
	inner_mesh.height = 0.12 if mode == GameMode.CHALLENGE else 0.14
	inner_mesh.radial_segments = 14
	inner_mesh.rings = 6
	inner.mesh = inner_mesh
	inner.position.y = -0.025
	inner.material_override = _material(Color("#fff6b0"), 0.16, Color("#fff3a0"), 5.0)
	flame.add_child(inner)

	var light: OmniLight3D = OmniLight3D.new()
	light.light_color = Color("#ff8a34")
	light.light_energy = 1.05
	light.omni_range = 2.2
	light.shadow_enabled = false
	flame.add_child(light)

	var data: Dictionary = {
		"root": root,
		"flame": flame,
		"light": light,
		"lit": true,
		"extinguishing": false,
		"phase": randf() * TAU,
		"heat": 1.0
	}
	candles.append(data)

func _lit_candle_indices() -> Array[int]:
	var result: Array[int] = []
	for i in range(candles.size()):
		var data: Dictionary = candles[i]
		if bool(data["lit"]):
			result.append(i)
	return result

func _on_birthday_pressed() -> void:
	_play_sound(SFX_CONFIRM, -9.0)
	_transition_to_game_audio()
	mode = GameMode.BIRTHDAY
	finished = false
	celebrating = false
	eating_mode = false
	birthday_name = name_edit.text.strip_edges()
	if birthday_name.is_empty():
		birthday_name = "YOU"

	banner_name.text = birthday_name.to_upper()
	_build_cake()
	_spawn_candles(BIRTHDAY_CANDLES)

	menu_root.visible = false
	hud_root.visible = true
	result_root.visible = false
	settings_root.visible = false
	eat_hint_label.visible = false
	eat_done_button.visible = false
	mode_label.text = _t("birthday_mode")
	timer_label.text = ""
	score_label.text = ""
	center_message.text = _t("wish_prompt")
	_soften_game_music_for_candles()
	_reset_mic_calibration()

func _on_challenge_pressed() -> void:
	_play_sound(SFX_CONFIRM, -9.0)
	_transition_to_game_audio()
	mode = GameMode.CHALLENGE
	finished = false
	celebrating = false
	eating_mode = false
	challenge_score = 0
	challenge_countdown = 3.2
	challenge_time_left = CHALLENGE_SECONDS
	challenge_active = false
	last_count_second = -1
	banner_name.text = _t("challenge_mode")
	_build_cake()
	_spawn_candles(CHALLENGE_CANDLES)
	menu_root.visible = false
	hud_root.visible = true
	result_root.visible = false
	settings_root.visible = false
	eat_hint_label.visible = false
	eat_done_button.visible = false
	mode_label.text = _t("challenge_mode")
	timer_label.text = "3"
	score_label.text = "0 / %d" % CHALLENGE_CANDLES
	center_message.text = _t("challenge_ready")
	_reset_mic_calibration()

func _reset_mic_calibration() -> void:
	calibration_left = CALIBRATION_SECONDS
	mic_noise_floor = maxf(mic_noise_floor, 0.003)
	mic_threshold = 0.010
	blow_strength = 0.0
	blow_smoothed = 0.0
	was_blowing = false
	test_blow_left = 0.0

func _finish_birthday() -> void:
	if finished:
		return
	finished = true
	celebrating = false
	_restore_game_music()
	center_message.text = ""

	# 最後の炎が消えた瞬間をちゃんと残す。すぐに歓声を鳴らさない。
	await get_tree().create_timer(0.55).timeout
	if mode != GameMode.BIRTHDAY:
		return

	center_message.text = _t("congrats_soft")
	celebrating = true
	_play_sound(custom_applause if custom_applause != null else SFX_APPLAUSE, -17.0)

	await get_tree().create_timer(1.45).timeout
	if mode != GameMode.BIRTHDAY:
		return

	center_message.text = _t("cake_soft")
	await get_tree().create_timer(0.80).timeout
	if mode == GameMode.BIRTHDAY:
		_start_cake_time()

func _finish_challenge() -> void:
	if finished:
		return
	finished = true
	celebrating = true
	challenge_active = false
	challenge_score = candles.size() - _lit_candle_indices().size()

	var rank_text: String = ""
	if challenge_score >= CHALLENGE_CANDLES:
		rank_text = _t("rank_perfect")
	elif challenge_score >= 20:
		rank_text = _t("rank_high")
	elif challenge_score >= 10:
		rank_text = _t("rank_mid")
	else:
		rank_text = _t("rank_low")

	_play_sound(SFX_SUCCESS, -10.0)
	_spawn_confetti(10)
	result_title.text = _t("challenge_result") % [challenge_score, CHALLENGE_CANDLES]
	result_subtitle.text = rank_text
	result_root.visible = true

func _spawn_confetti(count: int) -> void:
	var colors: Array[Color] = [Color("#e8b858"), Color("#d76f8c"), Color("#6f9bd1"), Color("#7eb48c"), Color("#b48ac9")]
	for i in range(count):
		var piece: MeshInstance3D = MeshInstance3D.new()
		var mesh: BoxMesh = BoxMesh.new()
		mesh.size = Vector3(0.045, 0.11, 0.015)
		piece.mesh = mesh
		piece.material_override = _material(colors[i % colors.size()], 0.65)
		piece.position = Vector3(randf_range(-3.4, 3.4), randf_range(4.4, 5.7), randf_range(-1.4, 1.6))
		piece.rotation_degrees = Vector3(randf_range(0.0, 180.0), randf_range(0.0, 180.0), randf_range(0.0, 180.0))
		world_root.add_child(piece)

		var target: Vector3 = piece.position + Vector3(randf_range(-0.8, 0.8), -randf_range(4.0, 5.2), randf_range(-0.4, 0.5))
		var duration: float = randf_range(1.8, 3.2)
		var tw: Tween = create_tween()
		tw.set_parallel(true)
		tw.tween_property(piece, "position", target, duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
		tw.tween_property(piece, "rotation_degrees", piece.rotation_degrees + Vector3(randf_range(280.0, 720.0), randf_range(280.0, 720.0), randf_range(280.0, 720.0)), duration)
		tw.finished.connect(piece.queue_free)

func _show_title_intro() -> void:
	title_intro_finished = false
	menu_root.visible = false
	hud_root.visible = false
	result_root.visible = false
	settings_root.visible = false
	intro_root.visible = true
	intro_title.modulate.a = 0.0
	intro_subtitle.modulate.a = 0.0
	intro_subtitle.text = _t("intro_subtitle")
	intro_skip_button.text = _t("skip_intro")
	_play_title_music()

	var tween: Tween = create_tween()
	tween.tween_interval(0.35)
	tween.tween_property(intro_title, "modulate:a", 1.0, 1.25)
	tween.tween_interval(0.20)
	tween.tween_property(intro_subtitle, "modulate:a", 0.88, 0.9)
	tween.tween_interval(1.4)
	tween.finished.connect(_finish_title_intro)

func _finish_title_intro() -> void:
	if title_intro_finished:
		return
	title_intro_finished = true
	var tween: Tween = create_tween()
	tween.tween_property(intro_root, "modulate:a", 0.0, 0.65)
	await tween.finished
	intro_root.visible = false
	intro_root.modulate.a = 1.0
	_show_menu()

func _fade_screen_to(alpha: float, duration: float) -> void:
	if fade_layer == null:
		return
	var tween: Tween = create_tween()
	tween.tween_property(fade_layer, "color:a", alpha, duration)
	await tween.finished

func _show_menu() -> void:
	mode = GameMode.MENU
	finished = false
	celebrating = false
	challenge_active = false
	eating_mode = false
	held_piece = null
	mic_test_active = false
	if banner_name != null:
		banner_name.text = "YOU"
	menu_root.visible = true
	hud_root.visible = false
	back_button_ref.visible = true
	mic_label.visible = true
	mic_meter.visible = true
	result_root.visible = false
	settings_root.visible = false
	eat_hint_label.visible = false
	eat_controls_panel.visible = false
	eat_mouth_zone.visible = false
	eat_done_button.visible = false
	_clear_cake_pieces()

	if candle_root != null and is_instance_valid(candle_root):
		for child in candle_root.get_children():
			child.queue_free()
	candles.clear()
	if bgm_player != null and bgm_player.playing:
		_fade_player(bgm_player, -80.0, 0.8, true)
	_play_menu_music()

func _restart_current_mode() -> void:
	result_root.visible = false
	if mode == GameMode.BIRTHDAY:
		_on_birthday_pressed()
	elif mode == GameMode.CHALLENGE:
		_on_challenge_pressed()

func _on_sensitivity_changed(value: float) -> void:
	saved_sensitivity = value
	if sensitivity_value_label != null:
		sensitivity_value_label.text = "%d%%" % int(round(value * 100.0))
	_save_settings()

func _on_button_hover() -> void:
	_play_sound(SFX_HOVER, -19.0)

func _open_settings() -> void:
	settings_root.visible = true
	_refresh_input_devices()
	settings_mic_status.text = _t("device_ready") % AudioServer.input_device

func _close_settings() -> void:
	mic_test_active = false
	settings_root.visible = false
	_save_settings()

func _auto_adjust_microphone() -> void:
	calibration_left = 1.25
	mic_noise_floor = 0.003
	settings_mic_status.text = _t("auto_done")

func _start_mic_test() -> void:
	mic_test_active = true
	mic_test_success_time = 0.0
	settings_mic_status.text = _t("mic_test_wait")

func _update_mic_test(delta: float) -> void:
	if not mic_test_active:
		return
	if blow_smoothed > 0.12:
		mic_test_success_time += delta
		if mic_test_success_time > 0.22:
			settings_mic_status.text = _t("mic_test_ok")
			mic_test_active = false
	else:
		mic_test_success_time = 0.0

func _on_language_selected(index: int) -> void:
	match index:
		0:
			current_language = "ja"
		1:
			current_language = "en"
		2:
			current_language = "zh"
		3:
			current_language = "ko"
		_:
			current_language = "en"
	_apply_language()
	_save_settings()

func _apply_language() -> void:
	if menu_subtitle_label == null:
		return

	menu_subtitle_label.text = _t("subtitle")
	name_edit.placeholder_text = _t("name_placeholder")
	birthday_button_ref.text = _t("birthday")
	challenge_button_ref.text = _t("challenge")
	settings_button_ref.text = _t("settings")
	settings_title.text = _t("settings")
	settings_language_label.text = _t("language")
	settings_mic_title.text = _t("microphone")
	settings_mic_device_label.text = _t("input_device")
	settings_refresh_devices_button.text = _t("refresh_devices")
	settings_sensitivity_label.text = _t("sensitivity")
	settings_auto_button.text = _t("auto_adjust")
	settings_test_button.text = _t("mic_test")
	settings_display_title.text = _t("display")
	fullscreen_toggle.text = _t("fullscreen")
	settings_close_button.text = _t("close")
	back_button_ref.text = _t("back")
	replay_button_ref.text = _t("replay")
	result_menu_button_ref.text = _t("menu")
	eat_done_button.text = _t("cake_done")
	if intro_subtitle != null:
		intro_subtitle.text = _t("intro_subtitle")
	if intro_skip_button != null:
		intro_skip_button.text = _t("skip_intro")
	if eat_controls_label != null:
		eat_controls_label.text = _t("cake_controls")
	if eat_mouth_label != null:
		eat_mouth_label.text = _t("mouth_here")

	if banner_title != null:
		banner_title.text = _t("banner")

	var phrase_count: int = mini(party_phrase_labels.size(), 5)
	for i in range(phrase_count):
		party_phrase_labels[i].text = _t("party_%d" % (i + 1))

	if language_option != null:
		var target_index: int = 1
		if current_language == "ja":
			target_index = 0
		elif current_language == "zh":
			target_index = 2
		elif current_language == "ko":
			target_index = 3
		language_option.select(target_index)


func _start_cake_time() -> void:
	eating_mode = true
	celebrating = false
	held_piece = null
	pieces_eaten = 0
	candles.clear()
	center_message.text = _t("cake_intro")
	mic_label.visible = false
	mic_meter.visible = false
	eat_hint_label.text = _t("cake_hint")
	eat_hint_label.visible = true
	eat_controls_label.text = _t("cake_controls")
	eat_controls_panel.visible = true
	eat_mouth_label.text = _t("mouth_here")
	eat_mouth_zone.visible = true
	eat_done_button.visible = true
	back_button_ref.visible = false
	_build_eating_cake()

func _build_eating_cake() -> void:
	_clear_cake_pieces()

	for child in cake_root.get_children():
		child.queue_free()

	var plate: MeshInstance3D = MeshInstance3D.new()
	var plate_mesh: CylinderMesh = CylinderMesh.new()
	plate_mesh.top_radius = 1.82
	plate_mesh.bottom_radius = 1.82
	plate_mesh.height = 0.08
	plate_mesh.radial_segments = 64
	plate.mesh = plate_mesh
	plate.position.y = -0.01
	plate.material_override = _material(Color("#d8d2cf"), 0.50)
	cake_root.add_child(plate)

	var slice_count: int = 8
	var radius: float = 1.38
	var cake_height: float = 0.56

	for i in range(slice_count):
		var start_angle: float = -PI * 0.5 + TAU * float(i) / float(slice_count)
		var end_angle: float = -PI * 0.5 + TAU * float(i + 1) / float(slice_count)

		var piece_root: Node3D = Node3D.new()
		piece_root.name = "CakeSlice%d" % (i + 1)
		piece_root.position = Vector3(0.0, 0.34, 0.0)
		cake_root.add_child(piece_root)

		var cake_part: MeshInstance3D = MeshInstance3D.new()
		cake_part.mesh = _create_wedge_mesh(radius, cake_height, start_angle, end_angle)
		cake_part.material_override = _material(Color("#b76d83"), 0.78)
		piece_root.add_child(cake_part)

		var cream: MeshInstance3D = MeshInstance3D.new()
		cream.mesh = _create_wedge_mesh(radius + 0.015, 0.10, start_angle, end_angle)
		cream.position.y = cake_height * 0.5 + 0.05
		cream.material_override = _material(Color("#fff1d2"), 0.95)
		piece_root.add_child(cream)

		var middle_angle: float = (start_angle + end_angle) * 0.5
		if i % 2 == 0:
			var berry: MeshInstance3D = MeshInstance3D.new()
			var berry_mesh: SphereMesh = SphereMesh.new()
			berry_mesh.radius = 0.09
			berry_mesh.height = 0.18
			berry.mesh = berry_mesh
			berry.position = Vector3(cos(middle_angle) * 0.82, cake_height * 0.5 + 0.20, sin(middle_angle) * 0.82)
			berry.scale = Vector3(0.78, 1.05, 0.78)
			berry.material_override = _material(Color("#9d2737"), 0.52)
			piece_root.add_child(berry)

		var area: Area3D = Area3D.new()
		area.collision_layer = 2
		area.collision_mask = 0
		area.input_ray_pickable = true
		area.set_meta("cake_piece", true)
		area.set_meta("bites", 0)
		area.set_meta("home_position", piece_root.position)
		area.set_meta("home_rotation", piece_root.rotation)
		area.set_meta("home_scale", piece_root.scale)
		area.set_meta("pick_angle", middle_angle)
		piece_root.add_child(area)

		var collision: CollisionShape3D = CollisionShape3D.new()
		var shape: ConvexPolygonShape3D = ConvexPolygonShape3D.new()
		var points: PackedVector3Array = PackedVector3Array()
		var half_h: float = cake_height * 0.5
		points.append(Vector3(0.0, -half_h, 0.0))
		points.append(Vector3(0.0, half_h + 0.16, 0.0))
		points.append(Vector3(cos(start_angle) * radius, -half_h, sin(start_angle) * radius))
		points.append(Vector3(cos(start_angle) * radius, half_h + 0.16, sin(start_angle) * radius))
		points.append(Vector3(cos(end_angle) * radius, -half_h, sin(end_angle) * radius))
		points.append(Vector3(cos(end_angle) * radius, half_h + 0.16, sin(end_angle) * radius))
		shape.points = points
		collision.shape = shape
		area.add_child(collision)

		cake_piece_areas.append(area)

	_play_sound(SFX_PLATE, -18.0)

func _create_wedge_mesh(radius: float, height: float, start_angle: float, end_angle: float) -> ArrayMesh:
	var surface: SurfaceTool = SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)

	var half_h: float = height * 0.5
	var segments: int = 5

	# Top and bottom fan triangles.
	for s in range(segments):
		var a0: float = lerpf(start_angle, end_angle, float(s) / float(segments))
		var a1: float = lerpf(start_angle, end_angle, float(s + 1) / float(segments))

		var top_center: Vector3 = Vector3(0.0, half_h, 0.0)
		var top0: Vector3 = Vector3(cos(a0) * radius, half_h, sin(a0) * radius)
		var top1: Vector3 = Vector3(cos(a1) * radius, half_h, sin(a1) * radius)

		surface.set_uv(Vector2(0.5, 0.5))
		surface.add_vertex(top_center)
		surface.set_uv(Vector2(0.5 + cos(a0) * 0.5, 0.5 + sin(a0) * 0.5))
		surface.add_vertex(top0)
		surface.set_uv(Vector2(0.5 + cos(a1) * 0.5, 0.5 + sin(a1) * 0.5))
		surface.add_vertex(top1)

		var bottom_center: Vector3 = Vector3(0.0, -half_h, 0.0)
		var bottom0: Vector3 = Vector3(cos(a0) * radius, -half_h, sin(a0) * radius)
		var bottom1: Vector3 = Vector3(cos(a1) * radius, -half_h, sin(a1) * radius)

		surface.add_vertex(bottom_center)
		surface.add_vertex(bottom1)
		surface.add_vertex(bottom0)

		# Outer curved wall, approximated by short flat sections.
		surface.add_vertex(bottom0)
		surface.add_vertex(bottom1)
		surface.add_vertex(top1)

		surface.add_vertex(bottom0)
		surface.add_vertex(top1)
		surface.add_vertex(top0)

	# Two radial side walls.
	for side_angle in [start_angle, end_angle]:
		var outer_bottom: Vector3 = Vector3(cos(side_angle) * radius, -half_h, sin(side_angle) * radius)
		var outer_top: Vector3 = Vector3(cos(side_angle) * radius, half_h, sin(side_angle) * radius)
		var center_bottom: Vector3 = Vector3(0.0, -half_h, 0.0)
		var center_top: Vector3 = Vector3(0.0, half_h, 0.0)

		surface.add_vertex(center_bottom)
		surface.add_vertex(outer_bottom)
		surface.add_vertex(outer_top)

		surface.add_vertex(center_bottom)
		surface.add_vertex(outer_top)
		surface.add_vertex(center_top)

	surface.generate_normals()
	return surface.commit()

func _clear_cake_pieces() -> void:
	cake_piece_areas.clear()
	held_piece = null

func _pick_cake_piece(screen_position: Vector2) -> void:
	if not eating_mode or camera == null or cake_piece_areas.is_empty():
		return

	var origin: Vector3 = camera.project_ray_origin(screen_position)
	var direction: Vector3 = camera.project_ray_normal(screen_position)

	# The edible cake sits roughly on this horizontal plane.
	# Intersect the mouse ray with that plane, then choose the wedge by angle.
	# This is much more reliable than requiring a tiny 3D collider hit.
	var cake_plane_y: float = cake_root.global_position.y + 0.34
	if absf(direction.y) > 0.0001:
		var distance_to_plane: float = (cake_plane_y - origin.y) / direction.y
		if distance_to_plane > 0.0:
			var world_point: Vector3 = origin + direction * distance_to_plane
			var local_point: Vector3 = cake_root.to_local(world_point)
			var radial_distance: float = Vector2(local_point.x, local_point.z).length()

			# Only accept clicks over the visible cake disc.
			if radial_distance <= 1.62:
				var angle: float = atan2(local_point.z, local_point.x)
				var normalized_angle: float = fposmod(angle + PI * 0.5, TAU)
				var slice_float: float = normalized_angle / TAU * float(cake_piece_areas.size())
				var slice_index: int = clampi(int(floor(slice_float)), 0, cake_piece_areas.size() - 1)
				_grab_cake_area(cake_piece_areas[slice_index])
				get_viewport().set_input_as_handled()
				return

	# Fallback: choose the nearest visible slice on screen with a very generous radius.
	var best_area: Area3D = null
	var best_distance: float = 999999.0

	for area in cake_piece_areas:
		if area == null or not is_instance_valid(area):
			continue

		var piece_root: Node3D = area.get_parent() as Node3D
		if piece_root == null:
			continue

		var pick_angle: float = float(area.get_meta("pick_angle", 0.0))
		var pick_world: Vector3 = piece_root.global_position + Vector3(
			cos(pick_angle) * 0.82,
			0.18,
			sin(pick_angle) * 0.82
		)

		if camera.is_position_behind(pick_world):
			continue

		var projected: Vector2 = camera.unproject_position(pick_world)
		var screen_distance: float = projected.distance_to(screen_position)
		if screen_distance < best_distance:
			best_distance = screen_distance
			best_area = area

	if best_area != null and best_distance <= 185.0:
		_grab_cake_area(best_area)
		get_viewport().set_input_as_handled()

func _grab_cake_area(area: Area3D) -> void:
	if area == null or not is_instance_valid(area):
		return

	held_piece = area
	var piece_root: Node3D = held_piece.get_parent() as Node3D
	if piece_root == null:
		held_piece = null
		return

	# Visual confirmation that the piece is actually in the player's hand.
	var grab_tween: Tween = create_tween()
	grab_tween.set_parallel(true)
	grab_tween.tween_property(piece_root, "position:y", 0.72, 0.10).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	grab_tween.tween_property(piece_root, "scale", Vector3(1.10, 1.10, 1.10), 0.10)

func _release_held_piece() -> void:
	if held_piece == null or not is_instance_valid(held_piece):
		held_piece = null
		return

	var area: Area3D = held_piece
	var piece_root: Node3D = area.get_parent() as Node3D
	held_piece = null

	if piece_root == null or not is_instance_valid(piece_root):
		return

	var home_position_variant: Variant = area.get_meta("home_position", Vector3.ZERO)
	var home_position: Vector3 = home_position_variant as Vector3
	var home_rotation_variant: Variant = area.get_meta("home_rotation", Vector3.ZERO)
	var home_rotation: Vector3 = home_rotation_variant as Vector3
	var home_scale_variant: Variant = area.get_meta("home_scale", Vector3.ONE)
	var home_scale: Vector3 = home_scale_variant as Vector3

	var return_tween: Tween = create_tween()
	return_tween.set_parallel(true)
	return_tween.tween_property(piece_root, "position", home_position, 0.20).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	return_tween.tween_property(piece_root, "rotation", home_rotation, 0.20)
	return_tween.tween_property(piece_root, "scale", home_scale, 0.20)

func _update_eating(delta: float) -> void:
	if not eating_mode or held_piece == null or not is_instance_valid(held_piece):
		return

	var piece_root: Node3D = held_piece.get_parent() as Node3D
	if piece_root == null:
		held_piece = null
		return

	var mouse: Vector2 = get_viewport().get_mouse_position()
	var viewport_size: Vector2 = get_viewport().get_visible_rect().size
	var origin: Vector3 = camera.project_ray_origin(mouse)
	var direction: Vector3 = camera.project_ray_normal(mouse)

	var y_ratio: float = clampf(mouse.y / maxf(viewport_size.y, 1.0), 0.0, 1.0)
	var mouth_progress: float = clampf((y_ratio - 0.18) / 0.72, 0.0, 1.0)
	var depth: float = lerpf(5.2, 1.05, mouth_progress)
	var target: Vector3 = origin + direction * depth

	piece_root.global_position = piece_root.global_position.lerp(target, minf(delta * 15.0, 1.0))
	piece_root.rotation_degrees.z = lerpf(piece_root.rotation_degrees.z, -8.0, minf(delta * 7.0, 1.0))

	var near_center: bool = absf(mouse.x - viewport_size.x * 0.5) < minf(260.0, viewport_size.x * 0.22)
	var in_mouth_zone: bool = y_ratio > 0.80 and near_center

	if eat_mouth_zone != null:
		var mouth_style: StyleBoxFlat = eat_mouth_zone.get_theme_stylebox("panel") as StyleBoxFlat
		if mouth_style != null:
			mouth_style.border_color = Color(0.96, 0.74, 0.81, 0.95) if in_mouth_zone else Color(0.88, 0.62, 0.72, 0.66)

	if in_mouth_zone and eat_cooldown <= 0.0:
		_bite_piece(held_piece)

func _bite_piece(area: Area3D) -> void:
	if area == null or not is_instance_valid(area):
		return

	var piece_root: Node3D = area.get_parent() as Node3D
	if piece_root == null:
		return

	var bites: int = int(area.get_meta("bites", 0)) + 1
	area.set_meta("bites", bites)
	eat_cooldown = 0.45
	_play_sound(custom_eat if custom_eat != null else SFX_BITE, -12.0)
	center_message.text = _t("bite")

	if bites >= 2:
		pieces_eaten += 1
		cake_piece_areas.erase(area)
		held_piece = null
		var tween: Tween = create_tween()
		tween.set_parallel(true)
		tween.tween_property(piece_root, "scale", Vector3(0.10, 0.10, 0.10), 0.18)
		tween.tween_property(piece_root, "global_position", camera.global_position + camera.global_basis * Vector3(0.0, -0.25, -0.80), 0.18)
		tween.finished.connect(piece_root.queue_free)

		if cake_piece_areas.is_empty():
			center_message.text = _t("all_eaten")
			await get_tree().create_timer(0.6).timeout
			_finish_eating()
	else:
		var new_home_scale: Vector3 = Vector3(0.74, 0.74, 0.74)
		area.set_meta("home_scale", new_home_scale)
		held_piece = null

		var home_position_variant: Variant = area.get_meta("home_position", Vector3.ZERO)
		var home_position: Vector3 = home_position_variant as Vector3
		var return_tween: Tween = create_tween()
		return_tween.set_parallel(true)
		return_tween.tween_property(piece_root, "position", home_position, 0.20).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		return_tween.tween_property(piece_root, "scale", new_home_scale, 0.20)

func _finish_eating() -> void:
	if not eating_mode or ending_in_progress:
		return

	ending_in_progress = true
	eating_mode = false
	held_piece = null
	eat_hint_label.visible = false
	eat_controls_panel.visible = false
	eat_mouth_zone.visible = false
	eat_done_button.visible = false
	back_button_ref.visible = false
	mic_label.visible = false
	mic_meter.visible = false
	center_message.text = ""

	if bgm_player != null and bgm_player.playing:
		_fade_player(bgm_player, -38.0, 1.5)

	await get_tree().create_timer(0.75).timeout
	center_message.text = _t("ending_thanks")
	await get_tree().create_timer(2.2).timeout
	center_message.text = _t("ending_next")
	await get_tree().create_timer(2.0).timeout

	await _fade_screen_to(1.0, 1.5)
	center_message.text = ""
	ending_in_progress = false
	back_button_ref.visible = true
	mic_label.visible = true
	mic_meter.visible = true
	_show_menu()
	await _fade_screen_to(0.0, 1.1)

func _play_sound(stream: AudioStream, volume_db: float = -7.0) -> void:
	var player: AudioStreamPlayer = AudioStreamPlayer.new()
	player.stream = stream
	player.volume_db = volume_db
	add_child(player)
	player.finished.connect(player.queue_free)
	player.play()
