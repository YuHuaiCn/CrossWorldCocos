
local Nmm = class("Nmm", Weapon.RangeWeapon)

function Nmm:ctor(...)
	Nmm.super.ctor(self, ...)
	self._imgName = "Atlases/Weapon/9mm.png"
	return self
end

Weapon.Nmm = Nmm