
local RangeWeapon = class("RangeWeapon", Weapon.BaseWeapon)

RangeWeapon._type = "Range"

function RangeWeapon:ctor(...)
	RangeWeapon.super.ctor(self, ...)
	return self
end

function RangeWeapon:dtor(...)
	-- body
end

function RangeWeapon:createBullet(degree)
	if not degree then
		print("RangeWeapon:createBullet: invalid argument")
		return
	end
	local bullet = Bullet.new("Yellow")
	bullet:setRotation(degree)
	-- 父子关系：LandLayer --> Alive --> Weapon
	local pos = self:getBulletPos()
	bullet:setPosition(pos)
	local body = bullet:getPhysicsBody()
	local velocity = self:getBulletVelocity(degree)
	body:setVelocity(velocity)
	DM:getValue("LandLayer"):addChild(bullet, 30)
end

function RangeWeapon:getBulletVelocity(d)
	if d == nil then
		print("RangeWeapon:getBulletVelocity: invalid argument")
		return
	end
	local speed = 30
	return cc.p(speed * math.cos(math.rad(d)), -speed * math.sin(math.rad(d)))
end

function RangeWeapon:getBulletPos()
	local basePos = cc.p(self:getParent():getPosition())
	local r = 20
	local d = self:getParent():getRotation()
	local delPos = cc.p(r * math.cos(math.rad(d)), -r * math.sin(math.rad(d)))
	return cc.pAdd(basePos, delPos)
end

Weapon.RangeWeapon = RangeWeapon