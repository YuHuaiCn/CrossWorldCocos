
PlayerManager = class("PlayerManager")

PlayerManager._currentHero = nil

function PlayerManager:getInstance()
    if not PlayerManager._instance then
        PlayerManager._instance = PlayerManager.new()
    end
    return PlayerManager._instance
end

function PlayerManager:getCurrentHero()
    return PlayerManager:getInstance()._currentHero
end

function PlayerManager:setCurrentHero(hero)
    if hero.__cname ~= "Player" and 
       (hero.super and hero.super.__cname ~= "Player") then
        print("PlayerManager:setCurrentHero error: invalid argument.")
        return
    end
    PlayerManager:getInstance()._currentHero = hero
end

PM = PlayerManager
