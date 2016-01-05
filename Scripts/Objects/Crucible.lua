include("Scripts/Interactable.lua")
include("Scripts/Objects/CLPlaceableObject.lua")
include("Scripts/Mixins/LiquidContainer.lua")
include("Scripts/Objects/Stone Furnace.lua")

-------------------------------------------------------------------------------
if (Crucible == nil) then
	Crucible = CLPlaceableObject.Subclass("Crucible")
	Crucible.MaxLiquidAmount = 100
	Crucible.StaticMixin(Interactable)
end

-------------------------------------------------------------------------------
function Crucible:Constructor(args)
	self:Mixin(LiquidContainer, {maxAmount = Crucible.MaxLiquidAmount})
	
	self.m_isHot = (self:NKGetName() == "Crucible Hot")
	self.m_isHard = (self:NKGetName() == "Crucible Hard")
	self.m_isEmpty = (self:NKGetName() == "Crucible Empty" or self:NKGetName() == "Crucible New")
	self.m_isOre = (self:NKGetName() == "Crucible Ore" or self:NKGetName() == "Crucible New Ore")
	self.m_isNew = (self:NKGetName() == "Crucible New Ore" or self:NKGetName() == "Crucible New")
	self.m_containerItems = {}
	self.m_containerItems["Iron Ore Clump"] = 0
	self.m_containerItems["Tin Ore"] = 0
	self.m_containerItems["Copper Ore"] = 0
	self.m_heat = 20
end

-------------------------------------------------------------------------------
function Crucible:PostLoad()
	Crucible.__super.PostLoad(self)
end

-------------------------------------------------------------------------------
function Crucible:Spawn()
	CL.println ("Crucible:Spawn()")
	self:SetMaxHitPoints(self.m_liquidAmountMax)
	self:_SetHitPoints(self.m_liquidAmount)
	self:NKEnableScriptProcessing(true)
end
 
-------------------------------------------------------------------------------
function Crucible:Despawn()
end
	
-------------------------------------------------------------------------------
function Crucible:OnEquip()
end

-------------------------------------------------------------------------------
function Crucible:_SetHitPoints(newValue)
	local value = self:GetHitPoints()
	if value ~= newValue then
		self:SetHitPoints(newValue)
	end
end

-------------------------------------------------------------------------------
function Crucible:Update(dt)
	if (not Eternus.IsServer) then
		return
	end
	if (self.m_isHot and self.m_liquidAmount <= 0) then
	end
	
	if (self.m_isHard or self.m_isHot) then
		self:_SetHitPoints(self.m_liquidAmount)
	else
		self:_SetHitPoints(0.0001)
	end
	
	if (self.m_isHard or self.m_isHot or self.m_isEmpty) then
		return
	end
	
	if (self.m_inInventory or self.m_ghostObject) then
		return
	end
	
	if self.m_isOre then
		if (self.m_heat > 1500 and self.m_containerItems["Iron Ore Clump"] >= 1) then
			self.m_liquid = "Iron"
			self.m_liquidAmount = self.m_containerItems["Iron Ore Clump"] * 25
			self.m_containerItems["Iron Ore Clump"] = 0
			self.m_containerItems["Tin Ore"] = 0
			self.m_containerItems["Copper Ore"] = 0
			self:ConvertTo("Crucible Hot")
			return true
		elseif (self.m_heat > 700 and self.m_containerItems["Tin Ore"] >= 1 and self.m_containerItems["Copper Ore"] >= 1) then
			self.m_liquid = "Bronze"
			self.m_liquidAmount = self.m_containerItems["Tin Ore"] * 50
			self.m_containerItems["Iron Ore Clump"] = 0
			self.m_containerItems["Tin Ore"] = 0
			self.m_containerItems["Copper Ore"] = 0
			self:ConvertTo("Crucible Hot")
			return true
		end
	end
	
	local gameobjects = Eternus.GameObjectSystem:NKGetGameObjectsInRadius(self:NKGetWorldPosition(), 1.5, "all", false)
	for objectID, gameobject in pairs(gameobjects) do
		if (gameobject:InstanceOf(StoneFurnace)) then
			self.m_heat = math.min(self.m_heat + 50*dt, 1600)
			return
		--elseif (gameobject:InstanceOf(LargeFurnace)) then
		--	self.m_heat = math.min(self.m_heat + 10*dt, 2000)
		--	return
		end
	end
end

-------------------------------------------------------------------------------
function Crucible:OnLiquidContainerEmpty(position, player)
	if player then
		local gameobject = Eternus.GameObjectSystem:NKCreateNetworkedGameObject("Crucible Empty", true, true)
		player:RemoveHandItem(-1)
		local pickedUp = player:Pickup(gameobject)
		if not pickedUp then
			player:DropItem(gameobject)
		end
		self:NKDeleteMe()
	else
		self.m_heat = 20
		self:ConvertTo("Crucible Empty")
	end
end

