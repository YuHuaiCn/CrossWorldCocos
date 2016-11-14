
AudioManager = class("AudioManager")

function AudioManager:playGunEffect(clsName)
	local function f(name) return "Sounds/snd" .. name .. ".wav" end
	AudioEngine.playEffect(f(clsName))
end

AdM = AudioManager