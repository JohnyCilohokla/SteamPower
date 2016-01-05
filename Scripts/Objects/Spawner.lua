include("Scripts/Interactable.lua")
include("Scripts/Objects/CLPlaceableObject.lua")

-------------------------------------------------------------------------------
if (Spawner == nil) then
	Spawner = CLPlaceableObject.Subclass("Spawner")
	
	Spawner.StaticMixin(Interactable)
end

-------------------------------------------------------------------------------
function Spawner:Constructor(args)
	self.m_sleepTimer = 10.0
	self.m_flashTimer = 0.0
	self.m_flashing = false
	self.m_interactor = nil
end

-------------------------------------------------------------------------------
function Spawner:PostLoad()
	Spawner.__super.PostLoad(self)
end

-------------------------------------------------------------------------------
function Spawner:Spawn()
	local filters = self:NKGetChildren()
	for filterID, filterData in pairs(filters) do 
		filterData:NKSetShouldRender(false, false)
	end
end
 
-------------------------------------------------------------------------------
function Spawner:Despawn()
	local filters = self:NKGetChildren()
	for filterID, filterData in pairs(filters) do 
		filterData:NKDeleteMe()
	end
end

-------------------------------------------------------------------------------
function Spawner:Update(dt)
	self.m_sleepTimer = self.m_sleepTimer-dt
	if (self.m_sleepTimer<0.0) then
		self.m_sleepTimer = 2
		local parentPosition = self:NKGetWorldPosition()
		local rotation = self:NKGetWorldOrientation()
		local outPositon = vec3.new(0, -2, 0)
	
		local filters = self:NKGetChildren()
		for filterID, filterData in pairs(filters) do 
				local ouput = Eternus.GameObjectSystem:NKCreateGameObject(filterData:NKGetName(), true)
				if ouput ~= nil then
					ouput:NKSetShouldRender(true, true)
					ouput:NKSetPosition(parentPosition +(outPositon:mul_quat(rotation)), false)
					ouput:NKSetOrientation(rotation)
				end
				ouput:NKPlaceInWorld(false, false, false)
				ouput:NKGetPhysics():NKSetMotionType(PhysicsComponent.DYNAMIC)
				ouput:NKGetPhysics():NKSetLinearVelocity(vec3.new(0, 0, - 1))
		end
	end
end

function Spawner:Interact(interactor)

	if interactor and interactor:InstanceOf(LocalPlayer) then
		local equippedItem = Eternus.GameState:GetHandSlotObject()
		if equippedItem == nil then
			equippedItem = interactor.gamestate:GetObjectGhost()
		end
		if equippedItem and equippedItem:NKGetName()~="" then
			--interactor:Place()
			--self:ConsumeFuel(60, true)
			
			local filters = self:NKGetChildren()
			local active = nil
			for filterID, filterData in pairs(filters) do 
				if filterData:NKGetName() == equippedItem:NKGetName() then
					active = filterData
				end
			end
			
			if (active==nil) then
				local ouput2 = Eternus.GameObjectSystem:NKCreateGameObject(equippedItem:NKGetName(), true)
				
				self:NKAddChildObject(ouput2)
				ouput2:NKSetPosition(vec3.new(0,2.0,0), false)
				ouput2:NKSetOrientation(quat.new(1,0,0,0))
				ouput2:NKSetAbsoluteScale(0.01)
				
				ouput2:NKInheritCellIDFrom(self.object)
				ouput2:NKPlaceInWorld(true, true, false)
				
				ouput2:NKSetShouldRender(false, false)
				
				--self.object:NKSendDataToServer()
				interactor:SendChatMessage("Added new spawner: "..equippedItem:NKGetName())
			else
				interactor:SendChatMessage("Removed spawner: "..active:NKGetName())
				self:NKRemoveChildObject(active)
				active:NKDeleteMe()
			end
			
			return true
		else
			for filterID, filterData in pairs(filters) do 
				filterData:NKDeleteMe()
			end
			interactor:SendChatMessage("Removed all spawners")
		end
	else
		NKError("No Local Player?")
	end

	return false
end

-------------------------------------------------------------------------------
EntityFramework:RegisterGameObject(Spawner)
