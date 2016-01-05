include("Scripts/Objects/CLPlaceableObject.lua")

-------------------------------------------------------------------------------
if (ElevatorBase == nil) then
	ElevatorBase = CLPlaceableObject.Subclass("ElevatorBase")
	
	--[[
	quat							x		y		z
	quat.new(1,0,0,0)       		0       0		1
	quat.new(0,0,1,0)       		0       0      -1
	quat.new(0.7071,0,0.7071,0)     -1       0       0
	quat.new(0.7071,0,-0.7071,0)    1      -0      0
	]]--
end
	
	ElevatorBase.CLConnectors = {}
	ElevatorBase.CLConnectors["Top"] = { pos = vec3.new(0,7.740,0), rotation = quat.new(0.707107,0.707107,0,0), opposite = quat.new(0.707107,-0.707107,0,0), types = {"itemLogicalOut"}}
	
	ElevatorBase.CLConnectors["Front"] = { pos = vec3.new(0,1.985,2.1), rotation = quat.new(1,0,0,0), opposite = quat.new(0,0,1,0), types = {"itemIn"}}
	ElevatorBase.CLConnectors["Back"] = { pos = vec3.new(0,1.985,-2.1), rotation = quat.new(0,0,1,0), opposite = quat.new(1,0,0,0), types = {"itemIn"}}
	ElevatorBase.CLConnectors["SideL"] = { pos = vec3.new(2.1,1.985,0), rotation = quat.new(0.707107,0,-0.707107,0), opposite = quat.new(0.707107,0,0.707107,0), types = {"itemIn"}}
	ElevatorBase.CLConnectors["SideR"] = { pos = vec3.new(-2.1,1.985,0), rotation = quat.new(0.707107,0,0.707107,0), opposite = quat.new(0.707107,0,-0.707107,0), types = {"itemIn"}}

-------------------------------------------------------------------------------
function ElevatorBase:Constructor(args)
	self.m_initTimer = 0.0
	self.m_shieldTimer = 0.0
	self.shield = nil
	self:Mixin(ConnectorInterface, args)
end

-------------------------------------------------------------------------------
function ElevatorBase:PostLoad()
	ElevatorBase.__super.PostLoad(self)
	self.m_initTimer = 0.0
	self.m_shieldTimer = 0.0
end

-------------------------------------------------------------------------------
function ElevatorBase:Spawn()
	CL.println ("ElevatorBase:Spawn()")
	self.m_initTimer = 0.0
	self.m_shieldTimer = 0.0
end
 
-------------------------------------------------------------------------------
function ElevatorBase:Despawn()
	CL.println ("ElevatorBase:Despawn()")
	local attachments = self:NKGetChildren()
	for attachmentsID, attachmentsData in pairs(attachments) do 
		if attachmentsData:NKGetName() == "Elevator Shield" then
			self:NKRemoveChildObject(attachmentsData)
			attachmentsData:NKDeleteMe()
		end
		CL.println ("Searching "..attachmentsData:NKGetName())
	end
	self.shield = nil
	self.m_initTimer = 0.0
	self.m_shieldTimer = 0.0
end

function ElevatorBase:ShieldRemoved()
	self.shield = nil
end

function ElevatorBase:InitializeShield()
	self.shield=nil
	local attachments = self:NKGetChildren()
	for attachmentsID, attachmentsData in pairs(attachments) do 
		if attachmentsData:NKGetName() == "Elevator Shield" then
			self:NKRemoveChildObject(attachmentsData)
			attachmentsData:NKDeleteMe()
		end
		CL.println ("Searching "..attachmentsData:NKGetName())
	end
	if (self.shield==nil) then
		self.shield = Eternus.GameObjectSystem:NKCreateGameObject("Elevator Shield", true)
		self:NKAddChildObject(self.shield)
		self.shield:NKSetPosition(vec3.new(0,0.0,0), false)
		self.shield:NKSetOrientation(quat.new(1,0,0,0))
		
		self.shield:NKPlaceInWorld(true, false)
		
		self.shield:SetBase(self)
		self.shield:NKGetPhysics():NKSetMotionType(PhysicsComponent.KEYFRAMED)
	end
	--self.shield:NKGetNet():NKForceGlobalRelevancy(true)
	--self.shield:NKGetNet():NKDisableAutoRelevancy(false)
	--[[self.shield:NKGetNet():NKReference(true)]]
