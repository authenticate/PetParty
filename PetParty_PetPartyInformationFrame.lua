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

local PADDING = 2;

local BUTTON_WIDTH = 22;
local BUTTON_HEIGHT = 22;

local BUTTON_ICON_WIDTH = 4;
local BUTTON_ICON_HEIGHT = 4;

local BUTTON_ICON_R = 0;
local BUTTON_ICON_G = 1;
local BUTTON_ICON_B = 0;
local BUTTON_ICON_A = 1;

local BUTTON_OFFSET_Y = -BUTTON_ICON_HEIGHT;

local PET_INFORMATION_PARTY_PET_INFORMATION_HEIGHT = PetParty.PET_INFORMATION_PARTY_FRAME_HEIGHT / PetParty.PETS_PER_PARTY;

local PET_INFORMATION_PARTY_BUTTON_COUNT = 2;

local PET_INFORMATION_PARTY_R = 0;
local PET_INFORMATION_PARTY_G = 0;
local PET_INFORMATION_PARTY_B = 0;
local PET_INFORMATION_PARTY_A = 0;

local PET_INFORMATION_PARTY_PET_INFORMATION_R = 0.2;
local PET_INFORMATION_PARTY_PET_INFORMATION_G = 0.2;
local PET_INFORMATION_PARTY_PET_INFORMATION_B = 0.2;
local PET_INFORMATION_PARTY_PET_INFORMATION_A = 0.5;

local PET_INFORMATION_FONT = "Fonts\\FRIZQT__.TTF";
local PET_INFORMATION_FONT_SIZE = 18;

local PET_INFORMATION_TITLE_R = 1;
local PET_INFORMATION_TITLE_G = 1;
local PET_INFORMATION_TITLE_B = 1;
local PET_INFORMATION_TITLE_A = 1;

-- Called when the pet party information frame's activate button is clicked.
function PetParty.OnClickPetPartyInformationFrameButtonActivate()
    -- For each pet...
    for i = 1, PetParty.PETS_PER_PARTY do
        -- Get the pet information frame.
        local pet_information_frame = PetParty_PetPartyInformationFrame.pet_frames[i];
        
        -- Activate the pets from the UI.
        C_PetJournal.SetPetLoadOutInfo(i, pet_information_frame.pet_guid);
        
        -- Get the ability GUIDs.
        local ability_guids = {};
        
        for j = 1, PetParty.ABILITY_GROUPS_PER_PET do
            for k = 1, PetParty.ABILITIES_PER_ABILITY_GROUP do
                -- Calculate the index.
                local index = ((j - 1) + ((k - 1) * PetParty.ABILITY_GROUPS_PER_PET)) + 1;
                
                -- Get the pet ability button.
                local ability_button = pet_information_frame.pet_ability_buttons[index];
                
                -- If the ability is active...
                if (ability_button.ability_active) then
                    -- Add the ability GUID to the array.
                    table.insert(ability_guids, ability_button.ability_id);
                end
            end
        end
        
        -- Active the pets' abilities from the UI.
        for j = 1, PetParty.ABILITY_GROUPS_PER_PET do
            C_PetJournal.SetAbility(i, j, ability_guids[j]);
        end
    end
end

-- Called when the pet party information frame's save button is clicked.
function PetParty.OnClickPetPartyInformationFrameButtonSave()
    -- Store the pets from the UI into the selected pet party frame.
    if (PetParty.pet_party_frame_selected ~= nil) then
        for i = 1, PetParty.PETS_PER_PARTY do
            -- Get the pet information frame.
            local pet_information_frame = PetParty_PetPartyInformationFrame.pet_frames[i];
            
            -- Get the ability GUIDs.
            local ability_guids = {};
            
            for j = 1, PetParty.ABILITY_GROUPS_PER_PET do
                for k = 1, PetParty.ABILITIES_PER_ABILITY_GROUP do
                    -- Calculate the index.
                    local index = ((j - 1) + ((k - 1) * PetParty.ABILITY_GROUPS_PER_PET)) + 1;
                    
                    -- Get the pet ability button.
                    local ability_button = pet_information_frame.pet_ability_buttons[index];
                    
                    -- If the ability is active...
                    if (ability_button.ability_active) then
                        -- Add the ability GUID to the array.
                        table.insert(ability_guids, ability_button.ability_id);
                    end
                end
            end
            
            -- Store the data.
            PetParty.pet_party_frame_selected.pet_guids[i] = pet_information_frame.pet_guid;
            PetParty.pet_party_frame_selected.ability_guids[i] = ability_guids;
        end
        
        -- Store the pet parties.
        PetParty.SerializePetParties();
    end
