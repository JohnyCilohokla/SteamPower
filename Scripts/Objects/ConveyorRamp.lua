include("Scripts/Objects/CLPlaceableObject.lua")

-------------------------------------------------------------------------------
if (ConveyorRamp == nil) then
	ConveyorRamp = CLPlaceableObject.Subclass("ConveyorRamp")
	ConveyorRamp.StaticMixin(ConnectorInterface)
	
end

	ConveyorRamp.CLConnectors = {}
	-- TODO FIXME flipped...
	ConveyorRamp.CLConnectors["Front"] = { pos = vec3.new(0,1.881,1.792), rotation = quat.new(1,0,0,0), opposite = quat.new(0,0,1,0), types = {"itemIn", "itemDropIn"}}
	ConveyorRamp.CLConnectors["Back"] = { pos = vec3.new(0,4.204,-1.798), rotation = quat.new(0,0,1,0), opposite = quat.new(1,0,0,0), types = {"itemOut"}}
-------------------------------------------------------------------------------
function ConveyorRamp:Constructor(args)
	self.m_sleepTimer = 0.0
	self.m_flashTimer = 0.0
	self.m_flashing = false
	self.m_interactor = nil
end

-------------------------------------------------------------------------------
function ConveyorRamp:PostLoad()
	ConveyorRamp.__super.PostLoad(self)
end

-------------------------------------------------------------------------------
function ConveyorRamp:Spawn()
--[[
	Debbuging...
	local inspect = require "Game.Core.Scripts.Utils.inspect"
	local file = io.open("dev/v0.6.5", "rw") -- output file is "dev/log"
	io.output(file) -- set output file
	io.write(tostring(inspect.inspect(_G))) -- write to file
	io.close(file) -- close the file
]]--
end
 
-------------------------------------------------------------------------------
function ConveyorRamp:Despawn()
end

-------------------------------------------------------------------------------
function ConveyorRamp:Update(dt)
	self:NKGetPhysics():NKEnableContactEvents()
	self:NKGetPhysics():NKEnableImpulseEvents()
	
	
	local parentPosition = self:NKGetWorldPosition()
	local rotation = self:NKGetWorldOrientation()
	local bb = { minX = - 1.3, minY = 1.6, minZ = - 3.5, maxX = 1.3, maxY = 2.8, maxZ = 3.5 }
	local gameobjects = getBB(parentPosition, rotation, bb)
	
	for objectID,objectData in pairs(gameobjects) do
		if (objectData:InstanceOf(BasePlayer)) then
		-- TODO player interaction
		else
			local inspect = require "Game.Core.Scripts.Utils.inspect"
			--CL.println(objectID)
			--CL.println(inspect.inspect(objectData))
			if (objectData:NKGetBounds():NKGetRadius()<3 and objectData:NKGetPhysics()~=nil and objectData:NKIsPhysicsDynamic()==false) then
				objectData:NKGetPhysics():NKSetMotionType(PhysicsComponent.DYNAMIC)
				self:Bounce(self, objectData, vec3.new(0,1,-1), 6)
			end
		end
	end
	
end

function ConveyorRamp:Bounce(self, value, dir, extend)
	local parentPosition = self:NKGetWorldPosition()
	
	if (value:NKGetName()~=self:NKGetName()) then 
		local physics = value:NKGetPhysics()
		local objectPosition = value:NKGetWorldPosition()
		if (physics~=nil) then 
			local rotation = self:NKGetWorldOrientation()
			local forward = dir:mul_quat(rotation)
			
			local dir = vec3.new(forward:x()*extend,forward:y()*extend,forward:z()*extend)
			dir = vec3.new(dir:x()+parentPosition:x(),dir:y()+parentPosition:y(),dir:z()+parentPosition:z())
			dir = vec3.new(dir:x()-objectPosition:x(),dir:y()-objectPosition:y(),dir:z()-objectPosition:z())
			
			local last = physics:NKGetVelocityVector()
			local up = forward:y()
			dir = vec3.new(dir:x()+last:x(),0,dir:z()+last:z())
			dir = dir:normalize()
			dir = vec3.new(dir:x()*4,up*2+2,dir:z()*4)
			
			physics:NKSetLinearVelocity(dir)
		end
	end
end

function ConveyorRamp:OnContactCreated(data)
	if (data.otherBody~=nil and data.otherBody.gameobject~=nil)then
		if (data.otherBody.gameobject:InstanceOf(BasePlayer)) then
		-- TODO player interaction
		else
			local parentPosition = self:NKGetWorldPosition()
			local invQuat = self:NKGetWorldOrientation():NKGetInverse()
			local contactPosition = data.contact.position
			local relativePosition = (contactPosition-parentPosition):mul_quat(invQuat)
			
			local bb = { minX = - 1.3, minY = 1.7, minZ = - 3.5, maxX = 1.3, maxY = 1.95, maxZ = 3.5 }
			
			--CL.println (itemData:NKGetBounds():NKGetExtents().minX)
			--local inspect = require "Game.Core.Scripts.Utils.inspect"
			--CL.println(inspect.inspect(getmetatable(itemData:NKGetBounds():NKGetExtents())))
				
			local isWithin = isWithinBB(relativePosition, bb)
			--CL.println(data.otherBody.gameobject:NKGetBounds():NKGetRadius())
			if (--[[isWithin and]] data.otherBody.gameobject:NKGetBounds():NKGetRadius()<3) then
				self:Bounce(self, data.otherBody.gameobject, vec3.new(0,1,-1), 6)
			end
		end
	end
end

-------------------------------------------------------------------------------
EntityFramework:RegisterGameObject(ConveyorRamp)
