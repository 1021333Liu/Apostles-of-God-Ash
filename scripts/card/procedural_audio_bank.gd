class_name ProceduralAudioBank
extends RefCounted

const SAMPLE_RATE: int = 22050


static func build() -> Dictionary:
	return {
		"ui_focus": _render("ui_focus", 0.055, 0.34, 101),
		"ui_confirm": _render("ui_confirm", 0.11, 0.42, 102),
		"ui_cancel": _render("ui_cancel", 0.13, 0.34, 103),
		"ui_warning": _render("ui_warning", 0.24, 0.40, 104),
		"dialogue": _render("dialogue", 0.065, 0.22, 105),
		"dice_tick": _render("dice_tick", 0.052, 0.42, 201),
		"dice_land": _render("dice_land", 0.14, 0.50, 202),
		"dice_critical": _render("dice_critical", 0.30, 0.43, 203),
		"dice_fumble": _render("dice_fumble", 0.32, 0.42, 204),
		"attack": _render("attack", 0.20, 0.42, 301),
		"heavy": _render("heavy", 0.34, 0.52, 302),
		"guard": _render("guard", 0.28, 0.38, 303),
		"ultimate": _render("ultimate", 0.58, 0.46, 304),
		"hit": _render("hit", 0.18, 0.55, 305),
		"block": _render("block", 0.22, 0.42, 306),
		"miss": _render("miss", 0.17, 0.30, 307),
		"step": _render("step", 0.09, 0.28, 401),
		"intent_attack": _render("intent_attack", 0.24, 0.38, 402),
		"intent_defend": _render("intent_defend", 0.20, 0.34, 403),
		"archive": _render("archive", 0.25, 0.35, 404),
		"room": _render("room", 0.36, 0.34, 405),
		"reward": _render("reward", 0.48, 0.38, 406),
		"victory": _render("victory", 0.78, 0.40, 407),
		"defeat": _render("defeat", 0.68, 0.46, 408)
	}


static func _render(kind: String, duration: float, gain: float, seed_value: int) -> AudioStreamWAV:
	var sample_count := maxi(int(ceil(duration * SAMPLE_RATE)), 1)
	var pcm := PackedByteArray()
	pcm.resize(sample_count * 2)
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value
	var filtered_noise := 0.0
	for i: int in range(sample_count):
		var t := float(i) / float(SAMPLE_RATE)
		var progress := clampf(t / duration, 0.0, 1.0)
		filtered_noise = lerpf(filtered_noise, rng.randf_range(-1.0, 1.0), 0.31)
		var edge := minf(t / 0.0035, 1.0) * minf((duration - t) / 0.008, 1.0)
		var sample := _sample(kind, t, progress, duration, filtered_noise) * gain * edge
		pcm.encode_s16(i * 2, int(round(clampf(sample, -1.0, 1.0) * 32767.0)))

	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = SAMPLE_RATE
	stream.stereo = false
	stream.data = pcm
	return stream


