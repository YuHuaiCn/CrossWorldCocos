
local RangeWeapon = class("RangeWeapon", Weapon.BaseWeapon)

RangeWeapon._type = "Range"

function RangeWeapon:ctor(...)
	RangeWeapon.super.ctor(self, ...)
	return self
end

function RangeWeapon:dtor(...)
	-- body
end

Weapon.RangeWeapon = RangeWeapon