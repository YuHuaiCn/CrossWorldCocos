
local animConfig = {}


-- animConfig format: gap = 5, offset = (0, 0)
animConfig.Player = {}
	animConfig.Player.Writer = {}	
		animConfig.Player.Writer.Walk = {}
			animConfig.Player.Writer.Walk.Unarmed = {gap = 10, offset = {1, 0}}
			animConfig.Player.Writer.Walk.Nmm     = {gap = 10, offset = {12, 0}}
			animConfig.Player.Writer.Walk.M16     = {gap = 10, offset = {8, 0}}
			animConfig.Player.Writer.Walk.Knife   = {gap = 10, offset = {8, -8}}

		animConfig.Player.Writer.Attack = {}
			animConfig.Player.Writer.Attack.Punch = {gap = 5,  offset = {10, 0}}
			animConfig.Player.Writer.Attack.Nmm   = {gap = 10, offset = {12, 0}}
			animConfig.Player.Writer.Attack.M16   = {gap = 5,  offset = {8, 0}}
			animConfig.Player.Writer.Attack.Knife = {gap = 3,  offset = {8, -8}}


	animConfig.Player.Nicke = {}
		animConfig.Player.Nicke.Leg = {gap = 5, offset = {-5, 0}}
		animConfig.Player.Nicke.Attack = {}
			animConfig.Player.Nicke.Attack.KnifeFlameThrower = {gap = 5, offset = {0, 0}}

return animConfig