
AudioManager = class("AudioManager")

function AudioManager:playGunEffect(clsName)
	local function f(name) return "Sounds/snd" .. name .. ".wav" end
	local fullName = f(clsName)
	if FileUtils:isFileExist(fullName) then
		AudioEngine.preloadEffect(fullName)
		AudioEngine.playEffect(fullName)
	end
end

function AudioManager:playEffectByName(efName)
	local function f(name) return "Sounds/snd" .. name .. ".wav" end
	local fullName = f(efName)
	if FileUtils:isFileExist(fullName) then
		AudioEngine.preloadEffect(fullName)
		AudioEngine.playEffect(fullName)
	end
end

AdM = AudioManager