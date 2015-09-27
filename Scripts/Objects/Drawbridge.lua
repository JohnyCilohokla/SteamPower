include("Scripts/Interactable.lua")
include("Scripts/Objects/CLPlaceableObject.lua")

-------------------------------------------------------------------------------
if (Drawbridge == nil) then
	Drawbridge = CLPlaceableObject.Subclass("Drawbridge")

	Drawbridge.StaticMixin(Interactable)
	
end

-------------------------------------------------------------------------------
function Drawbridge:Constructor(args)
	self.m_open = false
	self.m_closing = false
	self.m_opening = false
	self.m_closingRot = 0
	self.m_openingRot = 90
end

-------------------------------------------------------------------------------
function Drawbridge:PostLoad()
	Drawbridge.__super.PostLoad(self)
end

-------------------------------------------------------------------------------
function Drawbridge:Spawn()
	self:NKEnableScriptProcessing(true)
end
 
-------------------------------------------------------------------------------
function Drawbridge:Despawn()
end

-------------------------------------------------------------------------------
function Drawbridge:GetDebuggingText()
	local out = "Open: " .. tostring(self.m_open) .. "\n"
	
	out = out .. "m_closing: " .. tostring(self.m_closing) .. "\n"
	out = out .. "m_opening: " .. tostring(self.m_opening) .. "\n"
	out = out .. "m_closingRot: " .. tostring(self.m_closingRot) .. "\n"
	out = out .. "m_openingRot: " .. tostring(self.m_openingRot) .. "\n"
	
	return out
end

-------------------------------------------------------------------------------
function Drawbridge:Update(dt)

	if self.m_closing then
		self.m_closingRot = self.m_closingRot + (dt * (90/5))
		if self.m_closingRot > 90 then
			self.m_closingRot = 90
			self.m_closing = false
			self.m_open = false
		end
		local rot = quat.new(1,0,0,0)
		GLM.Rotate(rot , self.m_closingRot , vec3.new(1.0,0.0,0.0))
		self:NKSetOrientation(rot, true, false)
	end
	
	if self.m_opening then
		self.m_openingRot = self.m_openingRot - (dt * (90/5))
		if self.m_openingRot < 0 then
			self.m_openingRot = 0
			self.m_opening = false
			self.m_open = true
		end
		local rot = quat.new(1,0,0,0)
		GLM.Rotate(rot , self.m_openingRot , vec3.new(1.0,0.0,0.0))
		self:NKSetOrientation(rot, true, false)
	end
end

function Drawbridge:Interact(args)
	if (not Eternus.IsServer) then
		return
	end

	local player = args.player
	local equippedItem = args.heldItem
	
	if (player ~= nil) then
		if (equippedItem ~= nil) then

		else
			self:toggleState()
		end
	else
		NKError("No Local Player?")
	end

	return false
end

-------------------------------------------------------------------------------
function Drawbridge:toggleState( )
	if self.m_closing or self.m_opening then
		return
	end
	if self.m_open then
		self.m_closing = true
		self.m_closingRot = 0
	else
		self.m_opening = true
		self.m_openingRot = 90
	end
end

-------------------------------------------------------------------------------
function Drawbridge:Save( outData )
	Drawbridge.__super.Save(self, outData)
	
	outData.open = self.m_open
end

-------------------------------------------------------------------------------
function Drawbridge:Restore( inData, version )
	Drawbridge.__super.Restore(self, inData, version)

	self.m_open = inData.open or false
end

-------------------------------------------------------------------------------
EntityFramework:RegisterGameObject(Drawbridge)
