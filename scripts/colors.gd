extends Node

enum TYPE {
	PLAYER,
	ENEMY,
	NEUTRAL,
	DEFECTOR,
}

const COLORS = {
	TYPE.PLAYER: Color(0, 0.85, 0.85, 1),
	TYPE.ENEMY: Color(0.85, 0.15, 0, 1),
	TYPE.NEUTRAL: Color(0.6, 0.6, 0.6, 1),
	TYPE.DEFECTOR: Color(0.8, 0.1, 0.8, 1),
}