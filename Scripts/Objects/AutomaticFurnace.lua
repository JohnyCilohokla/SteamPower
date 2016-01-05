include("Scripts/Interactable.lua")
include("Scripts/Objects/CLPlaceableObject.lua")

-------------------------------------------------------------------------------
if (AutomaticFurnace == nil) then
	AutomaticFurnace = CLPlaceableObject.Subclass("AutomaticFurnace")

	AutomaticFurnace.StaticMixin(Interactable)
end

-------------------------------------------------------------------------------
function AutomaticFurnace:Constructor(args)
	self.m_sleepTimer = 0.0
	self.m_flashTimer = 0.0
	self.m_flashing = false
	self.m_interactor = nil
	
	self.m_fireTimer = 0.0
end

-------------------------------------------------------------------------------
function AutomaticFurnace:PostLoad()
	AutomaticFurnace.__super.PostLoad(self)
end

-------------------------------------------------------------------------------
function AutomaticFurnace:Spawn()
	local filters = self:NKGetChildren()
	for filterID, filterData in pairs(filters) do 
		if filterData:NKGetName() == "Coal" then
			filterData:NKSetShouldRender(false, false)
		end
	end
end
 
-------------------------------------------------------------------------------
function AutomaticFurnace:Despawn()
end


function AutomaticFurnace:Interact(interactor)

	if interactor and interactor:InstanceOf(LocalPlayer) then
		local equippedItem = Eternus.GameState:GetHandSlotObject()
		local ghost = false
		if equippedItem == nil then
			equippedItem = interactor.gamestate:GetObjectGhost()
			ghost = true
		end
		if equippedItem and equippedItem:NKGetName() == "Coal" then
			
			local attachments = self:NKGetChildren()
			local count = 0
			for attachmentsID, attachmentsData in pairs(attachments) do 
				if attachmentsData:NKGetName() == "Coal" then
					count = count+1
				end
			end
			local ouput2 = Eternus.GameObjectSystem:NKCreateGameObject(equippedItem:NKGetName(), true)
			
			self:NKAddChildObject(ouput2)
			ouput2:NKSetPosition(vec3.new(0,2.0,0), false)
			ouput2:NKSetOrientation(quat.new(1,0,0,0))
			ouput2:NKSetAbsoluteScale(0.01)
			
			ouput2:NKInheritCellIDFrom(self.object)
			ouput2:NKPlaceInWorld(true, true, false)
			
			ouput2:NKSetShouldRender(false, false)
			
			self.object:NKAlterData()
			--self.object:NKSendDataToServer()
			count = count + 1
			interactor:SendChatMessage("Added "..equippedItem:NKGetName().." current: "..count)
			
			return true
		end
	else
		NKError("No Local Player?")
	end

	return false
end

-------------------------------------------------------------------------------
function AutomaticFurnace:Update(dt)
	if self.m_fireTimer ~= 0.0 then
		self.m_fireTimer = self.m_fireTimer - dt
	end

	local parentPosition = self:NKGetWorldPosition()
	local rotation = self:NKGetWorldOrientation()
	--local gameobjects = Eternus.GameObjectSystem:NKGetGameObjectsInRadius(parentPosition+(vec3.new(0,1.369,-2.28):mul_quat(rotation)), 2, "all", false) -- works!


	--local sides = {distX = 4.0935,distY = 1.2195,distZ = 1.2195}
	local outPositon = vec3.new(5.4, 4.8, 0)
	
	out = { }
	out [ "Copper Ore" ] = { }
	out [ "Tin Ore" ] = { }

	local bb = { minX = - 6.2000, minY = 1.1000, minZ = - 1.4400, maxX = - 3.1000, maxY = 3.7000, maxZ = 1.4400 }

	--local localPosition = vec3.new(0.7575,2.4325,0.0000)


	--local bb = {minX = -1.124,minY = 0.800,minZ = -3.335,maxX = 1.124,maxY = 1.869,maxZ = -1.226}
	local input = getBB(parentPosition, rotation, bb, out)


	if(((# input [ "Copper Ore" ]) >= 1) and((# input [ "Tin Ore" ]) >= 1)) then

		if self.m_fireTimer <= 0.0 then
			local attachments = self:NKGetChildren()
			local coal = nil
			for attachmentsID, attachmentsData in pairs(attachments) do
				if attachmentsData:NKGetName() == "Coal" then
					coal = attachmentsData
				end
			end

			if(coal ~= nil) then
				self:NKRemoveChildObject(coal)
				coal:NKDeleteMe()
				self.m_fireTimer = self.m_fireTimer + 30.0
				--Eternus.GameState:PushToChatQueue("Consumed Coal")
			else
				--Eternus.GameState:PushToChatQueue("Missing Coal")
			end
		end


		if(self.m_fireTimer > 0) then
			local t = self:NKGetStackCount()
			--CL.println (t)
			t = t + dt * 1000


			if(t < 1000) then
				self:NKSetMaxStackCount(t + 1)
				self:NKSetStackCount(t)
				--self.object:NKSendDataToServer()
			else
				t = 1
				self:NKSetMaxStackCount(t + 1)
				self:NKSetStackCount(t)
				--self.object:NKSendDataToServer()

				input [ "Copper Ore" ] [ 1 ]:NKDeleteMe()
				input [ "Tin Ore" ] [ 1 ]:NKDeleteMe()
				local ouput = Eternus.GameObjectSystem:NKCreateGameObject("Latten", true)
				if ouput ~= nil then
					ouput:NKSetShouldRender(true, true)
					ouput:NKSetPosition(parentPosition +(outPositon:mul_quat(rotation)), false)
					ouput:NKSetOrientation(rotation)
				end
				--local ouput2 = Eternus.GameObjectSystem:NKCreateGameObject("Bamboo Shaft", true)
				--if ouput2 ~= nil then
				--	ouput2:NKSetShouldRender(true, true)
				--	ouput2:NKSetPosition(vec3.new(0,1.0,0), false)
				--	ouput2:NKSetOrientation(rotation)
				--	--ouput2:NKPlaceInWorld(false, false, false)
				--end
				--ouput:NKAddChildObject(ouput2)
				ouput:NKPlaceInWorld(false, false, false)
				ouput:NKGetPhysics():NKSetMotionType(PhysicsComponent.DYNAMIC)
				ouput:NKGetPhysics():NKSetLinearVelocity(vec3.new(2, 0, - 1))
			end

		end
	end

	--for inputID, inputData in pairs(input) do
	--	for itemID, itemData in pairs(inputData) do
	--		CL.println(inputID, itemData:NKGetName(), # inputData)
	--	end
	--end
	
	if self.m_fireTimer < 0.0 then
		self.m_fireTimer = 0.0
	end
end

-------------------------------------------------------------------------------
EntityFramework:RegisterGameObject(AutomaticFurnace)
