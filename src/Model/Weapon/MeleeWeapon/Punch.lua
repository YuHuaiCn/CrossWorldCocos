
local Punch = class("Punch", Weapon.MeleeWeapon)

function Punch:ctor(...)
	Punch.super.ctor(self, ...)
	self._imgName = nil
	return self
end

function Punch:runAnimLandedWeapon()

end


Weapon.Punch = Punch