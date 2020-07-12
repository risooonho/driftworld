extends Node

const hints = {
	"directive": ["destroy the enemy base"],
	"safety": ["there is safety in numbers"],
	"drifters": ["the drifters grow stronger", "they are against you"],
}

var seen = {}

func show_hint(ui, key):
	if key in seen:
		return
	for text in hints[key]:
		ui.show_message(text)
		yield(ui, "message_complete")
	seen[key] = true