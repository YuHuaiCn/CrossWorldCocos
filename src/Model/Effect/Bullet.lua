
local Bullet = class("Bullet", function(bullet)
					local path
					if bullet == "Black" or bullet == "black" then
						path = "Atlases/Effect/Bullet/Black.png"
					elseif bullet == "Yellow" or bullet == "yellow" then
						path = "Atlases/Effect/Bullet/Yellow.png"
					else
						path = "Atlases/Effect/Bullet/Black.png"
					end
					return cc.Sprite:create(path)
				end)

local BULLET_MATERIAL = {density = 1, friction = 0, restitution = 0}

function Bullet:ctor(...)
	local body = cc.PhysicsBody:createBox(self:getContentSize(), BULLET_MATERIAL)
    body:setContactTestBitmask(PhysicsMask.BULLET_CONTACT_MASK)
    body:setCategoryBitmask(PhysicsMask.BULLET_CATEGORY_MASK)
    body:setCollisionBitmask(PhysicsMask.BULLET_COLLISION_MASK)
    body:setLinearDamping(0)
    body:setAngularDamping(PHYSICS_INFINITY)
    body:setMoment(PHYSICS_INFINITY)
    self:setPhysicsBody(body)
end

cc.exports.Bullet = Bullet
