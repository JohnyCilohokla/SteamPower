include("Scripts/Objects/CLPlaceableObject.lua")

-------------------------------------------------------------------------------
if (NullObjectTemporary == nil) then
	NullObjectTemporary = CLPlaceableObject.Subclass("NullObjectTemporary")
end

-------------------------------------------------------------------------------
function NullObjectTemporary:Constructor(args)
end

-------------------------------------------------------------------------------
function NullObjectTemporary:PostLoad()
	NullObjectTemporary.__super.PostLoad(self)
end

-------------------------------------------------------------------------------
function NullObjectTemporary:Spawn()
end
 
-------------------------------------------------------------------------------
function NullObjectTemporary:Despawn()
end


-------------------------------------------------------------------------------
function NullObjectTemporary:Update(dt)
end


-------------------------------------------------------------------------------
EntityFramework:RegisterGameObject(NullObjectTemporary)
