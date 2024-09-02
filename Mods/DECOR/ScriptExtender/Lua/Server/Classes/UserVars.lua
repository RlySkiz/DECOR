-- I don't think synchronisation is necessary here as these should all be server side changes?
-- Aahz easydye will use them. FocusCore also has them

-- TODO - this is currently indepenadant
-- make sure corresponding spells trigger varsChanges

-- If anything fails, register them in BootStrap instead

-- CONSTRUCTOR
--------------------------------------------------------------


-- TODO - these have to be set to a default
Ext.Vars.RegisterUserVariable("DECOR_Flaccid", {})
Ext.Vars.RegisterUserVariable("DECOR_Erect", {})
Ext.Vars.RegisterUserVariable("DECOR_AutoErection", {})

-- _P("[DECOR - UserVars] Registered AutoErection")

---@param type string - either "DECOR_Flaccid" or "DECOR_Erect"
---@param genital string - uuid
---@param character string - uuid
function UserVars:AssignGenital(type, genital, character)
      local e = Ext.Entity.Get(character)
      if type == "DECOR_Flaccid" then
            e.Vars.DECOR_Flaccid = genital
      elseif type == "DECOR_Erect" then
            e.Vars.DECOR_Erect = genital
      else
            _P("Invalid type ", type , " please choose ’DECOR_Flaccid’ or ’DECOR_Erect’ ")
      end
end

---@param type string - either "DECOR_Flaccid" or "DECOR_Erect"
---@param character string - uuid
function UserVars:GetGenital(type, character)
      local e = Ext.Entity.Get(character)
      if type == "DECOR_Flaccid" then
            e.Vars.DECOR_Flaccid = genital
      elseif type == "DECOR_Erect" then
            e.Vars.DECOR_Erect = genital
      else
            _P("Invalid type ", type , " please choose ’DECOR_Flaccid’ or ’DECOR_Erect’ ")
      end
end


---@param DECOR_AutoErection int -- bools are not possible for UserVars, maybe in a future SE update
---@param character string - uuid
function UserVars:SetAutoErection(autoErection, character)
    local e = Ext.Entity.Get(character)
    e.Vars.DECOR_AutoErection = autoErection
end


---@param DECOR_AutoErection bool
---@param character string - uuid
function UserVars:GetAutoErection(character)
    local e = Ext.Entity.Get(character)
    return e.Vars.DECOR_AutoErection
end