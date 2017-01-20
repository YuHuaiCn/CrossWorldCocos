
StickController._ControlLayer = nil
StickController._SpCirele     = nil
StickController._SpStick      = nil
StickController._orgCenter    = nil
StickController._curCenter    = nil
StickController._cirRadious   = nil
StickController._stkRadious   = nil
StickController._touchRect    = {x = 0, y = 0, width = DesignSize.height / 2, height = DesignSize.height / 2}

local PointType = {
    NULL   = 0,
    ATTACK = 1,
    STICK  = 2,
}

function StickController:init(scene)
    local controlLayer = cc.CSLoader:createNode("Ui/StickControllerLayer.csb")
    scene:addChild(controlLayer, 50)
    self._ControlLayer = controlLayer
    self._SpCirele = controlLayer:getChildByName("SP_Circle")
    self._SpStick = controlLayer:getChildByName("SP_Stick")
    self._SpCirele:setOpacity(77)
    self._SpStick:setOpacity(77)
    self._orgCenter = cc.p(self._SpCirele:getPosition())
    self._cirRadious = self._SpCirele:getContentSize().width * self._SpCirele:getScaleX() * 0.5
    self._stkRadious = self._SpStick:getContentSize().width * self._SpStick:getScaleX() * 0.5
	local oneByOneListener = cc.EventListenerTouchOneByOne:create()
	oneByOneListener:registerScriptHandler(function (...) return self:touchBegin(...) end,
											cc.Handler.EVENT_TOUCH_BEGAN)
    oneByOneListener:registerScriptHandler(function (...) self:touchMoved(...) end,
    										cc.Handler.EVENT_TOUCH_MOVED)
    oneByOneListener:registerScriptHandler(function (...) self:touchEnded(...) end,
    										cc.Handler.EVENT_TOUCH_ENDED)
    EventDispatcher:addEventListenerWithSceneGraphPriority(oneByOneListener, controlLayer)
	return self
end

function StickController:touchBegin(touch, event)
    local touchPoint = touch:getLocation()
    if self:pointInRect(touchPoint) then
        touch._type = PointType.STICK
        self._SpStick:setPosition(touchPoint)
        self._SpCirele:setPosition(touchPoint)
        local act1 = cc.FadeTo:create(0.3, 166)
        local act2 = act1:clone()
        self._SpCirele:runAction(act1)
        self._SpStick:runAction(act2)
        self._curCenter = touchPoint
        return true
    else
        touch._type = PointType.NULL
        return false
    end
end

-- 判断point是否在左摇杆圈内
function StickController:pointInCircle(point)
    if point.x == nil or point.y == nil then
        return
    end
    local desSQ = cc.pDistanceSQ(point, self._center)
    if desSQ <= self._cirRadious * self._cirRadious then
        return true
    else
        return false
    end
end

function StickController:pointInRect(point)
    if point.x == nil or point.y == nil then
        return
    end
    local r = self._touchRect
    if point.x >= r.x and point.x <= r.x + r.width and
       point.y >= r.y and point.y <= r.y + r.height then
        return true
    else
        return false
    end
end

function StickController:touchMoved(touch, event)
    local touchPoint = touch:getLocation()
    local hero = DM:getValue("CurrentHero")
	if touch._type == PointType.STICK then
        local stickPos
        local dst = cc.pGetDistance(touchPoint, self._curCenter)
        if dst >= self._cirRadious - self._stkRadious then
            local r = (self._cirRadious - self._stkRadious) / dst
            stickPos = cc.pLerp(self._curCenter, touchPoint, r)
        else
            stickPos = touchPoint
        end
        self._SpStick:setPosition(stickPos)
        -- 计算followPoint
        local tp2cent = cc.pSub(stickPos, self._curCenter) -- touchPoint相对于中点的偏移向量
        -- 按照比例系数放大
        tp2cent = cc.pNormalize(tp2cent)
        tp2cent = cc.p(tp2cent.x * 100, tp2cent.y * 100)
        local followPoint = cc.pAdd(cc.p(hero:getPosition()), tp2cent) -- 相对坐标
        followPoint = DM:getValue("LandLayer"):convertToWorldSpace(followPoint) -- 世界坐标
        touch._followPoint = followPoint  -- 存储touch所对应的followPoint
        if hero._mouse == nil then
            -- 第一次进入此函数
            hero:startFollow(followPoint)
            -- 添加_synMoveEntry定时器，用于同步touch和mouse
            local synMoveEntry
            local function synMovePoint()
                if hero._mouse == nil then
                    Scheduler:unscheduleScriptEntry(synMoveEntry)
                    synMoveEntry = nil
                    return
                end
                hero:updateFollow(touch._followPoint)
            end
            synMoveEntry = Scheduler:scheduleScriptFunc(synMovePoint, 0.2, false)
        else
            hero:updateFollow(followPoint)
        end
    end
end

function StickController:touchEnded(touch, event)
    local touchPoint = touch:getLocation()
    local hero = DM:getValue("CurrentHero")
    if touch._type == PointType.STICK then
        local act1 = cc.Spawn:create(cc.FadeTo:create(0.2, 77), cc.MoveTo:create(0.2, self._orgCenter))
        local act2 = act1:clone()
        self._SpCirele:runAction(act1)
        self._SpStick:runAction(act2)
        if hero._mouse then
            hero:endFollow()
        end
    end
end

-- 设置跟随摄像机
function StickController:initCamera(layer, followNode)
    local layerSize = layer:getContentSize()
    local scaleX = layer:getScaleX()
    local scaleY = layer:getScaleY()
    layerSize = {width = scaleX * layerSize.width, height = scaleY * layerSize.height}
    -- 当sprWriter超出rect的范围则不跟踪。
    -- 关于rect的计算：
    -- layer:setScale(2)是以Scene的中心为基准进行放缩的。
    -- 所以放缩后的layer原点坐标如下。Follow的rect原点也应该是下点。
    -- cc.p(VisibleSize.width / 2 - layerSize.width / 2, VisibleSize.height / 2 - layerSize.height / 2)
    local actFollow = cc.Follow:create(followNode,
                        cc.rect(VisibleSize.width / 2 - layerSize.width / 2,
                            VisibleSize.height / 2 - layerSize.height / 2, layerSize.width, layerSize.height))
    layer:runAction(actFollow)
end

SC = StickController