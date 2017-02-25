
CollisionManager.__cname = "CollisionManager"

CollisionManager._collisionLayer = nil

function CollisionManager:init(layer)
	local contactListener = cc.EventListenerPhysicsContact:create()
	contactListener:registerScriptHandler(function (...) return self:onContactBegin(...) end,
                                            cc.Handler.EVENT_PHYSICS_CONTACT_BEGIN)
	contactListener:registerScriptHandler(function (...) return self:onContactPreSolve(...) end,
                                            cc.Handler.EVENT_PHYSICS_CONTACT_PRESOLVE)
    contactListener:registerScriptHandler(function (...) self:onContactPostSolve(...) end,
                                            cc.Handler.EVENT_PHYSICS_CONTACT_POSTSOLVE)
    contactListener:registerScriptHandler(function (...) self:onContactSeperate(...) end,
                                            cc.Handler.EVENT_PHYSICS_CONTACT_SEPARATE)
	EventDispatcher:addEventListenerWithSceneGraphPriority(contactListener, layer)
    self._collisionLayer = layer
	return self
end

function CollisionManager:dtor(...)
    -- DM:removeValue("CollisionLayer")
end

function CollisionManager:onContactBegin(contact)
    --print("onContactBegin")
    return true
end

function CollisionManager:onContactPreSolve(contact)
    local nodeA = contact:getShapeA():getBody():getNode()
    local nodeB = contact:getShapeB():getBody():getNode()
    local function deal(node)
        if node and node.__cname == "Bullet" then
            node:removeFromParent()
        end
    end
    deal(nodeA)
    deal(nodeB)
    return true
end

function CollisionManager:onContactPostSolve(contact)
    -- print("onContactPostSolve")
end

function CollisionManager:onContactSeperate(contact)

end

CM = CollisionManager
