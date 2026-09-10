extends Spell

func is_coop_enabled() -> bool:
	return ModLoader.mods.any(func (mod:Mod)->bool:return mod.id=="co-op")
