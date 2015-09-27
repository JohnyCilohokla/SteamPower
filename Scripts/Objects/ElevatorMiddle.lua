include("Scripts/Objects/CLPlaceableObject.lua")

-------------------------------------------------------------------------------
if (ElevatorMiddle == nil) then
	ElevatorMiddle = CLPlaceableObject.Subclass("ElevatorMiddle")
end
	
	ElevatorMiddle.CLConnectors = {}
	ElevatorMiddle.CLConnectors["Top"] = { pos = vec3.new(0,7.740,0), rotation = quat.new(0.707107,0.707107,0,0), opposite = quat.new(0.707107,-0.707107,0,0), types = {"itemLogicalOut"}}
	ElevatorMiddle.CLConnectors["Bottom"] = { pos = vec3.new(0,0.428,0), rotation = quat.new(0.707107,-0.707107,0,0), opposite = quat.new(0.707107,0.707107,0,0), types = {"itemLogicalIn"}}

-------------------------------------------------------------------------------
function ElevatorMiddle:Constructor(args)
	self:Mixin(ConnectorInterface, args)
end

-------------------------------------------------------------------------------
EntityFramework:RegisterGameObject(ElevatorMiddle)
