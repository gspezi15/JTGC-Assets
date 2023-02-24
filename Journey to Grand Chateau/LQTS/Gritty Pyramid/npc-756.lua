local npc = {}
local npcManager = require("npcManager")

function npc.onInitAPI()
	npcManager.registerEvent(NPC_ID, npc, "onTickNPC")
end

local function isGrabbed(i)
	for k,v in ipairs(Player.get()) do
		local n = v.holdingNPC
		if n and n == i then
			if v.speedY < -3 then
				v.speedY = -3
			end
		end
	end
end

function npc.onTickNPC(v)
	if Defines.levelFreeze then return end
	
	for k,b in ipairs(Block.getIntersecting(v.x + 1, v.y + 1, v.x + v.width - 2, v.y + v.height + 1)) do
		if not b.isHidden and (Block.config[b.id].npcfilter ~= -1 and Block.config[b.id].npcfilter ~= v.id) and not Block.config[b.id].passthrough and not Block.config[b.id].smashable then
			if Block.config[b.id].semisolid then
				if v.y + v.height + 1 <= b.y + 4 and v.speedY > -Defines.npc_grav then
					v.speedX = 0
					v.speedY = 0
				end
			else
				v.speedX = 0
				v.speedY = 0
			end
		end
	end
	
	if v.speedY < -6 then
		v.speedY = -6
	end
	
	if v:mem(0x12C, FIELD_WORD) > 0 then
		isGrabbed(v)
	end
	
	if v:mem(0x136, FIELD_BOOL) then
		local x = v.x - (v.width / 1.75)
		local y = v.y - (v.height / 1.75)
		local w = x + v.width + v.width / 1.5
		local h = y + v.height + v.height / 1.5
		
		for k,b in ipairs(Block.getIntersecting(x,y,w,h)) do
			if Block.config[b.id].smashable then
				b:remove(true)
			end
		end
		
		if v:mem(0x132, FIELD_WORD) < 0 then
			for k,p in ipairs(Player.getIntersecting(x,y,w,h)) do
				p:harm()
			end
		end
	end
end

return npc