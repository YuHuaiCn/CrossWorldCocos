
--------------- Class ------------------
cc.exports.Alive = {}
cc.exports.Player = {}
cc.exports.Writer = {}

cc.exports.Levels = {}
cc.exports.Weapon = {}

cc.exports.Manager = {}
cc.exports.AnimationManager = {}
cc.exports.AM = {}
cc.exports.AudioManager = {}
cc.exports.AdM = {}
cc.exports.CollisionManager = {}
cc.exports.CM = {}
cc.exports.FollowController = {}
cc.exports.FC = {}
cc.exports.StickController  = {}
cc.exports.SC = {}
cc.exports.DataManager = {}
cc.exports.DM = {}
cc.exports.PlayerManager = {}
cc.exports.PM = {}
cc.exports.TiledMapManager = {}
cc.exports.TMM = {}
cc.exports.Bullet = {}


--------------- Variate ---------------
cc.exports.Director  = cc.Director:getInstance()
cc.exports.Scheduler = Director:getScheduler()
cc.exports.EventDispatcher = Director:getEventDispatcher()
cc.exports.FileUtils = cc.FileUtils:getInstance()
cc.exports.CurrentHero = {}
cc.exports.VisibleSize = Director:getVisibleSize()
cc.exports.DesignSize  = {width = 960, height = 640}

cc.exports.PIXCEL_PER_METER = 35
cc.exports.POINT_TYPE_JUDGE_TIME = 0.08

cc.exports.PhysicsMask = {
    WALL_CONTACT_MASK   = 0x108,
    WALL_CATEGORY_MASK  = 0xFF,
    WALL_COLLISION_MASK = 0xFF,

	PLAYER_CONTACT_MASK   = 0x08,
	PLAYER_CATEGORY_MASK  = 0x01,
	PLAYER_COLLISION_MASK = 0x08,

	WEAPON_CONTACT_MASK   = 0x00,
	WEAPON_CATEGORY_MASK  = 0x02,
	WEAPON_COLLISION_MASK = 0x08,

	BULLET_CONTACT_MASK   = 0x101,
	BULLET_CATEGORY_MASK  = 0x08,
	BULLET_COLLISION_MASK = 0x01,
}

----------------- Enum -----------------
-- cc.exports