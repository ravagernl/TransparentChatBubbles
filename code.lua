local thisAddon, ns = ...
local select = select
local pairs = pairs
local GetCVarBool = GetCVarBool

local isBubble = function(frame)
	if frame:GetName() then return end
	if not frame:GetRegions() then return end
	local region = frame:GetRegions()
	return region:GetTexture() == [[Interface\Tooltips\ChatBubble-Background]]
end

local skinBubble = function(frame)
	for i=1, frame:GetNumRegions() do
		local region = select(i, frame:GetRegions())
		if region:GetObjectType() == "Texture" then
			region:SetTexture(nil)
		elseif region:GetObjectType() == "FontString" then
			local f, s = region:GetFont()
			region:SetFont(f, s, "OUTLINE")
			region:SetShadowColor(0, 0, 0, 0)
		end
	end
end

local skinBubbles = function(...)
	for i = 1, select('#', ...) do
		local frame = select(i, ...)
	
		if not frame.isTransparentBubble and isBubble(frame) then 
			skinBubble(frame)
			frame.isTransparentBubble = true
		end
	end
end

local numChildren = -1
local WorldFrame = WorldFrame

local f = CreateFrame("Frame")
f.elapsed = -2 -- wait two seconds
f:SetScript("OnUpdate", function(self, elapsed)
	self.elapsed = self.elapsed + elapsed
	if self.elapsed < 0.2 then return end
	self.elapsed = 0

	local count = WorldFrame:GetNumChildren()
	if count ~= numChildren then
		numChildren = count
		skinBubbles(WorldFrame:GetChildren())
	end
end)

-- immediately trigger an update when a chat bubble is shown for the following events
-- if the blizzard options has those speechbubbles enabled
local events = {
	CHAT_MSG_SAY = "chatBubbles", CHAT_MSG_YELL = "chatBubbles",
	CHAT_MSG_PARTY = "chatBubblesParty", CHAT_MSG_PARTY_LEADER = "chatBubblesParty",
	CHAT_MSG_MONSTER_SAY = "chatBubbles", CHAT_MSG_MONSTER_YELL = "chatBubbles", CHAT_MSG_MONSTER_PARTY = "chatBubblesParty",
}
f:SetScript("OnEvent", function(self, event)
	if GetCVarBool(events[event]) then
		self.elapsed = 0.158
	end
end)
for k, v in pairs(events) do
	f:RegisterEvent(k)
end

-- make the addon global.
ns.isBubble = isBubble
ns.skinBubble = skinBubble
ns.updateFrame = f
_G[thisAddon] = ns