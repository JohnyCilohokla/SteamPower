include("Scripts/Interactable.lua")
include("Scripts/Objects/CLPlaceableObject.lua")
include("Scripts/Mixins/LiquidContainer.lua")

-------------------------------------------------------------------------------
if (ClayJug == nil) then
	ClayJug = CLPlaceableObject.Subclass("ClayJug")
	ClayJug.MaxLiquidAmount = 100
	ClayJug.StaticMixin(Interactable)
end
	ClayJug.CLConnectors = {}
	ClayJug.CLConnectors["Top"] = { pos = vec3.new(0,1.000,0), rotation = quat.new(0.707107,0.707107,0,0), opposite = quat.new(0.707107,-0.707107,0,0), types = {"liquidDropIn"}}

-------------------------------------------------------------------------------
function ClayJug:Constructor(args)
	self:Mixin(ConnectorInterface, args)
	self:Mixin(LiquidContainer, {maxAmount = ClayJug.MaxLiquidAmount})
	
	self.m_isClosed = (self:NKGetName() == "Clay Jar")
	self:setupConnector()
end

-------------------------------------------------------------------------------
function ClayJug:PostLoad()
	ClayJug.__super.PostLoad(self)
end

-------------------------------------------------------------------------------
function ClayJug:Spawn()
	CL.println ("ClayJug:Spawn()")
	self:NKEnableScriptProcessing(true)
	self:SetMaxHitPoints(self.m_liquidAmountMax)
	self:_SetHitPoints(self.m_liquidAmount)
end
 
-------------------------------------------------------------------------------
function ClayJug:Despawn()
	ConnectorInterface.disconnectAll(self)
end
	
-------------------------------------------------------------------------------
function ClayJug:OnEquip()
	ConnectorInterface.disconnectAll(self)
end

-------------------------------------------------------------------------------
function ClayJug:_SetHitPoints(newValue)
	local value = self:GetHitPoints()
	if value ~= newValue then
		self:SetHitPoints(newValue)
	end
end

-------------------------------------------------------------------------------
function ClayJug:Update(dt)
	if (not Eternus.IsServer) then
		return
	end
	self:_SetHitPoints(self.m_liquidAmount)
	if (self.m_inInventory or self.m_ghostObject or self.m_isClosed) then
		return
	end
	
	-- TODO add different liquids
	local topConnection = self:getConnection("Top")
	if (topConnection~=nil and topConnection.object:InstanceOf(LiquidProvider)) then
		if (self.m_liquidAmountMax-self.m_liquidAmount) > 0 then
			local liquid, amout = topConnection.object:GetLiquid(dt, self.m_liquidAmountMax-self.m_liquidAmount, self.m_liquid)
			if (not self.m_liquid or liquid == self.m_liquid) then
				self.m_liquidAmount = self.m_liquidAmount + amout
				self.m_liquid = liquid
			end
			--CL.println(liquid,amout)
		end
	end
end

-------------------------------------------------------------------------------
function ClayJug:Interact(args)
	if (not Eternus.IsServer) then
		return
	end

	local player = args.player
	local equippedItem = args.heldItem
	
	if (player ~= nil) then
		if (equippedItem == nil) then
			self:ConvertTo(self.m_isClosed and "Clay Jar Open" or "Clay Jar")
		end
	else
		NKError("No Local Player?")
	end

	return false
end

-------------------------------------------------------------------------------
function ClayJug:ConvertTo(name)
	local newObj = Eternus.GameObjectSystem:NKCreateNetworkedGameObject(name, true, true)
	
	newObj:NKSetOrientation(self:NKGetWorldOrientation())
	newObj:NKSetPosition(self:NKGetWorldPosition(), false)
	local data = {}
	self:Save(data)
	self:NKDeleteMe()
	
	newObj:NKPlaceInWorld(true, false)
	
	newObj:Restore(data)
	if (newObj.OnPlace ~= nil) then
		newObj:OnPlace()
	end
end

-------------------------------------------------------------------------------
function ClayJug:GetDebuggingText()
	local out = "Liquid: " .. tostring(self.m_liquid) .. " " .. tostring(CL.round(self.m_liquidAmount,3))
	return out
end

-------------------------------------------------------------------------------
EntityFramework:RegisterGameObject(ClayJug)
