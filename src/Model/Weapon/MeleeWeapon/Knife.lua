
local Knife = class("Knife", Weapon.MeleeWeapon)

function Knife:ctor(...)
	Knife.super.ctor(self, ...)
	self._imgName = "Atlases/Weapon/Knife.png"
	return self
end

Weapon.Knife = Knife