end

-- Called when the pet party information frame receives an event.
function PetParty.OnEventPetPartyInformationFrame(self, event, arg1, ...)
    if (event == "PET_JOURNAL_LIST_UPDATE") then
        -- Load some initial pets into the pet frames.
        for i = 1, PetParty.PETS_PER_PARTY do
            if (PetParty_PetPartyInformationFrame.pet_frames[i].pet_guid == nil) then
                local petGUID, ability1, ability2, ability3, locked = C_PetJournal.GetPetLoadOutInfo(i);
                if (not locked) and (petGUID ~= nil) then
                    PetParty.SetPetGUIDPetInformationFrame(i, petGUID);
                    
                    local ability_guids = { ability1, ability2, ability3 };
                    PetParty.SetPetAbilityGUIDsPetInformationFrame(i, ability_guids)
                end
            end
        end
    end
end

-- Called when the pet party information frame is loaded.
function PetParty.OnLoadPetPartyInformationFrame()
    -- Configure the pet party information frame.
    PetParty_PetPartyInformationFrame:ClearAllPoints();
    PetParty_PetPartyInformationFrame:SetPoint("LEFT", PetParty_MainFrame, PetParty.MAIN_FRAME_OFFSET_LEFT, 0);
    PetParty_PetPartyInformationFrame:SetPoint("RIGHT", PetParty_MainFrame, PetParty.MAIN_FRAME_OFFSET_RIGHT, 0);
    PetParty_PetPartyInformationFrame:SetPoint("TOP", PetParty_PetPartyScrollFrame, "BOTTOM", 0, -PADDING);
    PetParty_PetPartyInformationFrame:SetPoint("BOTTOM", PetParty_MainFrame, "BOTTOM", 0, PetParty.MAIN_FRAME_OFFSET_BOTTOM);
    
    -- Register the per party information frame for events.
    PetParty_PetPartyInformationFrame:RegisterEvent("PET_JOURNAL_LIST_UPDATE");
    
    -- Set the per party information frame's scripts.
    PetParty_PetPartyInformationFrame:SetScript("OnEvent", PetParty.OnEventPetPartyInformationFrame);
    
    -- Configure the pet party information frame's background texture.
    local texture = PetParty_PetPartyInformationFrame:CreateTexture();
    texture:SetAllPoints();
    texture:SetTexture(PET_INFORMATION_PARTY_R,
                       PET_INFORMATION_PARTY_G,
                       PET_INFORMATION_PARTY_B,
                       PET_INFORMATION_PARTY_A);
    
    -- Initialize the pet party information frame's pet frames variable.
    PetParty_PetPartyInformationFrame.pet_frames = {};
    
    --
    -- Configure the pet party information frame's pet frames.
    --
    
    local parents = { PetParty_PetPartyInformationFrame };
    local anchors = { "TOPLEFT", "BOTTOMLEFT", "BOTTOMLEFT" };
    local offset_y_s = { -BUTTON_HEIGHT, 0, 0 };
    
    for i = 1, PetParty.PETS_PER_PARTY do
        -- Create a pet party information frame.
        local pet_information_frame = CreateFrame("Frame", nil, PetParty_PetPartyInformationFrame);
        pet_information_frame:EnableMouse(true);
        pet_information_frame:RegisterForDrag("LeftButton");
        pet_information_frame:ClearAllPoints();
        pet_information_frame:SetPoint("TOPLEFT", parents[i], anchors[i], 0, offset_y_s[i]);
        pet_information_frame:SetPoint("RIGHT", PetParty_PetPartyInformationFrame);
        pet_information_frame:SetHeight(PET_INFORMATION_PARTY_PET_INFORMATION_HEIGHT);
        
        -- Update the parent array.
        parents[i + 1] = pet_information_frame;
        
        -- Add a handler for when the mouse is released on the pet information frame.
        pet_information_frame:SetScript("OnMouseUp",
            function(self, button)
                local cursorType, petID = GetCursorInfo();
                if cursorType == "battlepet" then
                    -- Store the pet GUID.
                    PetParty.SetPetGUIDPetInformationFrame(self.id, petID);
                    
                    -- Cache the pet GUID of the pet currently loaded in slot one.
                    local petGUID_cache, ability1_cache, ability2_cache, ability3_cache, locked_cache = C_PetJournal.GetPetLoadOutInfo(1);
                    
                    -- Load the pet into slot one.
                    C_PetJournal.SetPetLoadOutInfo(1, petID);
                    
                    -- Get the active abilities of the pet from slot one.
                    local petGUID, ability1, ability2, ability3, locked = C_PetJournal.GetPetLoadOutInfo(1);
                    
                    -- Reset slot one.
                    C_PetJournal.SetPetLoadOutInfo(1, petGUID_cache);
                    
                    -- Store the pet's abilities' GUIDs.
                    local ability_guids = { ability1, ability2, ability3 };
                    PetParty.SetPetAbilityGUIDsPetInformationFrame(self.id, ability_guids)
                    
                    -- Reset the cursor.
                    ClearCursor();
                end
            end
        );
        
        pet_information_frame.id = i;
        pet_information_frame.pet_guid = nil;
        
        texture = pet_information_frame:CreateTexture();
        texture:SetAllPoints();
        texture:SetTexture(PET_INFORMATION_PARTY_PET_INFORMATION_R,
                           PET_INFORMATION_PARTY_PET_INFORMATION_G,
                           PET_INFORMATION_PARTY_PET_INFORMATION_B,
                           PET_INFORMATION_PARTY_PET_INFORMATION_A);
        
        -- Create the pet party information ability buttons.
        pet_information_frame.pet_ability_buttons = {};
        for j = 1, PetParty.ABILITY_GROUPS_PER_PET do
            for k = 1, PetParty.ABILITIES_PER_ABILITY_GROUP do
                -- Create the button.
                local offset_x = (PADDING) +
                                 (BUTTON_WIDTH * PetParty.ABILITIES_PER_ABILITY_GROUP * (PetParty.ABILITY_GROUPS_PER_PET - j)) +
                                 (PADDING * 2 * (PetParty.ABILITY_GROUPS_PER_PET - j)) +
                                 (BUTTON_WIDTH * (PetParty.ABILITIES_PER_ABILITY_GROUP - k));
                local offset_y = PADDING + BUTTON_OFFSET_Y;
                
                local button = CreateFrame("Button", nil, pet_information_frame);
                button:ClearAllPoints();
                button:SetPoint("RIGHT", pet_information_frame, -offset_x, offset_y);
                button:SetWidth(BUTTON_WIDTH);
                button:SetHeight(BUTTON_HEIGHT);
                
                -- Add a handler for when the mouse clicks a pet party information ability button.
                button:SetScript("OnClick",
                    function(self)
                        -- Activate this ability.
                        self.ability_active = true;
                        
                        -- Deactivate its counterpart ability.
                        local index_max = PetParty.ABILITIES_PER_ABILITY_GROUP * PetParty.ABILITY_GROUPS_PER_PET;
                        local index_counterpart = ((self.ability_group - 1) + (self.ability_index * PetParty.ABILITY_GROUPS_PER_PET)) % index_max + 1;
                        self:GetParent().pet_ability_buttons[index_counterpart].ability_active = false;
                        
                        -- Update the display.
                        PetParty.UpdatePetInformationPetInformationFrame(self:GetParent().id);
                    end
                );
                
                -- Add a handler for when the mouse enters a pet party information ability button.
                button:SetScript("OnEnter",
                    function(self)
                        -- Get the pet's information.
                        local speciesID, customName, level, XP, maxXP, displayID, isFavorite,
                              speciesName, icon, petType, companionID,
                              tooltip, description, isWild, canBattle, isTradable,
                              isUnique, isObtainable = C_PetJournal.GetPetInfoByPetID(self:GetParent().pet_guid);
                        
                        -- Show the tooltip.
                        PetJournal_ShowAbilityTooltip(self, self.ability_id, speciesID, self:GetParent().pet_guid, nil);
                    end
                );
                
                -- Add a handler for when the mouse leaves a pet party information ability button.
                button:SetScript("OnLeave",
                    function(self)
                        -- Hide the tooltip.
                        PetJournalPrimaryAbilityTooltip:Hide();
                    end
                );
                
                button.ability_active = false;
                button.ability_id = nil;
                button.ability_group = j;
                button.ability_index = k;
                
                button.texture = button:CreateTexture();
                button.texture:SetAllPoints();
                button.texture:SetTexture(0, 0, 0, 0);
                
                -- Create the button icon.
                local button_icon = CreateFrame("Frame", nil, button);
                button_icon:ClearAllPoints();
                button_icon:SetPoint("BOTTOM", button, "TOP", 0, -BUTTON_OFFSET_Y);
                button_icon:SetWidth(BUTTON_ICON_WIDTH);
                button_icon:SetHeight(BUTTON_ICON_HEIGHT);
                
                button_icon.texture = button_icon:CreateTexture();
                button_icon.texture:SetAllPoints();
                button_icon.texture:SetTexture(0, 0, 0, 0);
                
                -- Store the button icon.
                button.icon = button_icon;
                
                -- Store the button.
                pet_information_frame.pet_ability_buttons[((j - 1) + ((k - 1) * PetParty.ABILITY_GROUPS_PER_PET)) + 1] = button;
            end
        end
        
        pet_information_frame.font_string_title = pet_information_frame:CreateFontString();
        pet_information_frame.font_string_title:SetFont(PET_INFORMATION_FONT, PET_INFORMATION_FONT_SIZE);
        pet_information_frame.font_string_title:SetTextColor(PET_INFORMATION_TITLE_R,
                                                             PET_INFORMATION_TITLE_G,
                                                             PET_INFORMATION_TITLE_B,
                                                             PET_INFORMATION_TITLE_A);
        pet_information_frame.font_string_title:SetJustifyH("LEFT");
        pet_information_frame.font_string_title:ClearAllPoints();
        pet_information_frame.font_string_title:SetPoint("TOPLEFT", pet_information_frame);
        pet_information_frame.font_string_title:SetPoint("BOTTOMRIGHT", pet_information_frame);
        
        PetParty_PetPartyInformationFrame.pet_frames[i] = pet_information_frame;
    end
    
    -- Localize the buttons.
    PetParty_PetPartyInformationFrame_Button_Activate:SetText(PetParty.L["Activate"]);
    PetParty_PetPartyInformationFrame_Button_Save:SetText(PetParty.L["Save"]);
    
    -- Update pet information frame layout.
    PetParty.UpdatePetInformationFrameLayout();
