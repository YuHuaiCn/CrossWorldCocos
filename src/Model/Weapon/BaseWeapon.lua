
local BaseWeapon = class("BaseWeapon", function (...)
	return cc.Node:create(...)
end)

BaseWeapon._imgName = nil
BaseWeapon._spBody = nil
BaseWeapon._spBackground = nil

local WEAPON_MATERIAL = {density = 0.1, friction = 0, restitution = 0.5}
local WEAPON_CONTACT_MASK   = 0x0
local WEAPON_CATEGORY_MASK  = 0x2
local WEAPON_COLLISION_MASK = 0x8

local frameCache = cc.SpriteFrameCache:getInstance()

function BaseWeapon:ctor(...)
	return self
end

function BaseWeapon:dtor(...)
	
end

-- 武器躺在地上稳定后调用
function BaseWeapon:runAnimLandedWeapon()
	local spriteFrame = frameCache:getSpriteFrame(self._imgName)
	if not spriteFrame then
		AM:addImgToCache("Weapon")
		spriteFrame = frameCache:getSpriteFrame(self._imgName)
	end
	local posX, posY = self:getPosition()
	-- print(posX .. " " .. posY)
	local bg = cc.Sprite:createWithSpriteFrame(spriteFrame)
	self:addChild(bg, -1, "Background")
	self._spBackground = bg
	if not self._spBody then
		local spBody = cc.Sprite:createWithSpriteFrame(spriteFrame)
		self:addChild(spBody, -1, "Body")
		self._spBody = spBody
	end
	-- AM:runAnimLandedWeapon(self)
end

function BaseWeapon:addPhysicsBody()
	local spriteFrame = frameCache:getSpriteFrame(self._imgName)
	if not spriteFrame then
		AM:addImgToCache("Weapon")
		spriteFrame = frameCache:getSpriteFrame(self._imgName)
	end
	local contSize = spriteFrame:getRect()
	local body = cc.PhysicsBody:createBox(contSize, WEAPON_MATERIAL)
	body:setContactTestBitmask(WEAPON_CONTACT_MASK)
	body:setCategoryBitmask(WEAPON_CATEGORY_MASK)
	body:setCollisionBitmask(WEAPON_COLLISION_MASK)
	body:setLinearDamping(0.1)
	body:setAngularDamping(0.1)
	self:setPhysicsBody(body)
	local spBody = cc.Sprite:createWithSpriteFrame(spriteFrame)
	self:addChild(spBody, 10, "Body")
	self._spBody = spBody
end

function BaseWeapon:stopAnimLandedWeapon()
	self:removeChildByName("Background")
	self:removeChildByName("Body")
end

function BaseWeapon:pickedUp()
	self:removeChildByName("Background")
	self:removeChildByName("Body")
	local body = self:getPhysicsBody()
	if body then
		body:removeFromWorld()
		self:removeComponent(body)
	end
		-- self:removeAllComponents()
end

-- r为x轴顺时针到面朝方向的夹角(角度)
function BaseWeapon:throw(pos, d)
	if pos.x == nil or pos.y == nil or d == nil then
		print("BaseWeapon:throw: invalid argument")
		return
	end
	local velocity = self:getThrowVelocity(d)
	self:addPhysicsBody()
	print(pos.x .. " " .. pos.y)
	self:setPosition(pos)
	local pyBody = self:getPhysicsBody()
	pyBody:setVelocity(velocity)
	local entry
	entry = Scheduler:scheduleScriptFunc(function()
				local v = pyBody:getVelocity()
				if v.x < 0.01 and v.y < 0.01 then
					if entry then
						Scheduler:unscheduleScriptEntry(entry)
					end
					self:runAnimLandedWeapon()
				end
			end, 0, false)
end

function BaseWeapon:getThrowVelocity(d)
	if d == nil then
		print("BaseWeapon:getThrowVelocity: invalid argument")
		return
	end
	return cc.p(20 * math.cos(math.rad(d)), -20 * math.sin(math.rad(d)))
end

function BaseWeapon:addToLandedWeapons()
	-- 存储武器信息
	local posX, posY = self:getPosition()
	local wpnList = DM:getValue("LandedWeapons")
	if not wpnList then
		wpnList = {}
		wpnList[1] = self
		DM:storeValue("LandedWeapons", wpnList)
	else
		wpnList[#wpnList + 1] = self
	end
end

Weapon.BaseWeapon = BaseWeapon