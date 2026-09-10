extends Resource
class_name BubbleTapeSection

enum Target {
	WORD_LONG,
	WORD_SHORT,
	TILE_STATUS,
	TILE_EFFECT,
	TILE,
	GAME_STATE,
}

enum Section {
	CLAUSE,
	EFFECT,
	SELF_CONTAINED_CLAUSE
}

@export var section_type: Section
@export var target: Target
