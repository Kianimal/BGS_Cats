local PedPrompt = nil
local cooldown = 0

local function CreatePrompt(name, group)
	PedPrompt = PromptRegisterBegin()
	PromptSetControlAction(PedPrompt, 0xE3BF959B)
	PromptSetText(PedPrompt, CreateVarString(10, "LITERAL_STRING", name))
	PromptSetEnabled(PedPrompt, true)
	PromptSetVisible(PedPrompt, true)
	PromptSetHoldMode(PedPrompt, 1000)
	PromptSetGroup(PedPrompt, group)
	PromptRegisterEnd(PedPrompt)
end

CreateThread(function()
  while true do
    Wait(100)

    local pid = PlayerId()
    local retval, entity = GetPlayerTargetEntity(pid)

    if retval and cooldown == 0 and #(GetEntityCoords(PlayerPedId() - GetEntityCoords(entity)) < 2) then
      local model_hash = GetEntityModel(entity)
      if model_hash == 1462895032 then
        local promptGroup = PromptGetGroupIdForTargetEntity(entity)
        local promptName = Config.Language.PromptText
        if not PedPrompt then
          CreatePrompt(promptName, promptGroup)
        end
        if PromptHasHoldModeCompleted(PedPrompt) then
          cooldown = 1
          Citizen.InvokeNative(0xCD181A959CFDD7F4, PlayerPedId(), entity, GetHashKey("Interaction_Dog_Patting"), 0, 1)
        end
      end
    elseif cooldown ~= 0 then
      PromptDelete(PedPrompt)
      PedPrompt = nil
      cooldown = cooldown + 1
      if cooldown > 50 then
        cooldown = 0
      end
    else
      if PedPrompt then
        PromptDelete(PedPrompt)
      end
      PedPrompt = nil
    end
  end
end)