cc.FileUtils:getInstance():setPopupNotify(false)
cc.FileUtils:getInstance():addSearchPath("src/")
cc.FileUtils:getInstance():addSearchPath("res/")

require "config"
require "cocos.init"
require "init"

local function init()
	local glView = Director:getOpenGLView()
	local designSize = {width = 960, height = 640}
	local viewSize = glView:getFrameSize()
	if viewSize.width / viewSize.height > 1.5 then
		glView:setDesignResolutionSize(designSize.width, designSize.height, cc.ResolutionPolicy.FIXED_HEIGHT)
	else
		glView:setDesignResolutionSize(designSize.width, designSize.height, cc.ResolutionPolicy.FIXED_WIDTH)
	end
	VisibleSize = Director:getVisibleSize()
end

local function main()
	--init()
    local scene = Levels.FirstBloodScene.new()
    DM:storeValue("CurrentScene", scene)
    cc.Director:getInstance():replaceScene(scene)
end

local status, msg = xpcall(main, __G__TRACKBACK__)
if not status then
    print(msg)
end