end

-- Call to get a pet's GUID from a pet information frame.
function PetParty.GetPetGUIDPetInformationFrame(slot_index)
    -- The result.
    local pet_guid = nil;
    
    -- Get the pet frame.
    local pet_information_frame = PetParty_PetPartyInformationFrame.pet_frames[slot_index];
    if (pet_information_frame ~= nil) then
        pet_guid = pet_information_frame.pet_guid;
    end
    
    -- Return the result.
    return pet_guid;
end

-- Call to get a pet's abilities' GUIDs from a pet information frame.
function PetParty.GetPetAbilityGUIDsPetInformationFrame(slot_index)
    -- The result.
    local ability_guids = {};
    
    -- Get the pet frame.
    local pet_information_frame = PetParty_PetPartyInformationFrame.pet_frames[slot_index];
    if (pet_information_frame ~= nil) then
        -- For each ability button...
        for i = 1, PetParty.ABILITY_GROUPS_PER_PET do
            for j = 1, PetParty.ABILITIES_PER_ABILITY_GROUP do
                -- Calculate the index.
                local index = ((i - 1) + ((j - 1) * PetParty.ABILITY_GROUPS_PER_PET)) + 1;
                
                -- Get the ability button.
                local ability_button = pet_information_frame.pet_ability_buttons[index];
                
                -- If the ability is active...
                if (ability_button.ability_active) then
                    -- Add the ability GUID to the result.
                    table.insert(ability_guids, ability_button.ability_id);
                end
            end
        end
    end
    
    -- Return the result.
    return ability_guids;
