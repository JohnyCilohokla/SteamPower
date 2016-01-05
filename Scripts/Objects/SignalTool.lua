include("Scripts/Objects/Equipable.lua")
include("Scripts/Mixins/Usable.lua")

-------------------------------------------------------------------------------
SignalTool = Equipable.Subclass("SignalTool")

-------------------------------------------------------------------------------
function SignalTool:Constructor(args)
	self.m_source = nil
end

-------------------------------------------------------------------------------
function SignalTool:SecondaryAction(args)
	if args.targetObj then
		if args.targetObj and args.targetObj:InstanceOf(SignalInterface) then
			if self.m_source then
				self.m_source:AddSignalListener(args.targetObj)
				self.m_source = nil
			else
				self.m_source = args.targetObj
			end
		end
		return true
	else
		return false
	end
end

-------------------------------------------------------------------------------
EntityFramework:RegisterGameObject(SignalTool)

