include("Scripts/Objects/CLPlaceableObject.lua")

-------------------------------------------------------------------------------
if (ElevatorShields == nil) then
	ElevatorShields = CLPlaceableObject.Subclass("ElevatorShields")
end

-------------------------------------------------------------------------------
function ElevatorShields:Constructor(args)
	self.sp_base = nil
end

-------------------------------------------------------------------------------
function ElevatorShields:PostLoad()
	ElevatorShields.__super.PostLoad(self)
end

-------------------------------------------------------------------------------
function ElevatorShields:Spawn()
end

function ElevatorShields:SetBase(base)
	self.sp_base = base
end
 
-------------------------------------------------------------------------------
function ElevatorShields:Despawn()
	if (self.sp_base~=nil) then
		self.sp_base:ShieldRemoved()
	end
end

-------------------------------------------------------------------------------
function ElevatorShields:Update(dt)
end

-------------------------------------------------------------------------------
EntityFramework:RegisterGameObject(ElevatorShields)