end

-- Call to set a pet in the pet information frame.
function PetParty.SetPetGUIDPetInformationFrame(slot_index, pet_guid)
    -- Sanity.
    if (slot_index > 0) and (slot_index < PetParty.PETS_PER_PARTY + 1) and (pet_guid ~= nil) then
        -- If the slot is not locked...
        local petGUID, ability1, ability2, ability3, locked = C_PetJournal.GetPetLoadOutInfo(slot_index);
        if (not locked) then
            -- Get the pet information frame.
            local pet_information_frame = PetParty_PetPartyInformationFrame.pet_frames[slot_index];
            
            -- Get the other pet information frames.
            local index_a = ((slot_index + 1) % PetParty.PETS_PER_PARTY) + 1;
            local petGUID_a, ability1_a, ability2_a, ability3_a, locked_a = C_PetJournal.GetPetLoadOutInfo(index_a);
            local pet_frame_a = PetParty_PetPartyInformationFrame.pet_frames[index_a];
            
            local index_b = ((index_a + 1) % PetParty.PETS_PER_PARTY) + 1;
            local petGUID_b, ability1_b, ability2_b, ability3_b, locked_b = C_PetJournal.GetPetLoadOutInfo(index_b);
            local pet_frame_b = PetParty_PetPartyInformationFrame.pet_frames[index_b];
            
            -- Sanity.
            if (pet_guid ~= nil) then
                -- This pet is already set in slot "a".
                if (not locked_a) and (pet_frame_a.pet_guid ~= nil) and (pet_guid == pet_frame_a.pet_guid) then
                    -- Swap the pet information frames.
                    pet_information_frame.pet_guid, pet_frame_a.pet_guid = pet_frame_a.pet_guid, pet_information_frame.pet_guid;
                    
                    -- Update pet frame "a"'s information.
                    PetParty.UpdatePetInformationPetInformationFrame(pet_frame_a.id);
                -- This pet is already set in slot "b".
                elseif (not locked_b) and (pet_frame_b.pet_guid ~= nil) and (pet_guid == pet_frame_b.pet_guid) then
                    -- Swap the pet information frames.
                    pet_information_frame.pet_guid, pet_frame_b.pet_guid = pet_frame_b.pet_guid, pet_information_frame.pet_guid;
                    
                    -- Update pet frame "b"'s information.
                    PetParty.UpdatePetInformationPetInformationFrame(pet_frame_b.id);
                -- The normal case.
                else
                    pet_information_frame.pet_guid = pet_guid;
                end
            end
            
            -- Update the pet frame's information.
            PetParty.UpdatePetInformationPetInformationFrame(pet_information_frame.id);
        end
    end
