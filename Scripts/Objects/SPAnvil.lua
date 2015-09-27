include("Scripts/Objects/CraftingStation.lua")

if (SPAnvil == nil) then
	SPAnvil = CraftingStation.Subclass("SPAnvil")
end

-------------------------------------------------------------------------------
function SPAnvil:Constructor(args)
	self.m_craftingSoundList = { "SP_AnvilCrafting01", "SP_AnvilCrafting02", "SP_AnvilCrafting03", "SP_AnvilCrafting04"}
	self.m_craftingSound = nil
end

-------------------------------------------------------------------------------
function SPAnvil:Event_CraftingStart()
	if self.m_craftingSound then
		self:NKGetSound():NKStop3DSound(self.m_craftingSound)
		self.m_craftingSound = nil
	end
	
	self.m_craftingSound = self.m_craftingSoundList[ math.random( #self.m_craftingSoundList ) ]
	
	CL.println("SPAnvil:Event_CraftingEnd() "..self.m_craftingSound.." "..tostring(#self.m_craftingSoundList))
	
	if self.m_craftingSound then
		self:NKGetSound():NKPlay3DSound(self.m_craftingSound, false, vec3.new(0, 0, 0), 10.0, 15.0)
	end
end

-------------------------------------------------------------------------------
function SPAnvil:Event_CraftingEnd()
	if self.m_craftingSound then
		self:NKGetSound():NKStop3DSound(self.m_craftingSound)
		self.m_craftingSound = nil
	end
end

-------------------------------------------------------------------------------
EntityFramework:RegisterGameObject(SPAnvil)