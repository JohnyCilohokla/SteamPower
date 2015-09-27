include("Scripts/Interactable.lua")
include("Scripts/Objects/CLPlaceableObject.lua")

-------------------------------------------------------------------------------
if (SheetCast == nil) then
	SheetCast = CLPlaceableObject.Subclass("SheetCast")
	SheetCast.StaticMixin(Interactable)
end

-------------------------------------------------------------------------------
function SheetCast:Constructor(args)
	if (args.SheetTableCrafting == nil) then
		NKError("Missing SheetTableCrafting for SheetCast")
	end
	
	if (args.SheetTableCrafting) then
		self.m_recipes = args.SheetTableCrafting
	end
	self.m_cooldown = 0
end

-------------------------------------------------------------------------------
function SheetCast:PostLoad()
	SheetCast.__super.PostLoad(self)
end

-------------------------------------------------------------------------------
--[[function SheetCast:GetDebuggingText()
	local out = "Filters: "
	
	local filters = self:NKGetChildren();
	for filterID, filterData in pairs(filters) do 
		out = out .. filterData:NKGetName() .. " "
	end
	
	return out
end]]--

-------------------------------------------------------------------------------
function SheetCast:Spawn()
	self:NKEnableScriptProcessing(true)
end
 
-------------------------------------------------------------------------------
function SheetCast:Despawn()
end

-------------------------------------------------------------------------------
function SheetCast:Update(dt)
	if self.m_cooldown == 0 then
		return
	end
	self.m_cooldown = self.m_cooldown - dt
	if self.m_cooldown < 0 then
		self.m_cooldown = 0
	end
end

function SheetCast:Interact(args)
	if (not Eternus.IsServer) then
		return
	end
	
	if (self.m_cooldown ~= 0) then
		return
	end
	
	local player = args.player
	local equippedItem = args.heldItem

	if (player ~= nil) then
		if (equippedItem ~= nil) then
			if (equippedItem:InstanceOf(LiquidContainer)) then
				CL.println("LiquidContainer has liquid")
				for recipeName, recipeData in pairs(self.m_recipes) do
					CL.println("Checking ",recipeData.requiredLiquid,recipeData.requiredAmount)
					if equippedItem:HasLiquid(nil, recipeData.requiredAmount, recipeData.requiredLiquid) == true then
						equippedItem:GetLiquid(nil, recipeData.requiredAmount, recipeData.requiredLiquid,self:NKGetPosition() + vec3(0,2,0), args.player)
						self:SpawnTransitionObject(recipeData.transitionObject,recipeData.targetPosition,recipeData.targetObject,recipeData.transitionTime)
						return true
					end
				end
			end
			return true
		end
	end
		
	return false
end

function SheetCast:SpawnTransitionObject(transitionName, targetPosition, targetName, timeLeft)
	local newObj = Eternus.GameObjectSystem:NKCreateNetworkedGameObject(transitionName, true, true);
	
	newObj:NKSetOrientation(self:NKGetWorldOrientation())
	newObj:NKSetPosition(self:NKGetWorldPosition()+targetPosition, false)
	local newObjPhysics = newObj:NKGetPhysics()
	newObj:NKPlaceInWorld(true, false)
	
	local newObjInstance = newObj:NKGetInstance()
	newObjInstance:SetTarget( targetName, timeLeft )
	if (newObjInstance ~= nil) then
		if (newObjInstance.OnPlace ~= nil) then
			newObjInstance:OnPlace()
		end
	end
	self.m_cooldown = timeLeft
end

-------------------------------------------------------------------------------
function SheetCast:Save( outData )
	SheetCast.__super.Save(self, outData)
	outData.cooldown = self.m_cooldown
end

-------------------------------------------------------------------------------
function SheetCast:Restore( inData, version )
	SheetCast.__super.Restore(self, inData, version)
	self.m_cooldown = inData.cooldown or 0
end
-------------------------------------------------------------------------------
EntityFramework:RegisterGameObject(SheetCast)