end

-- Call to set a pet's abilities in the pet information frame.
function PetParty.SetPetAbilityGUIDsPetInformationFrame(slot_index, ability_guids)
    -- Sanity.
    if (slot_index > 0) and (slot_index < PetParty.PETS_PER_PARTY + 1) then
        -- Get the pet information frame.
        local pet_information_frame = PetParty_PetPartyInformationFrame.pet_frames[slot_index];
        
        -- For each ability button...
        for i = 1, PetParty.ABILITY_GROUPS_PER_PET do
            for j = 1, PetParty.ABILITIES_PER_ABILITY_GROUP do
                -- Calculate the index.
                local index = ((i - 1) + ((j - 1) * PetParty.ABILITY_GROUPS_PER_PET)) + 1;
                
                -- Get the ability button.
                local ability_button = pet_information_frame.pet_ability_buttons[index];
                
                -- Deactivate the ability.
                ability_button.ability_active = false;
                
                -- For each ability GUID...
                for k = 1, PetParty.ABILITY_GROUPS_PER_PET do
                    -- Get the ability GUID.
                    local ability_guid = ability_guids[k];
                    
                    -- If the ability GUID equals the ability button's ability GUID.
                    if (ability_guid == ability_button.ability_id) then
                        -- Activate the ability button.
                        ability_button.ability_active = true;
                        break;
                    end
                end
            end
        end
        
        -- Update the pet frame's information.
        PetParty.UpdatePetInformationPetInformationFrame(slot_index);
    end
