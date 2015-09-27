include("Scripts/Interactable.lua")
include("Scripts/Objects/CLPlaceableObject.lua")

-------------------------------------------------------------------------------
if (TSorter == nil) then
	TSorter = CLPlaceableObject.Subclass("TSorter")

	TSorter.StaticMixin(Interactable)
	
end
	TSorter.CLConnectors = {}
	TSorter.CLConnectors["Front"] = { pos = vec3.new(0,1.881,-2.428), rotation = quat.new(0,0,1,0), opposite = quat.new(1,0,0,0), types = {"itemIn"}}
	TSorter.CLConnectors["SideL"] = { pos = vec3.new(1.799,1.881,0), rotation = quat.new(0.707107,0,-0.707107,0), opposite = quat.new(0.707107,0,0.707107,0), types = {"itemDropOut"}}
	TSorter.CLConnectors["SideR"] = { pos = vec3.new(-1.799,1.881,0), rotation = quat.new(0.707107,0,0.707107,0), opposite = quat.new(0.707107,0,-0.707107,0), types = {"itemDropOut"}}

-------------------------------------------------------------------------------
function TSorter:Constructor(args)
	self:Mixin(ConnectorInterface, args)
	self.m_filters = {}
end

-------------------------------------------------------------------------------
function TSorter:PostLoad()
	TSorter.__super.PostLoad(self)
end

-------------------------------------------------------------------------------
function TSorter:GetDebuggingText()
	local out = "Filters: "
	
	for filterID, filterData in pairs(self.m_filters) do 
		out = out .. filterID .. " \n"
	end
	
	return out
end

-------------------------------------------------------------------------------
function TSorter:Spawn()
	self:NKEnableScriptProcessing(true)

end
 
-------------------------------------------------------------------------------
function TSorter:Despawn()
end

-------------------------------------------------------------------------------
function TSorter:Update(dt)
	local parentPosition = self:NKGetWorldPosition();
	local rotation = self:NKGetWorldOrientation();
	
	local outRight = parentPosition+(vec3.new(-3.6,3.5,0):mul_quat(rotation));
	local outLeft = parentPosition+(vec3.new(3.6,3.5,0):mul_quat(rotation));
	
	local localPosition = vec3.new(0,2.19,-1.3);
	local localRotation = quat.new(1, vec3.new((-16.5/360),0,0));
	
	local sides = {distX = 1.1,distY = 0.785,distZ = 0.75};
	local input = getQBB(parentPosition, localPosition, rotation, localRotation, sides)
	

	for inputID,inputData in pairs(input) do
		for itemID,itemData in pairs(inputData) do
			
			--CL.println(inputID,itemData:NKGetName(), #inputData)
			--itemData:NKRemoveFromWorld();
			
			
			local active = false;
			local filters = self:NKGetChildren();
			for filterID, filterData in pairs(self.m_filters) do 
				if filterID == itemData:NKGetName() then
					active = true
				end
			end
			if (active==true) then
				itemData:NKSetPosition(outRight)
			else
				itemData:NKSetPosition(outLeft)
			end
			itemData:NKPlaceInWorld(true, false)
			itemData:NKSetShouldRender(true, true)
			itemData:NKGetPhysics():NKSetMotionType(PhysicsComponent.DYNAMIC)
			itemData:NKGetPhysics():NKSetLinearVelocity(vec3.new(0,-0.5,0))
			
		end
	end
end

function TSorter:Interact(args)
	if (not Eternus.IsServer) then
		return
	end

	local player = args.player
	local equippedItem = args.heldItem
	
	if (player ~= nil) then
		if (equippedItem ~= nil) then
			--interactor:Place()
			--self:ConsumeFuel(60, true)
			
			local active = nil;
			for filterID, filterData in pairs(self.m_filters) do 
				if filterID == equippedItem:NKGetName() then
					active = filterID
				end
			end
			
			if (active==nil) then
				self.m_filters[equippedItem:NKGetName()] = true
				Eternus.GameState:PushToChatQueue("Added new filer: "..equippedItem:NKGetName())
			else
				Eternus.GameState:PushToChatQueue("Removed filer: "..active)
				self.m_filters[active] = nil
			end
			
			return true
		else
			self.m_filters = {}
			Eternus.GameState:PushToChatQueue("Removed all filers")
		end
	else
		NKError("No Local Player?")
	end

	return false
end

-------------------------------------------------------------------------------
function TSorter:SerializeObject( gameObject )
	local objectData = {}
	objectData.m_name = gameObject:NKGetName()
	objectData.m_scale = gameObject:NKGetWorldScale()
	local rotation = gameObject:NKGetOrientation()
	objectData.m_rotation = {w = rotation:w(), x = rotation:x(), y = rotation:y(), z = rotation:z()}
	objectData.m_data = {}
	gameObject:Save(objectData.m_data)
	return objectData
end

-- TODO move to CL
function tablelength(T)
  local count = 0
  for _ in pairs(T) do count = count + 1 end
  return count
end

-------------------------------------------------------------------------------
function TSorter:NetSerialize( netWriter )
	TSorter.__super.NetSerialize(self, netWriter)
	netWriter:NKWriteInt(tablelength(self.m_filters))
	for v,k in pairs(self.m_filters) do 
		netWriter:NKWriteString(v)
	end
end

-------------------------------------------------------------------------------
function TSorter:NetDeserialize( netReader )
	TSorter.__super.NetDeserialize(self, netReader)
	local filtersCount = netReader:NKReadInt()
	self.m_filters = {}
	for i = 1, filtersCount do 
		local filter = netReader:NKReadString()
		self.m_filters[filter] = true
	end
end

-------------------------------------------------------------------------------
function TSorter:Save( outData )
	TSorter.__super.Save(self, outData)
	
	outData.filters = self.m_filters
end

-------------------------------------------------------------------------------
function TSorter:Restore( inData, version )
	TSorter.__super.Restore(self, inData, version)

	self.m_filters = inData.filters or {}
end

-------------------------------------------------------------------------------
EntityFramework:RegisterGameObject(TSorter)
