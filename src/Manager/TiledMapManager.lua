
TiledMapManager.__cname = "TiledMapManager"

local WALL_CONTACT_MASK   = 0x100
local WALL_CATEGORY_MASK  = 0xFF
local WALL_COLLISION_MASK = 0xFF

function TiledMapManager:getInstance(...)
    if TiledMapManager._instance == nil then
        TiledMapManager._instance = TiledMapManager:ctor(...)
    end
    return TiledMapManager._instance
end

function TiledMapManager:ctor(...)
    return self
end

function TiledMapManager:createMap(name, layer)
	if not name then
		return
	end
	local map = cc.TMXTiledMap:create(name)
	self:initMap(map, layer)
	return map
end

function TiledMapManager:initMap(map, layer)
	local group = map:getObjectGroup("objects")
	local objects = group:getObjects()
	for _, obj in ipairs(objects) do
		if obj._unpassable then
			local shape = obj._shape
			shape = shape or "rect"
			local width = obj.width
			local height = obj.height
			local ndObj = cc.Node:create()
			local body
			if shape == "rect" then
				body = cc.PhysicsBody:createBox({width = width, height = height})
			elseif shape == "circle" then
				body = cc.PhysicsBody:createCircle(width / 2)
			end
			body:setMass(PHYSICS_INFINITY)
	    	body:setContactTestBitmask(WALL_CONTACT_MASK)
	    	body:setCategoryBitmask(WALL_CATEGORY_MASK)
	    	body:setCollisionBitmask(WALL_COLLISION_MASK)
	    	body:setMoment(PHYSICS_INFINITY)
			ndObj:setPhysicsBody(body)
			ndObj:setPosition(obj.x + obj.width / 2, obj.y + obj.height / 2)
			layer:addChild(ndObj)
		end
	end
end

TMM = TiledMapManager