end

-- Call to update the pet information frame layout.
function PetParty.UpdatePetInformationFrameLayout()
    -- Calculate the width of all the pet information buttons.
    local button_width = PetParty_PetPartyInformationFrame_Button_Activate:GetWidth() +
                         PetParty_PetPartyInformationFrame_Button_Save:GetWidth();
    
    -- Calculate the offsets.
    local offset_x = (PetParty_PetPartyInformationFrame:GetWidth() - button_width ) / (PET_INFORMATION_PARTY_BUTTON_COUNT + 1);
    local offset_y = 0;
    
    -- Update the position of the activate pet information frame button.
    PetParty_PetPartyInformationFrame_Button_Activate:ClearAllPoints();
    PetParty_PetPartyInformationFrame_Button_Activate:SetPoint("TOPLEFT", offset_x, offset_y);
    
    -- Update the offsets.
    offset_x = offset_x + PetParty_PetPartyInformationFrame_Button_Activate:GetWidth() + offset_x;
    
    -- Update the position of the save pet information frame button.
    PetParty_PetPartyInformationFrame_Button_Save:ClearAllPoints();
    PetParty_PetPartyInformationFrame_Button_Save:SetPoint("TOPLEFT", offset_x, offset_y);
end

-- Call to update the pet information in a pet information frame.
function PetParty.UpdatePetInformationPetInformationFrame(slot_index)
    -- Sanity.
    if (slot_index > 0) and (slot_index < PetParty.PETS_PER_PARTY + 1) then
        -- If the slot is not locked...
        local petGUID, ability1, ability2, ability3, locked = C_PetJournal.GetPetLoadOutInfo(slot_index);
        if (not locked) then
            -- Get the pet information frame.
            local pet_information_frame = PetParty_PetPartyInformationFrame.pet_frames[slot_index];
            
            -- Get the pet's information.
            local speciesID, customName, level, XP, maxXP, displayID, isFavorite,
                  speciesName, icon, petType, companionID,
                  tooltip, description, isWild, canBattle, isTradable,
                  isUnique, isObtainable = C_PetJournal.GetPetInfoByPetID(pet_information_frame.pet_guid);
            
            -- If this pet has a custom name...
            if (customName ~= nil) and (customName ~= "") then
                pet_information_frame.font_string_title:SetText(customName .. " (" .. speciesName .. ")");
            else
                pet_information_frame.font_string_title:SetText(speciesName);
            end
            
            -- Get the pet's abilities.
            local idTable, levelTable = C_PetJournal.GetPetAbilityList(speciesID);
            
            -- For each of the pet's abilities...
            local ability_count = PetParty.ABILITY_GROUPS_PER_PET * PetParty.ABILITIES_PER_ABILITY_GROUP;
            for i = 1, ability_count do
                -- Get the ability information.
                local abilityName, abilityIcon, abilityType = C_PetJournal.GetPetAbilityInfo(idTable[i]);
                
                -- Update the pet ability button.
                pet_information_frame.pet_ability_buttons[i].ability_id = idTable[i];
                pet_information_frame.pet_ability_buttons[i].texture:SetTexture(abilityIcon);
                
                -- If this ability is activated...
                if (pet_information_frame.pet_ability_buttons[i].ability_active) then
                    -- Update the pet ability button icon.
                    pet_information_frame.pet_ability_buttons[i].icon.texture:SetTexture(BUTTON_ICON_R,
                                                                                         BUTTON_ICON_G,
                                                                                         BUTTON_ICON_B,
                                                                                         BUTTON_ICON_A);
                else
                    -- Update the pet ability button icon.
                    pet_information_frame.pet_ability_buttons[i].icon.texture:SetTexture(0, 0, 0, 0);
                end
            end
        end
    end
end
