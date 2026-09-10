extends Resource
class_name BubbleTapeSection

enum Target {
	WORD_LONG,
	WORD_SHORT,
	LETTER,
	TILE_STATUS,
	TILE_EFFECT,
	TILE,
	GAME_STATE,
}

enum Section {
	CLAUSE,
	EFFECT
}


@export var strength := 1
@export var section_type: Section
@export var target: Target
