include("Scripts/Interactable.lua")
include("Scripts/Objects/CLPlaceableObject.lua")

-- Temporary Solution
include("Scripts/Objects/ConveyorBelt.lua")
include("Scripts/Objects/ConveyorRamp.lua")
include("Scripts/Objects/TSorter.lua")
include("Scripts/Objects/ElevatorMiddle.lua")
-- Temporary Solution

-------------------------------------------------------------------------------
if (Frame == nil) then
	Frame = CLPlaceableObject.Subclass("Frame")
	Frame.StaticMixin(Interactable)
end

-- Temporary Solution
Frame.ElevatorConnectors = {}
Frame.ElevatorConnectors["Top"] = { pos = vec3.new(0,7.740,0), rotation = quat.new(0.707107,0.707107,0,0), opposite = quat.new(0.707107,-0.707107,0,0), types = {"itemLogicalOut"}}
Frame.ElevatorConnectors["Bottom"] = { pos = vec3.new(0,0.428,0), rotation = quat.new(0.707107,-0.707107,0,0), opposite = quat.new(0.707107,0.707107,0,0), types = {"itemLogicalIn"}}

Frame.ElevatorConnectors["Front"] = { pos = vec3.new(0,1.985,2.1), rotation = quat.new(1,0,0,0), opposite = quat.new(0,0,1,0), types = {"itemIn"}}
Frame.ElevatorConnectors["Back"] = { pos = vec3.new(0,1.985,-2.1), rotation = quat.new(0,0,1,0), opposite = quat.new(1,0,0,0), types = {"itemIn"}}
Frame.ElevatorConnectors["SideL"] = { pos = vec3.new(2.1,1.985,0), rotation = quat.new(0.707107,0,-0.707107,0), opposite = quat.new(0.707107,0,0.707107,0), types = {"itemIn"}}
Frame.ElevatorConnectors["SideR"] = { pos = vec3.new(-2.1,1.985,0), rotation = quat.new(0.707107,0,0.707107,0), opposite = quat.new(0.707107,0,-0.707107,0), types = {"itemIn"}}
-- Temporary Solution

-------------------------------------------------------------------------------
function Frame:Constructor(args)
	self.m_frameLayout = CL.FrameLayouts.parse(args.attachmentPointsRef);
	self.m_targetObject = args.targetObject;
	self.m_targets = {};
	self.m_targetID = 1;
	if args.targets then
		for key,data in pairs(args.targets) do
			table.insert(self.m_targets, data)
		end
	else
		table.insert(self.m_targets, {name = args.targetObject})
	end
	for v,k in pairs(self.m_targets) do
		if k.name == self.m_targetObject then
			self.m_targetID = v
		end
	end
	
	-- Temporary Solution
	if (self:NKGetName() == "Conveyor Belt Frame") then
		self.CLConnectors = ConveyorBelt.CLConnectors
	elseif (self:NKGetName() == "Conveyor Ramp Frame") then
		self.CLConnectors = ConveyorRamp.CLConnectors
	elseif (self:NKGetName() == "T Sorter Frame") then
		self.CLConnectors = TSorter.CLConnectors
	elseif (self:NKGetName() == "Elevator Frame") then
		self.CLConnectors = Frame.ElevatorConnectors
	end
	-- Temporary Solution
	self:Mixin(ConnectorInterface, args)
end

-------------------------------------------------------------------------------
function Frame:PostLoad()
	Frame.__super.PostLoad(self)
end

-------------------------------------------------------------------------------
Frame.RegisterScriptEvent("Event_AttachObject",
	{
		objectName = "string",
		position = "vec3",
		rotation = "quat"
	}
)
-------------------------------------------------------------------------------
-- TODO
function Frame:Event_AttachObject(args)
	CL.out("Creating " .. args.objectName)
	local newObject = Eternus.GameObjectSystem:NKCreateGameObject(args.objectName, true)
	if not newObject then
		CL.out("Failed to create " .. args.objectName)
	end
	self:NKAddChildObject(newObject)
	newObject:NKSetPosition( args.position, false )
	newObject:NKSetOrientation( args.rotation, false )

	newObject:NKGetPhysics():NKDeactivate()
	newObject:NKPlaceInWorld(true, false)
end


-------------------------------------------------------------------------------
function Frame:OnPlace()
end


-------------------------------------------------------------------------------
Frame.RegisterScriptEvent("NetEvent_DetachAll",
	{
	}
)
-------------------------------------------------------------------------------
function Frame:PickedUp()
	if (self.m_inInventory or self.m_ghostObject or not Eternus.IsServer) then
		return
	end
	if Eternus.IsServer then
		self:RaiseNetEvent("NetEvent_DetachAll", {})
	end
	Frame.__super.PickedUp(self)
