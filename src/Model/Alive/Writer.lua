
Writer = class("Writer", Player)

Writer._bodyShape = {shape = "rect", value = {width = 15, height = 26}}

-- 存储动画
Writer._animPool = {}
Writer._preAnimName = "" -- 缓存动画名
-- 状态机
Writer.StateMachine = nil

local ANIM_PREFIX = "PlayerWriter"

Writer._isAttacking = false  -- 攻击开始设为true,结束设为false


local frameCache = cc.SpriteFrameCache:getInstance()

function Writer:ctor(args)
	Writer.super.ctor(self, args)
	--AM:addAnimation(self._spLeg, 'PlayerWriterLeg', true)
	AM:addAnimation(self._spBody, 'PlayerWriterWalkUnarmed', true)
	self._weapon = Weapon.Punch.new()
	self:addChild(self._weapon)
	self:initStateMachine()
end

function Writer:initStateMachine()
	local StateMachine = require("Manager.StateMachine").new()
	StateMachine:setupState({
		initial = "idle",
		events = {
			-- Event: Walk
			{name = "Walk", from = "idle", to = "walk"},
			{name = "Walk", from = "attacking", to = "walk"},
			{name = "Walk", from = "attack", to = "walk"},
			-- Event: Idle
			{name = "Idle", from = "walk", to = "idle"},
			{name = "Idle", from = "attack", to = "idle"},
			{name = "Idle", from = "attacking", to = "idle"},
			{name = "Idle", from = "pickup", to = "idle"},
			-- Event: Turn
			{name = "Turn", from = "walk", to = "turn"},
			{name = "Turn", from = "idle", to = "turn"},
			-- Event: attack
			{name = "Attack", from = "turn", to = "attack"},
			{name = "Attacking", from = "attack", to = "attacking"},
			-- Event: Pickup
			{name = "Pickup", from = "idle", to = "pickup"},
			{name = "Pickup", from = "walk", to = "pickup"}
		},
		callbacks = {
			onbeforeWalk      = function(event) end,
			onbeforeIdle      = function(event) end,
			onbeforeTurn      = function(event) end,
			onbeforePickup    = function(event) end,
			onbeforeAttack    = function(event) end,
			onbeforeAttacking = function(event) end,

			onleaveidle   =	function(event)
								self._spBody:stopAllActions()
							end,
			onleavewalk   =	function(event)
								self._spBody:stopAllActions()
								AM:pauseAnimation(self._spLeg)
							end,
			onleaveturn   =	function(event) end,
			onleavepickup = function(event) end,
			onleaveattack =	function(event)
								self._spBody:stopAllActions()
							end,
			onleaveattacking =	function(event)
									self._spBody:stopAllActions()
								end,

			onwalk   =	function(event)
							self:runWalkAnim()
						end,
			onidle   =	function(event)
							if event.from == "none" then
								self:runIdleAnim(true)
							else
								self:runIdleAnim(false)
							end
						end,
			onturn   =	function(event)
							local tarPoint = event.args[1]
							if tarPoint.x and tarPoint.y then
								self:turnToPoint(tarPoint)
							end
						end,
			onpickup =	function(event)
							if not event.args[1] then 
								print("onpickup: invalid argument") 
								return 
							end
							local wpnList = DM:getValue("LandedWeapons")
							local ndWeapon = wpnList[event.args[1]]
							-- 丢弃原先的武器
							if self._weapon and self._weapon.__cname ~= "Punch" then
								-- 切换weapon父节点
								self._weapon:retain()
								self._weapon:removeFromParent()
								DM:getValue("LandLayer"):addChild(self._weapon)
    							wpnList[#wpnList + 1] = self._weapon
								self._weapon:throw(cc.p(self:getPosition()), self:getRotation())
								self._weapon = nil
							end
							if ndWeapon then
								-- 捡起现在的武器
								-- 切换weapon父节点
								ndWeapon:retain()
								ndWeapon:removeFromParent()
								self:addChild(ndWeapon)
				    			ndWeapon:pickedUp()
    							table.remove(wpnList, event.args[1])
								if event.from == "walk" then
									self._weapon = ndWeapon
									self:endFollow()
								elseif event.from == "idle" then
									self._weapon = ndWeapon
									self.StateMachine:doEvent("Idle")
								end
							end
						end,
			onattack =	function(event)
							self:runAttackAnim()
						end,
			onattacking  =	function(event)
								self:runAttackAnim(true)
							end,

			onIdle   = function(event) end,
			onWalk   = function(event) end,
			onTurn   = function(event) end,
			onPickup = function(event) end,
			onAttack = function(event) end,
			onAttacking = function(event) end,
		}
	})
	self.StateMachine = StateMachine
end

function Writer:startAttack(touchPoint)
	-- self._weapon = "Nmm"
	if self.StateMachine:canDoEvent("Turn") then
		self.StateMachine:doEvent("Turn", touchPoint)
		local entry
		-- 攻击状态切换定时器(turn -> attack --> attacking)
		entry =	Scheduler:scheduleScriptFunc(function()
					-- Turn动画执行完之后进行攻击
					if self.StateMachine:getState() == "turn" and
					   self:getNumberOfRunningActions() == 0 then
						self.StateMachine:doEvent("Attack")
					elseif self.StateMachine:getState() == "attack" and
						   self._spBody:getNumberOfRunningActions() == 0 then
						-- attack到attacking的转换
						if entry then
							Scheduler:unscheduleScriptEntry(entry)
						end
						-- attack动画播放结束还没有调用endAttack()，则转换为attacking状态
						if self._isAttacking == true then
							self.StateMachine:doEvent("Attacking")
						end
					end

				end, 0, false)
		self._isAttacking = true
		return true
	else
		return false
	end
end

function Writer:updateAttack(touchPoint)
	self.updateAttackCallback = updateAttackCallback
	self.super.updateAttack(self, touchPoint)
end

function Writer:endAttack()
	self._isAttacking = false
	local state = self.StateMachine:getState()
	if state == "attacking" then
		self.StateMachine:doEvent("Idle")
	else
		-- 攻击结束检测定时器，结束后切换到idle状态
		local entry
		entry = Scheduler:scheduleScriptFunc(function()
					local state = self.StateMachine:getState()
					if state == "attack" and self._spBody:getNumberOfRunningActions() == 0 then
						if entry then
							Scheduler:unscheduleScriptEntry(entry)
						end
						self.StateMachine:doEvent("Idle")
					end
				end, 0, false)
	end
end

function Writer:startFollow(touchPoint)
	self.super.startFollow(self, touchPoint)
    -- change to state walk
    self.StateMachine:doEvent("Walk")
end

function Writer:updateFollow(touchPoint)
	self.super.updateFollow(self, touchPoint)
end

function Writer:endFollow()
	self.super.endFollow(self)
    -- change to state idle
    self.StateMachine:doEvent("Idle")
end

local function getWalkAnimName(wepName)
	local animName
	if wepName == "Punch" then
		animName = "PlayerWriterWalkUnarmed"
	else
		animName = "PlayerWriterWalk" .. wepName
	end
	return animName
end

function Writer:runWalkAnim()
	-- run body anim
	local animName = getWalkAnimName(self._weapon.__cname)
	if animName then
		AM:addAnimation(self._spBody, animName, true)
	end
	AM:runAnimation(self._spBody)
	-- run leg anim
	if self._spLeg:getNumberOfRunningActions() == 0 then
		AM:addAnimation(self._spLeg, 'PlayerWriterLeg', true)
	end
	AM:runAnimation(self._spLeg)
end

function Writer:runIdleAnim(needInit)
	if needInit then
		local plistName = "Atlases/Player/Writer/PlayerWriter.plist"
		AM:addPlistToFrameCache(plistName)
	end
	local animName = getWalkAnimName(self._weapon.__cname)
	AM:addAnimation(self._spBody, animName, true)
end

-- 更新self._animation中的动画
local isFirstAttack = true
function Writer:runAttackAnim(loop)
	loop = loop or false
	local animName = "PlayerWriterAttack" .. self._weapon.__cname
	-- loop == false则播放一次之后就会被释放掉
	AM:addAnimation(self._spBody, animName, loop)
	-- 需要反转X轴获得第二个动画
	if self._weapon._type == "Melee" then
		-- 切换动画1和动画2
		if isFirstAttack then
			-- self._spBody:setFlippedY(true)
			self._spBody:setScaleY(-1)
			isFirstAttack = false
		else
			-- self._spBody:setFlippedY(false)
			self._spBody:setScaleY(1)
			isFirstAttack = true
		end
	end
	AM:runAnimation(self._spBody)
end

function Writer:pickupWeapon(touchPoint)
	if self.StateMachine:cannotDoEvent("Pickup") then
		return false
	end
	local lcTouchPoint = DM:getValue("LandLayer"):convertToNodeSpace(touchPoint)
	local selfPoint = cc.p(self:getPosition())
    local wpnList = DM:getValue("LandedWeapons")
    wpnList = wpnList or {}
    -- 获得TouchPoint临近的一个武器
    local wpnNearby
    for i, spWpn in ipairs(wpnList) do
        local dst = cc.pDistanceSQ(lcTouchPoint, cc.p(spWpn:getPosition()))
        if dst <= 225 then
            wpnNearby = {index = i, tar = spWpn}
            break
        end
    end
    if wpnNearby then
    	local dst2wp = cc.pDistanceSQ(selfPoint, cc.p(wpnNearby.tar:getPosition()))
    	-- 距离太远则需要走过去
    	if dst2wp >= 225 then
    		self:startFollow(touchPoint)
    		local entry
    		entry = Scheduler:scheduleScriptFunc(function()
    					local v = self:getPhysicsBody():getVelocity()
    					local absV
    					if v then
    						absV = cc.pLengthSQ(v)
    					end
    					if absV < 4 then
    						if entry then
    							Scheduler:unscheduleScriptEntry(entry)
    						end
    						self.StateMachine:doEvent("Pickup", wpnNearby.index)
    					end
    				end, 0, false)
    	else
    		self.StateMachine:doEvent("Pickup", wpnNearby.index)
    	end
    	return true
    end
    return false
end
