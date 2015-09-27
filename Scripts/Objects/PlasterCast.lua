include("Scripts/Interactable.lua")
include("Scripts/Objects/CLPlaceableObject.lua")
include("Scripts/Mixins/LiquidContainer.lua")

-------------------------------------------------------------------------------
if (PlasterCast == nil) then
	PlasterCast = CLPlaceableObject.Subclass("PlasterCast")
	PlasterCast.StaticMixin(Interactable)
end

-------------------------------------------------------------------------------
function PlasterCast:Constructor(args)
	self:Mixin(LiquidContainer, {maxAmount = 1})
	
	if (args.CastCrafting) then
		self.m_recipes = args.CastCrafting
	end
	self:SetMaxHitPoints(1)
	self:SetHitPoints(0.00001)
end

-------------------------------------------------------------------------------
function PlasterCast:PostLoad()
	PlasterCast.__super.PostLoad(self)
end

-------------------------------------------------------------------------------
function PlasterCast:Spawn()
end
 
-------------------------------------------------------------------------------
function PlasterCast:Despawn()
end

-------------------------------------------------------------------------------
function PlasterCast:Update(dt)
end

-------------------------------------------------------------------------------
function PlasterCast:GetDebuggingText()
	local out = "Liquid: " .. tostring(self.m_liquid) .. " " .. tostring(CL.round(self.m_liquidAmount,3)) .. "\n"
	local out = "Crafted: " .. tostring(self.m_craftedItem) .. "\n"
	return out
end

function PlasterCast:Interact(args)
	if (not Eternus.IsServer) then
		return
	end
	local player = args.player
	local equippedItem = args.heldItem
	
	if (player ~= nil) then
		if (equippedItem ~= nil) then
			if not self.m_craftedItem then
				if (equippedItem:InstanceOf(LiquidContainer)) then
					CL.println("LiquidContainer has liquid")
					for recipeName, recipeData in pairs(self.m_recipes) do
						CL.println("Checking ",recipeData.requiredLiquid,recipeData.requiredAmount)
						local hasLiquid = equippedItem:HasLiquid(nil, recipeData.requiredAmount, recipeData.requiredLiquid)
						if (not self.m_liquid or recipeData.requiredLiquid == self.m_liquid) and (hasLiquid == true or (hasLiquid and hasLiquid > 0)) then
							local liquid, amount = equippedItem:GetLiquid(nil, recipeData.requiredAmount, recipeData.requiredLiquid,self:NKGetPosition() + vec3(0,2,0), args.player)
							self.m_liquidAmountMax = recipeData.requiredAmount
							self.m_liquidAmount = self.m_liquidAmount + amount
							self.m_liquid = liquid
							
							self:SetMaxHitPoints(self.m_liquidAmountMax)
							self:SetHitPoints(self.m_liquidAmount)
							
							if (self.m_liquidAmount >= recipeData.requiredAmount) then
								self.m_craftedItem = recipeData.targetObject
							end
							return true
						end
					end
				end
				return true
			elseif (equippedItem:NKGetName() == "Bronze Hammer") then
				local newObj = Eternus.GameObjectSystem:NKCreateNetworkedGameObject(self.m_craftedItem, true, true);
				
				newObj:NKSetOrientation(self:NKGetWorldOrientation())
				newObj:NKSetPosition(self:NKGetWorldPosition(), false)
				local newObjPhysics = newObj:NKGetPhysics()
				if (newObjPhysics ~= nil) then
					newObjPhysics:NKSetMotionType(PhysicsComponent.DYNAMIC)
					newObjPhysics:NKEnableSimulation()
				end
				newObj:NKPlaceInWorld(true, false)
				
				local newObjInstance = newObj:NKGetInstance()
				if (newObjInstance ~= nil) then
					if (newObjInstance.OnPlace ~= nil) then
						newObjInstance:OnPlace()
					end
				end
				self:ProduceDrops(self:NKGetWorldPosition())
				self:NKDeleteMe()
				return true
			end
		end
	end

	return false
end

-------------------------------------------------------------------------------
function PlasterCast:Save( outData )
	PlasterCast.__super.Save(self, outData)
	outData.craftedItem = self.m_craftedItem
end

-------------------------------------------------------------------------------
function PlasterCast:Restore( inData, version )
	PlasterCast.__super.Restore(self, inData, version)
	self.m_craftedItem = inData.craftedItem or nil
end

-------------------------------------------------------------------------------
EntityFramework:RegisterGameObject(PlasterCast)