end
-------------------------------------------------------------------------------
function Frame:OnDestroy()
	if (self.m_inInventory or self.m_ghostObject or not Eternus.IsServer) then
		return
	end
	if Eternus.IsServer then
		self:RaiseNetEvent("NetEvent_DetachAll", {})
	end
end

-------------------------------------------------------------------------------
function Frame:NetEvent_DetachAll()
	CL.out("Frame:NetEvent_DetachAll()")
	local attachments = self:NKGetChildren();
	if Eternus.IsServer then
		for attachmentID, attachmentData in pairs(attachments) do 
			local newObject = Eternus.GameObjectSystem:NKCreateNetworkedGameObject(attachmentData:NKGetName(), true, true)
			if not newObject then
				CL.out("Failed to create " .. objectName)
			end
			newObject:NKSetPosition( attachmentData:NKGetWorldPosition(), false )
			newObject:NKSetOrientation( attachmentData:NKGetWorldOrientation(), false )

			newObject:NKGetPhysics():NKActivate()
			newObject:NKPlaceInWorld(true, false)
			
			self:NKRemoveChildObject(attachmentData)
			attachmentData:NKDeleteMe()
		end
	elseif Eternus.IsClient then
		for attachmentID, attachmentData in pairs(attachments) do
			attachmentData:NKDeleteMe()
		end
	end
end

-------------------------------------------------------------------------------
function Frame:Spawn()
end

-------------------------------------------------------------------------------
function Frame:ListIngredients()
	local attachmentsReq = {}
	local attachmentsAvailable = {}
	
	local selfPos = self:NKGetWorldPosition();
	local selfInvRot = self:NKGetWorldOrientation():NKGetInverse();
	
	local attachmentsPositions = {};
	local attachments = self:NKGetChildren();
	for attachmentID, attachmentData in pairs(attachments) do 
		attachmentsPositions[(attachmentData:NKGetWorldPosition()-selfPos):mul_quat(selfInvRot)] = attachmentData:NKGetName()
	end
	
	for _, connectorData in pairs(self.m_frameLayout) do 
		for locationID, locationData in pairs(connectorData.locations) do 
			attachmentsReq[connectorData.ingredients[1]] = (attachmentsReq[connectorData.ingredients[1]] or 0) + 1
			local attachments = self:NKGetChildren();
			for attachmentPosition, attachmentName in pairs(attachmentsPositions) do
				if (CL.compareVec3(locationData.position,attachmentPosition) and connectorData.ingredients[1] == attachmentName) then
					--match
					attachmentsAvailable[attachmentName] = (attachmentsAvailable[attachmentName] or 0) + 1
				end
			end
		end
	end
	return attachmentsReq, attachmentsAvailable;
end
 
 
-------------------------------------------------------------------------------
function Frame:GetDebuggingText()
	local out = ""
	
	local attachmentsReq,attachmentsAvailable = self:ListIngredients()
	if self.m_targetObject then
		out = out .. "Target " .. self.m_targetObject .."\n"
	end
	
	for attachmentsReq, amount in pairs(attachmentsReq) do 
		out = out .. attachmentsReq .. " " .. (attachmentsAvailable[attachmentsReq] or 0) .. "/" .. amount .."\n"
	end
	
	return out
end

-------------------------------------------------------------------------------
function Frame:Despawn()
end

-------------------------------------------------------------------------------
function Frame:Update(dt)
end

