include("Scripts/Objects/CLPlaceableObject.lua")

-------------------------------------------------------------------------------
if (ConveyorBelt == nil) then
	ConveyorBelt = CLPlaceableObject.Subclass("ConveyorBelt")
	--ConveyorBelt.StaticMixin(ConnectorInterface)
	
end

	ConveyorBelt.CLConnectors = {}
	ConveyorBelt.CLConnectors["Front"] = { pos = vec3.new(0,1.881,3.488), rotation = quat.new(1,0,0,0), opposite = quat.new(0,0,1,0), types = {"itemOut"}}
	ConveyorBelt.CLConnectors["Back"] = { pos = vec3.new(0,1.881,-3.547), rotation = quat.new(0,0,1,0), opposite = quat.new(1,0,0,0), types = {"itemIn", "itemDropIn"}}
	ConveyorBelt.CLConnectors["SideL"] = { pos = vec3.new(1.753,1.881,0), rotation = quat.new(0.707107,0,-0.707107,0), opposite = quat.new(0.707107,0,0.707107,0), types = {"itemDropIn"}}
	ConveyorBelt.CLConnectors["SideR"] = { pos = vec3.new(-1.753,1.881,0), rotation = quat.new(0.707107,0,0.707107,0), opposite = quat.new(0.707107,0,-0.707107,0), types = {"itemDropIn"}}
-------------------------------------------------------------------------------
function ConveyorBelt:Constructor(args)
	self.m_sleepTimer = 0.0
	self.m_flashTimer = 0.0
	self.m_flashing = false
	self.m_interactor = nil
	self:Mixin(ConnectorInterface, args)
end

-------------------------------------------------------------------------------
function ConveyorBelt:PostLoad()
	ConveyorBelt.__super.PostLoad(self)
	self:NKEnableScriptProcessing(true)
end

-------------------------------------------------------------------------------
function ConveyorBelt:Spawn()
	self:NKGetPhysics():NKSetContactEventsEnabled(true)
end
 
-------------------------------------------------------------------------------
function ConveyorBelt:Despawn()
	self:NKGetPhysics():NKSetContactEventsEnabled(false)
end

-------------------------------------------------------------------------------
function ConveyorBelt:Update(dt)
	local bb = { minX = - 1.3, minY = 1.6, minZ = - 3.5, maxX = 1.3, maxY = 2.8, maxZ = 4.2 }
	local gameobjects = getBB(self:NKGetWorldPosition(), self:NKGetWorldOrientation(), bb)
	
	
	for objectID,gameobject in pairs(gameobjects) do
		if (gameobject:InstanceOf(LootObject)) then
			self:Bounce(self, gameobject, vec3.new(0,0,1), 6)
		elseif (gameobject:InstanceOf(PlaceableObject)) then
			if (gameobject:NKGetBounds():NKGetRadius()<3 and gameobject:NKGetPhysics()~=nil and gameobject:NKIsPhysicsDynamic()==false) then
				gameobject:NKGetPhysics():NKSetMotionType(PhysicsComponent.DYNAMIC)
				self:Bounce(self, gameobject, vec3.new(0,0,1), 6)
			end
		--elseif (gameobject:InstanceOf(BasePlayer)) then
		-- TODO player interaction
		end
	end
	
end

function ConveyorBelt:Bounce(self, value, dir, extend)
	local parentPosition = self:NKGetWorldPosition()
	
	if (value:NKGetName()~=self:NKGetName()) then 
		local physics = value:NKGetPhysics()
		local objectPosition = value:NKGetWorldPosition()
		if (physics~=nil) then 
			local forward = dir:mul_quat(self:NKGetWorldOrientation())
			
			local dir = vec3.new(forward:x()*extend,forward:y()*extend,forward:z()*extend)
			dir = vec3.new(dir:x()+parentPosition:x(),dir:y()+parentPosition:y(),dir:z()+parentPosition:z())
			dir = vec3.new(dir:x()-objectPosition:x(),dir:y()-objectPosition:y(),dir:z()-objectPosition:z())
			
			local last = physics:NKGetLinearVelocity()
			local up = forward:y()
			dir = vec3.new(dir:x()+last:x(),0,dir:z()+last:z())
			dir = dir:normalize()
			dir = vec3.new(dir:x()*3,up*3,dir:z()*3)
			
			physics:NKSetLinearVelocity(dir)
		end
	end
end

function ConveyorBelt:OnContactStart( collision )
	if not collision.gameobject then return end
	collision.raiseStopEvents = true
	collision.raiseStayEvents = true
	
	self:OnContact(collision.gameobject)
end

function ConveyorBelt:OnContactStay( collision )
	if not collision.gameobject then return end
	collision.raiseStayEvents = true
	collision.raiseStopEvents = true
	
	self:OnContact(collision.gameobject)
end

function ConveyorBelt:OnContactStop( collision )
	if not collision.gameobject then return end
	
	self:OnContact(collision.gameobject)
end

function ConveyorBelt:OnContact(instance)
	if (instance:InstanceOf(EternusEngine.GameObjectClass)) then
		--local relativePosition = (data.contact.position-self:NKGetWorldPosition()):mul_quat(self:NKGetWorldOrientation():NKGetInverse())
		
		--local bb = { minX = - 1.3, minY = 1.7, minZ = - 3.5, maxX = 1.3, maxY = 1.95, maxZ = 3.5 }
			
		--local isWithin = isWithinBB(relativePosition, bb)
		--CL.println(data.otherBody.gameobject:NKGetBounds():NKGetRadius())
		--if (isWithin and instance:NKGetBounds():NKGetRadius()<3) then
			self:Bounce(self, instance, vec3.new(0,0,1), 6)
		--end
	--elseif (instance:InstanceOf(Character) or instance:InstanceOf(BasePlayer) or instance:InstanceOf(NetworkPlayer)) then
	-- TODO player interaction
	end
end

-------------------------------------------------------------------------------
EntityFramework:RegisterGameObject(ConveyorBelt)