static func _sample(kind: String, t: float, progress: float, duration: float, noise: float) -> float:
	match kind:
		"ui_focus":
			return exp(-t * 36.0) * (_chirp(t, duration, 980.0, 620.0) * 0.78 + noise * 0.16)
		"ui_confirm":
			return exp(-t * 22.0) * (sin(TAU * 310.0 * t) * 0.48 + sin(TAU * 970.0 * t) * 0.28 + noise * 0.20)
		"ui_cancel":
			return exp(-t * 17.0) * (_chirp(t, duration, 220.0, 82.0) * 0.72 + noise * 0.14)
		"ui_warning":
			return _pulse(t, 0.0, 82.0, 11.0) * 0.62 + _pulse(t, 0.105, 74.0, 12.0) * 0.54
		"dialogue":
			return exp(-t * 48.0) * (sin(TAU * 710.0 * t) * 0.50 + noise * 0.28)
		"dice_tick":
			return exp(-t * 47.0) * (_chirp(t, duration, 1580.0, 720.0) * 0.52 + noise * 0.42)
		"dice_land":
			return exp(-t * 24.0) * (sin(TAU * 92.0 * t) * 0.55 + sin(TAU * 530.0 * t) * 0.30 + noise * 0.28)
		"dice_critical":
			return _note(t, 0.0, 880.0, 11.0) * 0.48 + _note(t, 0.072, 1320.0, 9.5) * 0.42 + _note(t, 0.145, 1760.0, 8.0) * 0.28
		"dice_fumble":
			return sin(PI * progress) * _chirp(t, duration, 260.0, 48.0) * 0.70 + exp(-t * 14.0) * noise * 0.16
		"attack":
			return sin(PI * progress) * (noise * 0.68 + _chirp(t, duration, 1180.0, 150.0) * 0.24)
		"heavy":
			var impact := _pulse(t, duration * 0.64, 68.0, 20.0)
			return sin(PI * progress) * (noise * 0.48 + _chirp(t, duration, 720.0, 62.0) * 0.38) + impact * 0.55
		"guard":
			return sin(PI * progress) * (_chirp(t, duration, 260.0, 690.0) * 0.52 + _chirp(t, duration, 520.0, 1030.0) * 0.25) + exp(-t * 13.0) * noise * 0.10
		"ultimate":
			var release := _pulse(t, duration * 0.66, 54.0, 10.0)
			return sin(PI * progress) * (_chirp(t, duration, 52.0, 250.0) * 0.62 + sin(TAU * 440.0 * t) * progress * 0.18) + release * 0.60
		"hit":
			return exp(-t * 18.0) * (sin(TAU * 72.0 * t) * 0.60 + sin(TAU * 148.0 * t) * 0.24 + noise * 0.40)
		"block":
			return exp(-t * 14.0) * (sin(TAU * 740.0 * t) * 0.42 + sin(TAU * 1160.0 * t) * 0.28 + sin(TAU * 1810.0 * t) * 0.16 + noise * 0.13)
		"miss":
			return sin(PI * progress) * (noise * 0.35 + _chirp(t, duration, 900.0, 240.0) * 0.22)
		"step":
			return exp(-t * 38.0) * (sin(TAU * 86.0 * t) * 0.55 + noise * 0.42)
		"intent_attack":
			return _pulse(t, 0.0, 94.0, 16.0) * 0.64 + _pulse(t, 0.095, 82.0, 17.0) * 0.55
		"intent_defend":
			return exp(-t * 14.0) * (sin(TAU * 620.0 * t) * 0.42 + sin(TAU * 970.0 * t) * 0.25 + noise * 0.13)
		"archive":
			var latch := _pulse(t, duration * 0.62, 310.0, 24.0)
			return sin(PI * progress) * noise * 0.34 + latch * 0.48 + _note(t, duration * 0.64, 920.0, 18.0) * 0.18
		"room":
			return exp(-t * 8.0) * (sin(TAU * 54.0 * t) * 0.60 + sin(TAU * 81.0 * t) * 0.22 + noise * 0.10)
		"reward":
			return _note(t, 0.0, 440.0, 7.0) * 0.42 + _note(t, 0.105, 660.0, 6.5) * 0.36 + _note(t, 0.225, 990.0, 5.5) * 0.27
		"victory":
			return _note(t, 0.0, 330.0, 4.5) * 0.34 + _note(t, 0.14, 495.0, 4.2) * 0.34 + _note(t, 0.29, 660.0, 3.8) * 0.32 + _note(t, 0.45, 990.0, 3.4) * 0.22
		"defeat":
			return sin(PI * progress) * (_chirp(t, duration, 185.0, 42.0) * 0.68 + sin(TAU * 61.0 * t) * 0.20) + exp(-t * 4.0) * noise * 0.08
		_:
			return 0.0


static func _chirp(t: float, duration: float, start_hz: float, end_hz: float) -> float:
	var slope := (end_hz - start_hz) / maxf(duration, 0.001)
	return sin(TAU * (start_hz * t + 0.5 * slope * t * t))


static func _pulse(t: float, start_time: float, frequency: float, decay: float) -> float:
	if t < start_time:
		return 0.0
	var local_time := t - start_time
	return sin(TAU * frequency * local_time) * exp(-local_time * decay)


static func _note(t: float, start_time: float, frequency: float, decay: float) -> float:
	if t < start_time:
		return 0.0
	var local_time := t - start_time
	var onset := minf(local_time / 0.006, 1.0)
	return sin(TAU * frequency * local_time) * exp(-local_time * decay) * onset
