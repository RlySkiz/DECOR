Ext.Events.NetMessage:Subscribe(function(e) 
    if (e.Channel == "DECOR_NPCStrip") then
        local strip = Ext.Json.Parse(e.Payload)
        Ext.Resource.Get(strip.resource,"CharacterVisual").VisualSet.Slots = strip.naked
    end
    if (e.Channel == "DECOR_NPCDress") then
        local dress = Ext.Json.Parse(e.Payload)
        Ext.Resource.Get(dress.resource,"CharacterVisual").VisualSet.Slots = dress.dressed
    end
end)

-- Doesn't work with ModEvents because it needs to be replicated on all clients

-- Ext.ModEvents.DECOR.NPCStrip:Subscribe(function (payload)
--     local strip = Ext.Json.Parse(payload)
--     Ext.Resource.Get(strip.resource,"CharacterVisual").VisualSet.Slots = strip.naked
-- end)
-- Ext.ModEvents.DECOR.NPCDress:Subscribe(function (payload)
--     local dress = Ext.Json.Parse(payload)
--     Ext.Resource.Get(dress.resource,"CharacterVisual").VisualSet.Slots = dress.dressed
-- end)