include("Scripts/Interactable.lua")
include("Scripts/Objects/CLPlaceableObject.lua")

-------------------------------------------------------------------------------
if (SignalButton == nil) then
	SignalButton = CLPlaceableObject.Subclass("SignalButton")
	
	SignalButton.StaticMixin(Interactable)
end

-------------------------------------------------------------------------------
function SignalButton:Constructor(args)
	self:Mixin(SignalInterface, nil)
end

-------------------------------------------------------------------------------
function SignalButton:Spawn()
end
 
-------------------------------------------------------------------------------
function SignalButton:Despawn()
end

function SignalButton:Interact(interactor)
	self:ToggleSignalState()
end

-------------------------------------------------------------------------------
EntityFramework:RegisterGameObject(SignalButton)
