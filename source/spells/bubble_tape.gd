extends Spell

func is_coop_enabled() -> bool:
	return ModLoader.mods.any(func (mod:Mod)->bool:return mod.id=="co-op")

const FIBONACCI_NUMBERS = [0, 1, 1, 2, 3, 5, 8, 13, 21]
