
-------------------------------------------------------------------------------
if (VoidPad == nil) then
	VoidPad = EternusEngine.GameObjectClass.Subclass("VoidPad")
end

-------------------------------------------------------------------------------
function VoidPad:Constructor(args)
	self.m_sleepTimer = 0.0
	self.m_flashTimer = 0.0
	self.m_flashing = false
	self.m_interactor = nil
end

-------------------------------------------------------------------------------
function VoidPad:PostLoad()
	VoidPad.__super.PostLoad(self)
	self:NKGetPhysics():NKEnableContactEvents()
end

-------------------------------------------------------------------------------
function VoidPad:Spawn()
end
 
-------------------------------------------------------------------------------
function VoidPad:Despawn()
end

-------------------------------------------------------------------------------
function VoidPad:OnContactCreated(data)
	if (data.otherBody~=nil and data.otherBody.gameobject~=nil)then
		data.otherBody.gameobject:NKRemoveFromWorld(true, true, true)
	end
end

-------------------------------------------------------------------------------
EntityFramework:RegisterGameObject(VoidPad)
