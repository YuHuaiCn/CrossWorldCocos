
local FirstBloodScene = class("FirstBloodScene", Levels.BaseScene)

function FirstBloodScene:ctor()
	self.super.ctor(self, "res/Maps/Test/TestLevel.tmx")
	self._landLayer:setScale(2)
	self:test()
end

function FirstBloodScene:dtor()
	DM:removeValue("PhysicsWorld")
end

function FirstBloodScene:test()
	-- run anim
	local sprWriter = Writer.new()
	sprWriter:setPosition(480, 100)
	local landLayer = DM:getValue("LandLayer")
	landLayer:addChild(sprWriter, 10)
	FC:initCamera(landLayer, sprWriter)
	DM:storeValue("CurrentHero", sprWriter)
	-- add Weapon
	local spr9mm = Weapon.Nmm.new()
	spr9mm:addPhysicsBody()
	spr9mm:setPosition(530, 100)
	spr9mm:setRotation(60)
	spr9mm:runAnimLandedWeapon()
	spr9mm:addToLandedWeapons()
	landLayer:addChild(spr9mm, 9)
	-- add Weapon2
	local sprM16 = Weapon.M16.new()
	sprM16:addPhysicsBody()
	sprM16:setPosition(500, 120)
	sprM16:setRotation(115)
	sprM16:runAnimLandedWeapon()
	sprM16:addToLandedWeapons()
	landLayer:addChild(sprM16, 9)
	-- add Weapon3
	local sprKnife = Weapon.Knife.new()
	sprKnife:addPhysicsBody()
	sprKnife:setPosition(500, 90)
	sprKnife:setRotation(30)
	sprKnife:runAnimLandedWeapon()
	sprKnife:addToLandedWeapons()
	landLayer:addChild(sprKnife, 9)
end

Levels.FirstBloodScene = FirstBloodScene
