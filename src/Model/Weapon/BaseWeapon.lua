
local BaseWeapon = class("BaseWeapon", function (...)
	return cc.Node:create(...)
end)

BaseWeapon._imgName = nil
BaseWeapon._spBody = nil
BaseWeapon._spBackground = nil

local WEAPON_MATERIAL = {density = 0.1, friction = 0, restitution = 1}
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
	local bg = cc.Sprite:createWithSpriteFrame(spriteFrame)
	self:addChild(bg, -1, "Background")
	self._spBackground = bg
	if not self._spBody then
		local spBody = cc.Sprite:createWithSpriteFrame(spriteFrame)
		self:addChild(spBody, 1, "Body")
		self._spBody = spBody
	end
	AM:runAnimLandedWeapon(self)
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
	self:addChild(spBody, 1, "Body")
	self._spBody = spBody
end

function BaseWeapon:pickedUp(alive)
	-- 切换父节点
	self:retain()
	self:removeFromParent()
	alive:addChild(self)
	-- 从LandedWeapons中删除
	local wpnList = DM:getValue("LandedWeapons")
	if wpnList then
		for i, v in ipairs(wpnList) do
			if v == self then
				table.remove(wpnList, i)
			end
		end
	end
	-- 删除子节点和PhysicsBody
	self:removeChildByName("Background")
	self:removeChildByName("Body")
	local body = self:getPhysicsBody()
	if body then
		self:removeComponent(body)
	end
end

-- 修复：武器有时会被扔出墙
-- d为x轴顺时针到面朝方向的夹角(角度)
function BaseWeapon:throw(alive)
	if not alive then
		print("BaseWeapon:throw: invalid argument")
		return
	end
	local pos = cc.p(alive:getPosition())
	local d = alive:getRotation()
	if pos.x == nil or d == nil then
		print("BaseWeapon:throw: invalid argument")
		return
	end
	-- 切换weapon父节点
	alive._weapon:retain()
	alive._weapon:removeFromParent()
	DM:getValue("LandLayer"):addChild(alive._weapon)
	self:setRotation(0) -- 必须初始化，否则添加PhysicsBody会出错
	local velocity = self:getThrowVelocity(d)
	self:addPhysicsBody()
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
					local wpnList = DM:getValue("LandedWeapons")
					wpnList[#wpnList + 1] = self
					self:runAnimLandedWeapon()
				end
			end, 0, false)
end

function BaseWeapon:getThrowVelocity(d)
	if d == nil then
		print("BaseWeapon:getThrowVelocity: invalid argument")
		return
	end
	return cc.p(30 * math.cos(math.rad(d)), -30 * math.sin(math.rad(d)))
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