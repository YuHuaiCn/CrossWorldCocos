
local M16 = class("M16", Weapon.RangeWeapon)

function M16:ctor(...)
	M16.super.ctor(self, ...)
	self._imgName = "Atlases/Weapon/M16.png"
	return self
end

Weapon.M16 = M16