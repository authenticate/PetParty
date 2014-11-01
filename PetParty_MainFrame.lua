--
-- Pet Party
-- Copyright 2014 James Lammlein
--
-- This file is part of Pet Party.
--
-- Pet Party is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- any later version.
--
-- Pet Party is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with Pet Party.  If not, see <http://www.gnu.org/licenses/>.
--

--
-- Constants.
--

local PET_PARTY_BUTTON_COUNT = 2;

-- A flag if the pet parties have been deserialized.
local is_deserialized = false;

-- Called when the main frame's create pet party button is clicked.
function PetParty.OnClickMainFrameButtonCreatePetParty()
    StaticPopup_Show("PetParty_CreatePetPartyDialog");
end

-- Called when the main frame's delete pet party button is clicked.
function PetParty.OnClickMainFrameButtonDeletePetParty()
    PetParty.DeletePetPartyFrame();
end

-- Called when the main frame receives an event.
function PetParty.OnEventMainFrame(self, event, arg1, ...)
    if (event == "ADDON_LOADED") and (arg1 == PetParty.ADDON_NAME) then
        -- Load Blizzard's pet journal.
        if not IsAddOnLoaded("Blizzard_PetJournal") then
            LoadAddOn("Blizzard_PetJournal")
        end
    elseif (event == "ADDON_LOADED") and (arg1 == "Blizzard_PetJournal") then
        -- Anchor the main frame to Blizzard's pet journal.
        PetParty_MainFrame:SetParent(PetJournal);
        PetParty_MainFrame:ClearAllPoints();
        PetParty_MainFrame:SetPoint("TOPLEFT", PetJournal, "TOPRIGHT");
        PetParty_MainFrame:SetPoint("BOTTOM", PetJournal);
        PetParty_MainFrame:SetWidth(PetParty.MAIN_FRAME_WIDTH);
    elseif (event == "PLAYER_ENTERING_WORLD") then
        if (PetPartyCharacterDB ~= nil) then
            if (PetPartyCharacterDB.main_frame_hidden ~= nil) then
                if (PetPartyCharacterDB.main_frame_hidden) then
                    PetParty_MainFrame:Hide();
                else
                    PetParty_MainFrame:Show();
                end
            end
        end
        
        PetParty.UpdateMainFrameLayout();
    elseif (event == "PLAYER_LOGOUT") then
        if (PetPartyCharacterDB == nil) then
            PetPartyCharacterDB = {};
        end
        
        -- Serialize whether or not the main frame is hidden.
        PetPartyCharacterDB.main_frame_hidden = not PetParty_MainFrame:IsShown();
        
        -- Serialize the pet parties.
        PetParty.SerializePetParties()
    end
end

-- Called when the main frame is hidden.
function PetParty.OnHideMainFrame()
    StaticPopup_Hide("PetParty_CreatePetPartyDialog");
end

-- Called when the main frame is loaded.
function PetParty.OnLoadMainFrame()
    -- Register the main frame for events.
    PetParty_MainFrame:RegisterEvent("ADDON_LOADED");
    PetParty_MainFrame:RegisterEvent("PLAYER_ENTERING_WORLD");
    PetParty_MainFrame:RegisterEvent("PLAYER_LOGOUT");
    
    -- Set the main frame's scripts.
    PetParty_MainFrame:SetScript("OnEvent", PetParty.OnEventMainFrame);
    
    -- Create the pet party scroll frame.
    PetParty.CreatePetPartyContentAndScrollFrames();
    
    -- Create the create pet party dialog box.
    StaticPopupDialogs["PetParty_CreatePetPartyDialog"] = {
        text = PetParty.L["Create a pet party."],
        button1 = PetParty.L["Create"],
        button2 = PetParty.L["Cancel"],
        OnAccept =
            function (self)
                local text = self.editBox:GetText();
                if (text ~= nil) and (text ~= "") then
                    PetParty.AddPetPartyFrame(text);
                end
            end
        ,
        OnShow =
            function (self, data)
                if (data ~= nil) then
                    self.editBox:SetText(data);
                else
                    self.button1:Disable();
                end
            end
        ,
        EditBoxOnTextChanged =
            function (self)
                local text = self:GetText();
                if (text ~= nil) and (text ~= "") then
                    self:GetParent().button1:Enable();
                else
                    self:GetParent().button1:Disable();
                end
            end
        ,
        EditBoxOnEnterPressed =
            function (self)
                if (self:GetParent().button1:IsEnabled()) then
                    self:GetParent().button1:Click("LeftButton", false);
                end
            end
        ,
        EditBoxOnEscapePressed =
            function (self)
                self:GetParent():Hide();
            end
        ,
        hasEditBox = true,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
        preferredIndex = 3,
    };
    
    -- Localize the UI.
    PetParty_MainFrame_Title_Font_String:SetText(PetParty.L["Pet Party"]);
    PetParty_MainFrame_Button_Create_Pet_Party:SetText(PetParty.L["Create"]);
    PetParty_MainFrame_Button_Delete_Pet_Party:SetText(PetParty.L["Delete"]);
end

-- Called when the main frame is shown.
function PetParty.OnShowMainFrame()
    if (not is_deserialized) then
        if (PetPartyDB ~= nil) then
            -- Deserialize the pet parties.
            PetParty.DeserializePetParties();
        end
        
        -- Update the flag.
        is_deserialized = true;
        
        -- Update all pet frames' information.
        for i = 1, PetParty.PETS_PER_PARTY do
            PetParty.UpdatePetInformationPetInformationFrame(i);
        end
    end
end

-- Call to update the main frame layout.
function PetParty.UpdateMainFrameLayout()
    -- Calculate the width of all the pet party buttons.
    local button_width = PetParty_MainFrame_Button_Create_Pet_Party:GetWidth() +
                         PetParty_MainFrame_Button_Delete_Pet_Party:GetWidth();
    
    -- Starting locations.
    local start_x = PetParty.MAIN_FRAME_OFFSET_LEFT;
    local start_y = PetParty.MAIN_FRAME_OFFSET_TOP - PetParty.TRAINING_PET_INFORMATION_FRAME_HEIGHT;
    
    -- Calculate the offsets.
    local offset_x = (PetParty_MainFrame:GetWidth() - PetParty.MAIN_FRAME_OFFSET_LEFT + PetParty.MAIN_FRAME_OFFSET_RIGHT - button_width ) /
                     (PET_PARTY_BUTTON_COUNT + 1);
    local offset_y = 0;
    
    -- Update the position of the create pet party button.
    PetParty_MainFrame_Button_Create_Pet_Party:ClearAllPoints();
    PetParty_MainFrame_Button_Create_Pet_Party:SetPoint("TOPLEFT", start_x + offset_x, start_y + offset_y);
    
    -- Update the current offsets.
    offset_x = offset_x + PetParty_MainFrame_Button_Create_Pet_Party:GetWidth() + offset_x;
    
    -- Update the position of the delete pet party button.
    PetParty_MainFrame_Button_Delete_Pet_Party:ClearAllPoints();
    PetParty_MainFrame_Button_Delete_Pet_Party:SetPoint("TOPLEFT", start_x + offset_x, start_y + offset_y);
end