end

-------------------------------------------------------------------------------
function ElevatorBase:Update(dt)
	if (self.m_inInventory or self.m_ghostObject) then
		return
	end
	self.m_shieldTimer = (self.m_shieldTimer + dt)
	
	if (self.m_initTimer~=2)then
		self.m_initTimer = self.m_initTimer + dt
		if (self.m_initTimer>2)then
			self.m_initTimer = 2
		end
	else
		if (self.shield==nil) then
			self:InitializeShield()	
			return
		end
		if (self.m_shieldTimer < 10) then
			self:setShieldPosition(vec3.new(0,0.0,0))
		elseif(self.m_shieldTimer>=10 and self.m_shieldTimer < 11) then
			self:setShieldPosition(vec3.new(0,(self.m_shieldTimer-10)*1.75,0))
		elseif(self.m_shieldTimer>=11 and self.m_shieldTimer < 14) then
			self:setShieldPosition(vec3.new(0,1.75,0))
			if Eternus.IsServer then
				local parentPosition = self:NKGetWorldPosition()
				local rotation = self:NKGetWorldOrientation()
				
				local localPosition = vec3.new(0,2.2,0)
				local localRotation = quat.new(1,0,0,0)
				
				local sides = {distX = 1.7,distY = 1.4,distZ = 1.7}
				local input = getQBB(parentPosition, localPosition, rotation, localRotation, sides)
				
				for inputID,inputData in pairs(input) do
					for itemID,itemData in pairs(inputData) do
						if itemData:NKGetName() ~= "Elevator Base" and itemData:NKGetParent()==nil then
							-- TODO simplify
							local topConnection = self:getConnection("Top")
							while (topConnection~=nil and topConnection.object:NKGetName() == "Elevator Middle") do
								topConnection = topConnection.object:getConnection("Top")
							end
							if (topConnection~=nil and topConnection.object:NKGetName() == "Elevator Top") then
							
								local parentPosition = topConnection.object:NKGetWorldPosition()
								local rotation = topConnection.object:NKGetWorldOrientation()
								local outRight = parentPosition+(vec3.new(0,5.5,3.6):mul_quat(rotation))
								itemData:NKSetPosition(outRight)
								itemData:NKPlaceInWorld(true, false)
								itemData:NKSetShouldRender(true, true)
								itemData:NKGetPhysics():NKSetMotionType(PhysicsComponent.DYNAMIC)
								itemData:NKGetPhysics():NKSetLinearVelocity(vec3.new(0,0,0))
							end
						end
					end
				end
			end
		elseif(self.m_shieldTimer>=14 and self.m_shieldTimer < 15) then
			self:setShieldPosition(vec3.new(0,1.75-(self.m_shieldTimer-14)*1.75,0))
		else
			self.m_shieldTimer = self.m_shieldTimer - 8
			self:RaiseClientEvent("ClientEvent_SyncShield", { shieldTimer = self.m_shieldTimer })
			self:setShieldPosition(vec3.new(0,0,0))
		end
	end
end

-------------------------------------------------------------------------------
function ElevatorBase:setShieldPosition(position)
	self.shield:NKSetPosition(position, false)
	self.shield:RefreshPhysics()
end

-------------------------------------------------------------------------------
function ElevatorBase:NetSerializeConstruction( stream )
	ElevatorBase.__super.NetSerializeConstruction(self, stream)
	
	stream:NKWriteInt(self.m_shieldTimer)
end

-------------------------------------------------------------------------------
function ElevatorBase:NetDeserializeConstruction( stream )
	ElevatorBase.__super.NetDeserializeConstruction(self, stream)

	self.m_shieldTimer = stream:NKReadInt()
end

-------------------------------------------------------------------------------
ElevatorBase.RegisterScriptEvent("ClientEvent_SyncShield",
	{
		shieldTimer = "double"
	}
)

-------------------------------------------------------------------------------
function ElevatorBase:ClientEvent_SyncShield( args )
	if not Eternus.IsServer then
		self.m_shieldTimer = args.shieldTimer
	end
end

-------------------------------------------------------------------------------
EntityFramework:RegisterGameObject(ElevatorBase)
