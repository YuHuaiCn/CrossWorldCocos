
local BaseScene = class("BaseScene", function (...)
	local scene = cc.Scene:createWithPhysics()
	local world = scene:getPhysicsWorld()
	--world:setDebugDrawMask(cc.PhysicsWorld.DEBUGDRAW_ALL)
	world:setSpeed(50)
	scene:getPhysicsWorld():setGravity(cc.p(0, 0))
	DM:storeValue("PhysicsWorld", world)
	return scene
end)

BaseScene._landLayer = nil

function BaseScene:ctor(tmxMap)
	local landLayer = cc.Layer:create()
	local map = TMM:createMap(tmxMap, landLayer)
	FollowController:init(landLayer)
	CollisionManager:init(landLayer)
	local mapSize = map:getMapSize()
	local tileSize = map:getTileSize()
	local size = {width = mapSize.width * tileSize.width + VisibleSize.width,
					height = mapSize.height * tileSize.height + VisibleSize.height}
	local body = cc.PhysicsBody:createEdgeBox(size, {density = 1.0, friction = 0.5, restitution = 1.0})
	local edgeNode = cc.Node:create()
	edgeNode:setPosition(cc.p(VisibleSize.width / 2, VisibleSize.height / 2))
	edgeNode:setPhysicsBody(body)
	landLayer:addChild(edgeNode)
	landLayer:addChild(map)
	self:addChild(landLayer)
	self._landLayer = landLayer
	DM:storeValue("LandLayer", landLayer)
end

function BaseScene:dtor()
	DM:removeValue("LandLayer", landLayer)
end

Levels.BaseScene = BaseScene