-------------------------------------------------------------------------------
function Crucible:Interact(args)
	CL.println("Crucible:Interact(args)")
	if (not Eternus.IsServer) then
		return
	end
	
	local player = args.player
	local equippedItem = args.heldItem
	
	if (player ~= nil) then
		if (equippedItem ~= nil) then
			if (self.m_isHard or self.m_isHot) then
				return false
			end
			
			local count = 0
			for itemName, itemAmount in pairs(self.m_containerItems) do
				count = count + itemAmount
			end
			if (count >= 4) then
				return false
			end
			
			local itemName = equippedItem:NKGetName()
			
			if (itemName == "Iron Ore Clump" and self.m_containerItems["Copper Ore"] == 0 and self.m_containerItems["Tin Ore"] == 0) then
				CL.println("Found ".."Iron Ore Clump")
				self.m_containerItems["Iron Ore Clump"] = self.m_containerItems["Iron Ore Clump"] + 1
				count = count + 1
				player:RemoveHandItem(1)
			end
			
			if ((itemName == "Copper Ore" or itemName == "Tin Ore") and self.m_containerItems["Iron Ore Clump"] == 0) then
				--
				if (itemName == "Copper Ore") then
					local otherItem = self:FindItem("Tin Ore", player.m_inventoryContainers[2])
					if otherItem then
						self:RemoveItem(player.m_inventoryContainers[2], otherItem)
					else
						otherItem = self:FindItem("Tin Ore", player.m_inventoryContainers[3])
						if otherItem then
							self:RemoveItem(player.m_inventoryContainers[3], otherItem)
						else
							return false
						end
					end
				end
				if (itemName == "Tin Ore") then
					local otherItem = self:FindItem("Copper Ore", player.m_inventoryContainers[2])
					if otherItem then
						self:RemoveItem(player.m_inventoryContainers[2], otherItem)
					else
						otherItem = self:FindItem("Copper Ore", player.m_inventoryContainers[3])
						if otherItem then
							self:RemoveItem(player.m_inventoryContainers[3], otherItem)
						else
							return false
						end
					end
				end
				self.m_containerItems["Copper Ore"] = self.m_containerItems["Copper Ore"] + 1
				self.m_containerItems["Tin Ore"] = self.m_containerItems["Tin Ore"] + 1
				count = count + 2
				player:RemoveHandItem(1)
			end
			
			if (self.m_isEmpty) then
				if (count>0) then
					self:ConvertTo(self.m_isNew and "Crucible New Ore" or "Crucible Ore")
					return true
				end
			end
			return true
			--Crucible:ConvertTo(name)
		else
		end
	end

	return false
end

-------------------------------------------------------------------------------
function Crucible:ConvertTo(name)
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


function Crucible:FindItem( itemName, container )
	for id, itemUI in pairs(container.m_items) do 
		if itemUI:GetName() == itemName then
			return id
		end
	end
	return nil
end

function Crucible:RemoveItem(container, slot)
	-- Reduce the stack count
	local cur = container.m_items[slot]:GetStackSize()
	cur = cur - 1
	if cur <= 0 then -- if the new stack size is 0 remove the item
		container:RemoveItem(container.m_items[slot], -1, slot) -- remove the item from the belt
	else
		container.m_items[slot]:SetStackSize(cur) -- set the new stack size
	end
end

-------------------------------------------------------------------------------
function Crucible:GetDebuggingText()
	local out = "Heat: " .. " " .. tostring(CL.round(self.m_heat,1)) .. "\n"
	out = out .. "Liquid: " .. tostring(self.m_liquid) .. " " .. tostring(CL.round(self.m_liquidAmount,3)) .. "\n"
	for itemName, itemAmount in pairs(self.m_containerItems) do
		out = out .. "Item: " .. tostring(itemName) .. " " .. tostring(itemAmount) .. "\n"
	end
	return out
end
	
-------------------------------------------------------------------------------
function Crucible:NetSerialize( netWriter )
	Crucible.__super.NetSerialize(self, netWriter)
	netWriter:NKWriteDouble(self.m_heat)
	netWriter:NKWriteDouble(self.m_containerItems["Iron Ore Clump"])
	netWriter:NKWriteDouble(self.m_containerItems["Tin Ore"])
	netWriter:NKWriteDouble(self.m_containerItems["Copper Ore"])
end

-------------------------------------------------------------------------------
function Crucible:NetDeserialize( netReader )
	Crucible.__super.NetDeserialize(self, netReader)
	self.m_heat = netReader:NKReadDouble()
	self.m_containerItems = {}
	self.m_containerItems["Iron Ore Clump"] = netReader:NKReadDouble()
	self.m_containerItems["Tin Ore"] = netReader:NKReadDouble()
	self.m_containerItems["Copper Ore"] = netReader:NKReadDouble()
end
-------------------------------------------------------------------------------
function Crucible:Save( outData )
	Crucible.__super.Save(self, outData)
	outData.containerItems = self.m_containerItems
	outData.heat = self.m_heat
end

-------------------------------------------------------------------------------
function Crucible:Restore( inData, version )
	Crucible.__super.Restore(self, inData, version)
	if (inData.containerItems) then
		self.m_containerItems = inData.containerItems
	end
	self.m_heat = inData.heat or 20
end
-------------------------------------------------------------------------------
EntityFramework:RegisterGameObject(Crucible)