function Frame:Interact(args)
	if (self.m_inInventory or self.m_ghostObject or not Eternus.IsServer) then
		return
	end
	
	local player = args.player
	local equippedItem = args.heldItem

	if (player ~= nil) then
		if (equippedItem ~= nil) then
			if (equippedItem:NKGetName() == "Iron Wrench") then
				self.m_targetID = self.m_targetID + 1
				if self.m_targets[self.m_targetID] then
					self.m_targetObject = self.m_targets[self.m_targetID].name
				else
					self.m_targetObject = self.m_targets[1].name
					self.m_targetID = 1
				end
				return true
			else
				local selfPos = self:NKGetWorldPosition();
				local selfInvRot = self:NKGetWorldOrientation():NKGetInverse();
				
				local attachmentsPositions = {};
				local attachments = self:NKGetChildren();
				for attachmentID, attachmentData in pairs(attachments) do 
					attachmentsPositions[(attachmentData:NKGetWorldPosition()-selfPos):mul_quat(selfInvRot)] = attachmentData:NKGetName()
				end
		
				for _, connectorData in pairs(self.m_frameLayout) do 
					if (connectorData.ingredients[1] == equippedItem:NKGetName()) then
						for locationID, locationData in pairs(connectorData.locations) do 
							local matchAll = false;
							for attachmentPosition, attachmentName in pairs(attachmentsPositions) do
								if (CL.compareVec3(locationData.position,attachmentPosition)) then
									matchAll = true;
								end
							end
							if (not matchAll) then
								self:RaiseNetEvent("Event_AttachObject",{objectName=connectorData.ingredients[1], position=locationData.position, rotation=locationData.rotation})
								player:RemoveHandItem(1)
								return true
							end
						end
					end
				end
			end
			return false
		else
			local attachmentsReq,attachmentsAvailable = self:ListIngredients()
			local _matchAll = true
			for attachmentsReq, amount in pairs(attachmentsReq) do 
				if ((attachmentsAvailable[attachmentsReq] or 0) < amount) then
					_matchAll = false;
				end
			end
			if (_matchAll) then
				CL.println("Done!");
				local selfPos = self:NKGetWorldPosition();
				local selfInvRot = self:NKGetWorldOrientation():NKGetInverse();
				
				local attachmentsPositions = {};
		
				for _, connectorData in pairs(self.m_frameLayout) do 
					for locationID, locationData in pairs(connectorData.locations) do 
						local attachments = self:NKGetChildren();
						for attachmentID, attachmentData in pairs(attachments) do 
							if (CL.compareVec3(locationData.position,(attachmentData:NKGetWorldPosition()-selfPos):mul_quat(selfInvRot))) then
								attachmentData:NKDeleteMe()
							end
						end
					end
				end
				
				-- drop all other attachments
				
				local newObj = Eternus.GameObjectSystem:NKCreateNetworkedGameObject(self.m_targetObject, true, true);
				
				newObj:NKSetOrientation(self:NKGetWorldOrientation())
				newObj:NKSetPosition(self:NKGetWorldPosition(), false)
				--newObj:NKGetPhysics()
				newObj:NKPlaceInWorld(true, false)
				
				local newObjInstance = newObj:NKGetInstance()
				if (newObjInstance ~= nil) then
					if (newObjInstance.OnPlace ~= nil) then
						newObjInstance:OnPlace()
					end
				end
				
				self:NKRemoveFromWorld(true, true, true)
				--self:NKDeleteMe()
				
			end
		end
	end

	return false
end
-------------------------------------------------------------------------------
function Frame:NetSerializeConstruction( stream )
	Frame.__super.NetSerializeConstruction(self, stream)
	
	local attachments = self:NKGetChildren();
	
	local i = 0
	for attachmentID, attachmentData in pairs(attachments) do 
		i = i + 1
	end
	stream:NKWriteInt(i)
	
	for attachmentID, attachmentData in pairs(attachments) do
		local name = attachmentData:NKGetName()
		CL.out("Sending "..name)
		stream:NKWriteString(name)
		stream:NKWriteVec3(attachmentData:NKGetPosition())
		CL.out("Sending "..attachmentData:NKGetPosition():NKToString())
		local orient = attachmentData:NKGetOrientation()
		stream:NKWriteDouble(orient:w())
		stream:NKWriteDouble(orient:x())
		stream:NKWriteDouble(orient:y())
		stream:NKWriteDouble(orient:z())
	end
	
	self:NetSerialize(stream)
end

-------------------------------------------------------------------------------
function Frame:NetDeserializeConstruction( stream )
	Frame.__super.NetDeserializeConstruction(self, stream)
	
	local attachements = stream:NKReadInt()
	
	for i = 1, attachements do
		local name = stream:NKReadString()
		local position = stream:NKReadVec3()
		
		local orient_w = stream:NKReadDouble()
		local orient_x = stream:NKReadDouble()
		local orient_y = stream:NKReadDouble()
		local orient_z = stream:NKReadDouble()
		local orient = quat(orient_w,orient_x,orient_y,orient_z)
		
		CL.out("Got "..name)
		CL.out("Got "..position:NKToString())
		CL.out("Got "..orient:NKToString())
		self:Event_AttachObject({objectName=name, position=position, rotation=orient})
	end
	
	self:NetDeserialize(stream)
end

-------------------------------------------------------------------------------
function Frame:NetSerialize( stream )
	stream:NKWriteString(self.m_targetObject)
end

-------------------------------------------------------------------------------
function Frame:NetDeserialize( stream )
	self.m_targetObject = stream:NKReadString()
	for v,k in pairs(self.m_targets) do
		if k.name == self.m_targetObject then
			self.m_targetID = v
		end
	end
end

-------------------------------------------------------------------------------
function Frame:Save( outData )
	Frame.__super.Save(self, outData)
	
	outData.targetObject = self.m_targetObject
end

-------------------------------------------------------------------------------
function Frame:Restore( inData, version )
	Frame.__super.Restore(self, inData, version)
	if inData.targetObject then
		self.m_targetObject = inData.targetObject
		for v,k in pairs(self.m_targets) do
			if k.name and k.name == self.m_targetObject then
				self.m_targetID = v
			end
		end
	end
end
-------------------------------------------------------------------------------
EntityFramework:RegisterGameObject(Frame)
