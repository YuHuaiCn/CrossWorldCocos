
local MeleeWeapon = class("MeleeWeapon", Weapon.BaseWeapon)

MeleeWeapon._type = "Melee"

function MeleeWeapon:ctor(...)
	MeleeWeapon.super.ctor(self, ...)
	return self
end

function MeleeWeapon:dtor(...)
	-- body
end

Weapon.MeleeWeapon = MeleeWeapon