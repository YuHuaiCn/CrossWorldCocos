
Alive = class("Alive", function (...)
    return cc.Node:create(...)
end)

local PI = math.pi

Alive._health            = 100         -- point
Alive._walkSpeed         = 3           -- m/s
Alive._runSpeed          = 6           -- m/s
Alive._turnSpeed         = 3 * PI      -- r/s
Alive._reactionTime      = 0.5         -- s
Alive._alertReactionTime = 0.3         -- s
Alive._moveInertialTime  = 0.3	       -- s time cost from static to move and move to static
Alive._viewDist          = 20          -- m
Alive._viewAngle         = PI / 2      -- radian

Alive.MoveType = {
	WALK = 1,
	RUN  = 2,
}

function Alive:ctor(args)
	if type(args) ~= 'table' then
		return
	end
	for k, v in pairs(args) do
		self[k] = v
	end
end

function Alive:hurt(nDamage)
	_health = _health - nDamage
	if _health <= 0 then
		_health = 0
		self:dying()
	end
end

function Alive:dying()
	
end

function Alive:setHealth(nHealth)
	self._health = nHealth
end

function Alive:getHealth()
	return self._health
end

function Alive:setWalkSpeed(nWalkSpeed)
	self._walkSpeed = nWalkSpeed
end

function Alive:getWalkSpeed( )
	return self._walkSpeed
end

function Alive:setRunSpeed(nRunSpeed)
	self._runSpeed = nRunSpeed
end

function Alive:getRunSpeed( )
	return self._runSpeed
end

function Alive:setTurnSpeed(nTurnSpeed)
	self._turnSpeed = nTurnSpeed
end

function Alive:getTurnSpeed()
	return self._turnSpeed
end

function Alive:setReactionTime(nReactionTime)
	self._reactionTime = nReactionTime
end

function Alive:getReactionTime()
	return self._reactionTime
end

function Alive:setAlertReactionTime(nAlertReactionTime)
	self._alertReactionTime = nAlertReactionTime
end

function Alive:getAlertReactionTime()
	return self._alertReactionTime
end

function Alive:setViewDist(nViewDist)
	self._viewDist = nViewDist
end

function Alive:getViewDist()
	return self._viewDist
end

function Alive:setViewAngle(nViewAngle)
	self._viewAngle = nViewAngle
end

function Alive:getViewAngle()
	return self._viewAngle
end
