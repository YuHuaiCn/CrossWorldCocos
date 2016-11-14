--[[

addAnimation(node, animName, loop = false)
    det: 为node添加动画，初始动画速度为0
    arg: [1]: node [2]: 动画名由动画全路径组成 eg:PlayerWriterWalkUnarmed [3]: 是否循环播放
    ret: [1]: actSpeed动画 [2]: 初始帧动画

setSpeed(node, speed = 1)
    det: 设置node动画的播放速度

runAnimation(node, speed = 1)
    det: 播放node已添加的动画

--]]


AnimationManager.__cname = "AnimationManager"

AnimationManager._animConfig = require "Model.AnimationData"

local frameCache = cc.SpriteFrameCache:getInstance()

function AnimationManager:getInstance(...)
    if AnimationManager._instance == nil then
        AnimationManager._instance = AnimationManager:ctor(...)
    end
    return AnimationManager._instance
end

function AnimationManager:ctor(...)
    return self
end

local function getAnimConfigByPath(self, path)
    local config = self._animConfig
    -- get config  path is start with 'Atlases/' so remove it
    for subPath in path:sub(9, -1):gmatch("%w+") do
        config = config[subPath]
        if not config then
            break
        end
    end
    return config
end

local function getPathListFromString(animName)
    local upIndex = {}  -- capital letters' index in animName
    local path = {}     -- sub pathes split from animName
    local pngPath = ''
    local index = 0
    for _, nChar in ipairs({animName:byte(1, -1)}) do
        index = index + 1
        -- if this Char is upper save it
        if nChar >= 65 and nChar <= 90 then
            upIndex[#upIndex + 1] = index
        end
    end
    local lastIndex = 1
    for i = 2, #upIndex do
        path[#path + 1] = animName:sub(lastIndex, upIndex[i] - 1)
        lastIndex = upIndex[i]
    end
    -- push last sub path
    path[#path + 1] = animName:sub(lastIndex, -1)

    return path
end

local function getFramesFromPath(path)
    -- create animation
    local animation = nil
    local frameList = {}
    local animPathHome = "Atlases/" .. table.concat(path, '/', 1, 2)  -- path of anim eg: Atlases/Player/Write
    local plistName = string.format("%s/%s.plist", animPathHome, path[1] .. path[2])
    if not frameCache:isSpriteFramesWithFileLoaded(plistName) then
        frameCache:addSpriteFrames(plistName)
    end

    -- load Frames from FrameCache
    local frames = 0
    -- find frames and store it to frameList
    local function createInPath(path)
        for i = 0, 999 do
            local pngName = string.format("%s/%03d.png", path, i)
            local spriteFrame = frameCache:getSpriteFrame(pngName)
            if spriteFrame then
                --animation:addSpriteFrame(spriteFrame)
                frameList[#frameList + 1] = spriteFrame
                frames = frames + 1
            else
                return frames
            end
        end
    end

    -- get target path
    local function getAnimPath(pathName)
        local animPath
        if pathName == 'normal' then
            if #path < 3 then
                print("Can't find anim: " .. table.concat(path, '/'))
                return
            end
            animPath = animPathHome .. '/' .. table.concat(path, '/', 3)
        elseif pathName == 'father' then
            if #path < 4 then
                print("Can't find anim: " .. table.concat(path, '/'))
                return
            end
            animPath = animPathHome .. '/' .. table.concat(path, '/', 3, #path - 1) .. path[#path]
        elseif pathName == "grand" then
            if #path < 5 then
                print("Can't find anim: " .. table.concat(path, '/'))
                return
            end
            animPath = animPathHome .. '/' .. table.concat(path, '/', 3, #path - 2) .. path[#path - 1] .. path[#path]
        end
        return animPath
    end

    -- first find in normal path
    local tarPath = nil
    tarPath = getAnimPath('normal')
    if tarPath then
        createInPath(tarPath)
        if frames == 0 then   -- can't find in normal path
            -- find in father path
            tarPath = getAnimPath('father')
            if tarPath then
                createInPath(tarPath)
                if frames == 0 then  -- can't find in father path
                    -- find in grand path
                    tarPath = getAnimPath('grand')
                    createInPath(tarPath)  -- if frames stil 0, can't find in grand path
                end
            end
        end
    end
    return frameList, tarPath
end


-------------------------------------------class function-------------------------------------------
-- 优化：暂存animation
function AnimationManager:addAnimation(sprite, animName, loop)
    loop = loop or false
    local path = getPathListFromString(animName)
    local frameList, tarPath = getFramesFromPath(path)
    if frameList then
        sprite:setSpriteFrame(frameList[1])
        sprite._firstFrame = frameList[1]
        local config = getAnimConfigByPath(self, tarPath)
        if not config then
            config = {gap = 5, offset = {0, 0}}
        end
        -- set offset
        local of = config.offset
        local cS = sprite:getContentSize()
        local anchor = cc.p(0.5 - of[1] / cS.width, 0.5 - of[2] / cS.width)
        sprite:setAnchorPoint(anchor)
        -- create animation
        local animation = cc.Animation:createWithSpriteFrames(frameList, config.gap * Director:getAnimationInterval())
        animation:setRestoreOriginalFrame(true)
        -- crate action
        local action = cc.Animate:create(animation)
        if loop then
            action = cc.RepeatForever:create(action)
        end
        local actSpeed = cc.Speed:create(action, 0)
        sprite:stopAllActions()
        sprite:runAction(actSpeed)
        sprite._animation = actSpeed
        return actSpeed, frameList[1]
    else
        print("Can't find anim: " .. animName)
    end
end

function AnimationManager:flipX(animation)
    local speed = animation:getSpeed()
    local action = animation:getInnerAction()
    local actFlipX = cc.FlipX:create(true)


end

function AnimationManager:setSpeed(node, speed)
    speed = speed or 1
    local action = node._animation
    if action then
        action:setSpeed(speed)
    end
end

function AnimationManager:runAnimation(node, speed)
    self:setSpeed(node, speed)
end

function AnimationManager:pauseAnimation(node)
    local action = node._animation
    if action then
        action:setSpeed(0)
        local node = action:getTarget()
        node:setSpriteFrame(node._firstFrame)
    end
end

function AnimationManager:addImgToCache(name)
    if name == "Weapon" then
        frameCache:addSpriteFrames("Atlases/Weapon/Weapons.plist")
    end
end

-- 不要主动调用这个函数，应该使用weaponSpr:runAnimLandedWeapon()
function AnimationManager:runAnimLandedWeapon(weaponSpr)
    local posX, posY = weaponSpr:getPosition()
    local body = weaponSpr:getChildByName("Body")
    local bg = weaponSpr:getChildByName("Background")
    bg:setColor(cc.c3b(0, 0, 0))
    bg:setOpacity(128)
    bg:setPosition(weaponSpr:convertToNodeSpace(cc.p(posX, posY - 2)))
    local action = cc.MoveBy:create(0.85, weaponSpr:convertToNodeSpace(cc.p(posX, posY + 2)))
    local reAction = action:reverse()
    local seq = cc.Sequence:create(action, reAction)
    local repAct = cc.RepeatForever:create(seq)
    body:runAction(repAct)
end

function AnimationManager:addPlistToFrameCache(plistName)
    if not frameCache:isSpriteFramesWithFileLoaded(plistName) then
        frameCache:addSpriteFrames(plistName)
    end
end

AM = AnimationManager