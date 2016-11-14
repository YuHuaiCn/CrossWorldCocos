
FollowController.__cname = "FollowController"

FollowController._oneByOnePoints = {}   -- struct: type: point type
										--         entryTime: the time of point pushed
										--         entryPos:  the position of entry point
										--         curPos:    the position of current point
										-- hasFollowPoint
FollowController._touchLayer = nil
FollowController._radious = nil
FollowController._center = nil

local POINT_TYPE_NULL    = 0
local POINT_TYPE_ATTACK  = 1
local POINT_TYPE_FOLLOW  = 2
local POINT_TYPE_DISCARD = 3  -- 一开始为FollowPoint后弃用
local POINT_TYPE_PICKUP  = 4

function FollowController:init(layer)
	local oneByOneListener = cc.EventListenerTouchOneByOne:create()
	oneByOneListener:registerScriptHandler(function (...) return self:touchBegin(...) end,
											cc.Handler.EVENT_TOUCH_BEGAN)
    oneByOneListener:registerScriptHandler(function (...) self:touchMoved(...) end,
    										cc.Handler.EVENT_TOUCH_MOVED)
    oneByOneListener:registerScriptHandler(function (...) self:touchEnded(...) end,
    										cc.Handler.EVENT_TOUCH_ENDED)
    EventDispatcher:addEventListenerWithSceneGraphPriority(oneByOneListener, layer)
    if VisibleSize.height <= VisibleSize.width then
        self._radious = VisibleSize.height * 0.38
    else
        self._radious = VisibleSize.width * 0.38
    end
    self._center = cc.p(VisibleSize.width / 2, VisibleSize.height / 2)
	return self
end

function FollowController:dtor(...)
    FollowController._instance = nil
    FollowController = nil
end

function FollowController:pointOnCircle(point)
    local h = point.y - self._center.y  -- 直角三角形的高
    local r = self._radious
    -- 超出圆圈的范围
    if h >= r then
        return cc.p(self._center.x, self._center.y + r)
    elseif h <= -self._radious then
        return cc.p(self._center.x, self._center.y - r)
    end
    -- 未超出
    local w   -- 直角三角形的宽
    w = math.sqrt(r*r - h*h)
    -- 右半球
    if point.x >= self._center.x then
        return cc.p(self._center.x + w, self._center.y + h)
    else
    -- 左半球
        return cc.p(self._center.x - w, self._center.y + h)
    end
end

function FollowController:touchBegin(touch, event)
    touch._entryTime = os.clock()
    touch._type = POINT_TYPE_NULL
    self._oneByOnePoints[#self._oneByOnePoints + 1] = touch
    local landLayer = DM:getValue("LandLayer")
    local hero = DM:getValue("CurrentHero")
    local touchPoint = touch:getLocation()
    -- in follow panel
    if touchPoint.x <= VisibleSize.width / 10 or
       touchPoint.x >= VisibleSize.width / 10 * 9 then
        -- 移除上一个touch point
        for i, point in ipairs(self._oneByOnePoints) do
            if point._type == POINT_TYPE_FOLLOW then
                hero:endFollow()
                point._type = POINT_TYPE_DISCARD
            end
        end
        touch._type = POINT_TYPE_FOLLOW
        local followPoint = self:pointOnCircle(touchPoint)
        hero:startFollow(followPoint)
        -- 添加_synMoveEntry定时器，用于同步touch和mouse
        local synMoveEntry
        local function synMovePoint()
            if touch._type ~= POINT_TYPE_FOLLOW and synMoveEntry then
                Scheduler:unscheduleScriptEntry(synMoveEntry)
                synMoveEntry = nil
                return
            end
            if touch._pointChange then
                followPoint = self:pointOnCircle(touch:getLocation())
                touch._pointChange = false
            end
            hero:updateFollow(followPoint)
        end
        synMoveEntry = Scheduler:scheduleScriptFunc(synMovePoint, 0.2, false)
    else
        -- not in follow panel
        local lcPoint = landLayer:convertToNodeSpace(touchPoint)
        local wpnNearby = {}
        -- 半径75之外的触点不认为是PickUp点
        if cc.pDistanceSQ(lcPoint, cc.p(hero:getPosition())) < 150 * 150 then
            local wpnList = DM:getValue("LandedWeapons")
            wpnList = wpnList or {}
            for _, spWpn in ipairs(wpnList) do
                local dst = cc.pDistanceSQ(lcPoint, cc.p(spWpn:getPosition()))
                if dst <= 225 then
                    wpnNearby[#wpnNearby + 1] = spWpn
                end
            end
        end
        if #wpnNearby >= 1 then
            touch._type = POINT_TYPE_PICKUP
            hero:pickupWeapon(touchPoint)
        else
            if hero:startAttack(touchPoint) then 
                touch._type = POINT_TYPE_ATTACK
            end
        end
    end
    return true
end

-- 优化：超过一定距离才出发updateFollow
function FollowController:touchMoved(touch, event)
    local touchPoint = touch:getLocation()
    local hero = DM:getValue("CurrentHero")
	if touch._type == POINT_TYPE_FOLLOW then
        local followPoint = self:pointOnCircle(touchPoint)
		hero:updateFollow(followPoint)
        touch._pointChange = true  -- follow point 发生变化
	elseif touch._type == POINT_TYPE_ATTACK then
        hero:updateAttack(touch:getLocation())
    end
end

function FollowController:touchEnded(touch, event)
    local hero = DM:getValue("CurrentHero")
    for i, point in ipairs(self._oneByOnePoints) do
        if point == touch then
        	if point._type == POINT_TYPE_FOLLOW then
                hero:endFollow()
    		elseif point._type == POINT_TYPE_ATTACK then
                hero:endAttack()
            end
            table.remove(self._oneByOnePoints, i)
            break
        end
    end
end

-- 设置跟随摄像机
function FollowController:initCamera(layer, followNode)
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

FC = FollowController