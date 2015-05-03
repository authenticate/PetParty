--
-- Pet Party
-- Copyright 2014 - 2015 James Lammlein
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

local BUTTON_ICON_WIDTH = 16;
local BUTTON_ICON_HEIGHT = 16;

local BUTTON_OFFSET_Y = -6;

local BUTTON_ICON_OFFSET_X = -3;
local BUTTON_ICON_OFFSET_Y = 8;
local BUTTON_ICON_TEXTURE = "Interface\\PetBattles\\PetJournal";
local BUTTON_ICON_TEXTURE_COORDINATE_LEFT = 0.11328125;
local BUTTON_ICON_TEXTURE_COORDINATE_RIGHT = 0.16210938;
local BUTTON_ICON_TEXTURE_COORDINATE_TOP = 0.02246094;
local BUTTON_ICON_TEXTURE_COORDINATE_BOTTOM = 0.04687500;

local PET_INFORMATION_HEIGHT = (PetParty.PET_INFORMATION_FRAME_HEIGHT - PetParty.FONT_STRING_HEIGHT -
                                PetParty.FONT_STRING_PADDING - PetParty.PADDING - PetParty.BUTTON_HEIGHT) /
                               PetParty.PETS_PER_PARTY;

local PET_INFORMATION_BUTTON_COUNT = 2;

local PET_INFORMATION_R = 0;
local PET_INFORMATION_G = 0;
local PET_INFORMATION_B = 0;
local PET_INFORMATION_A = 0;

-- Call to create a pet information frame.
function PetParty.CreatePetInformationFrame(parent, name)
    -- Create a pet party information frame.
    local pet_information_frame = CreateFrame("Frame", name, parent);
    pet_information_frame:EnableMouse(true);
    pet_information_frame:RegisterForDrag("LeftButton");
    
    -- Add a handler for when the mouse is released on the pet information frame.
    pet_information_frame:SetScript("OnMouseUp",
        function(self, button)
            local cursorType, petID = GetCursorInfo();
            if (cursorType == "battlepet") then
                -- If this is the training pet...
                if (PetParty.training_pet_cursor) then
                    -- Store the pet GUID.
                    PetParty.SetPetGUIDPetInformationFrame(self.id, petID);
                    
                    -- Update the training pet frame.
                    self:GetParent().training_pet_frame = self;
                    
                    -- Store the pet's abilities' GUIDs.
                    local ability_guids = PetParty.GetPetAbilityGUIDsTrainingPetFrame();
                    PetParty.SetPetAbilityGUIDsPetInformationFrame(self.id, ability_guids);
                -- If this is an information pet...
                elseif (PetParty.pet_information_frame_cursor ~= nil) then
                    -- Store the pet's abilities' GUIDs.
                    local ability_guids = PetParty.GetPetAbilityGUIDsPetInformationFrame(PetParty.pet_information_frame_cursor.id);
                    
                    -- Store the pet GUID.
                    PetParty.SetPetGUIDPetInformationFrame(self.id, petID);
                    
                    -- Update the pet's abilities' GUIDs.
                    PetParty.SetPetAbilityGUIDsPetInformationFrame(self.id, ability_guids);
                -- If this is a pet from Blizzard's UI...
                else
                    -- If this is the training pet frame...
                    if (PetParty_PetPartyInformationFrame.training_pet_frame == self) then
                        -- Clear the training pet frame.
                        PetParty_PetPartyInformationFrame.training_pet_frame = nil;
                    end
                    
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
                    PetParty.SetPetAbilityGUIDsPetInformationFrame(self.id, ability_guids);
                end
                
                -- Update all pet frames' information.
                for i = 1, PetParty.PETS_PER_PARTY do
                    PetParty.UpdatePetInformationPetInformationFrame(i);
                end
                
                -- Reset the cursor.
                ClearCursor();
                
                -- Update the flags.
                PetParty.pet_information_frame_cursor = nil;
                PetParty.training_pet_cursor = false;
            end
        end
    );
    
    pet_information_frame.id = 0;
    pet_information_frame.pet_guid = nil;
    
    texture = pet_information_frame:CreateTexture();
    texture:SetAllPoints();
    texture:SetTexture(PET_INFORMATION_R,
                       PET_INFORMATION_G,
                       PET_INFORMATION_B,
                       PET_INFORMATION_A);
    
    -- Create the pet party pet button.
    local pet_button = CreateFrame("Button", name .. "_PetButton", pet_information_frame, "PetParty_PetInformationButtonTemplate");
    pet_button:ClearAllPoints();
    pet_button:SetPoint("LEFT", pet_information_frame);
    
    -- Store the pet party pet button.
    pet_information_frame.pet_button = pet_button;
    
    -- Create the pet party information ability buttons.
    pet_information_frame.pet_ability_buttons_active = {};
    pet_information_frame.pet_ability_buttons = {};
    for j = 1, PetParty.ABILITY_GROUPS_PER_PET do
        for k = 1, PetParty.ABILITIES_PER_ABILITY_GROUP do
            -- Create the button.
            local offset_x = (PetParty.PADDING) +
                             (PetParty.BUTTON_WIDTH * PetParty.ABILITIES_PER_ABILITY_GROUP * (PetParty.ABILITY_GROUPS_PER_PET - j)) +
                             (PetParty.PADDING * 2 * (PetParty.ABILITY_GROUPS_PER_PET - j)) +
                             (PetParty.BUTTON_WIDTH * (PetParty.ABILITIES_PER_ABILITY_GROUP - k));
            local offset_y = BUTTON_OFFSET_Y;
            
            local button = CreateFrame("Button", nil, pet_information_frame);
            button:ClearAllPoints();
            button:SetPoint("RIGHT", pet_information_frame, -offset_x, offset_y);
            button:SetWidth(PetParty.BUTTON_WIDTH);
            button:SetHeight(PetParty.BUTTON_HEIGHT);
            
            -- Add a handler for when the mouse clicks a pet party information ability button.
            button:SetScript("OnClick",
                function(self)
                    -- Activate this ability.
                    self:GetParent().pet_ability_buttons_active[self.ability_group] = self;
                    
                    -- If this is the training pet...
                    if (self:GetParent() == PetParty_PetPartyInformationFrame.training_pet_frame) then
                        -- Clear the training pet frame.
                        PetParty_PetPartyInformationFrame.training_pet_frame = nil;
                    end
                    
                    -- Update the display.
                    PetParty.UpdatePetInformationPetInformationFrame(self:GetParent().id);
                end
            );
            
            -- Add a handler for when the mouse enters a pet party information ability button.
            button:SetScript("OnEnter",
                function(self)
                    -- Sanity.
                    if (self:GetParent().pet_guid ~= nil) then
                        -- Get the pet's information.
                        local speciesID, customName, level, XP, maxXP, displayID, isFavorite,
                            speciesName, icon, petType, companionID,
                            tooltip, description, isWild, canBattle, isTradable,
                            isUnique, isObtainable = C_PetJournal.GetPetInfoByPetID(self:GetParent().pet_guid);
                        
                        -- Show the tooltip.
                        PetJournal_ShowAbilityTooltip(self, self.ability_guid, speciesID, self:GetParent().pet_guid, nil);
                    end
                end
            );
            
            -- Add a handler for when the mouse leaves a pet party information ability button.
            button:SetScript("OnLeave",
                function(self)
                    -- Hide the tooltip.
                    PetJournalPrimaryAbilityTooltip:Hide();
                end
            );
            
            button.ability_guid = nil;
            button.ability_group = j;
            button.ability_index = k;
            
            button.texture = button:CreateTexture();
            button.texture:SetAllPoints();
            button.texture:SetTexture(0, 0, 0, 0);
            
            -- Create the button icon.
            local button_icon = CreateFrame("Frame", nil, button);
            button_icon:Hide();
            button_icon:ClearAllPoints();
            button_icon:SetPoint("RIGHT", pet_information_frame, (-offset_x) + BUTTON_ICON_OFFSET_X, (-offset_y) + BUTTON_ICON_OFFSET_Y);
            button_icon:SetWidth(BUTTON_ICON_WIDTH);
            button_icon:SetHeight(BUTTON_ICON_HEIGHT);
            
            button_icon.texture = button_icon:CreateTexture();
            button_icon.texture:SetAllPoints();
            button_icon.texture:SetTexture(BUTTON_ICON_TEXTURE);
            button_icon.texture:SetTexCoord(BUTTON_ICON_TEXTURE_COORDINATE_LEFT,
                                            BUTTON_ICON_TEXTURE_COORDINATE_RIGHT,
                                            BUTTON_ICON_TEXTURE_COORDINATE_TOP,
                                            BUTTON_ICON_TEXTURE_COORDINATE_BOTTOM);
            
            -- Store the button icon.
            button.icon = button_icon;
            
            -- Store the button.
            pet_information_frame.pet_ability_buttons[((j - 1) + ((k - 1) * PetParty.ABILITY_GROUPS_PER_PET)) + 1] = button;
        end
    end
    
    pet_information_frame.font_string_name = pet_information_frame:CreateFontString();
    pet_information_frame.font_string_name:SetFontObject("GameFontNormal");
    pet_information_frame.font_string_name:SetJustifyH("LEFT");
    pet_information_frame.font_string_name:ClearAllPoints();
    pet_information_frame.font_string_name:SetPoint("TOP", pet_information_frame);
    pet_information_frame.font_string_name:SetPoint("LEFT", pet_information_frame.pet_button, "RIGHT", PetParty.PADDING, 0);
    pet_information_frame.font_string_name:SetPoint("BOTTOMRIGHT", pet_information_frame);
    
    pet_information_frame.font_string_subname = pet_information_frame:CreateFontString();
    pet_information_frame.font_string_subname:SetFontObject("GameFontWhite");
    pet_information_frame.font_string_subname:SetJustifyH("LEFT");
    pet_information_frame.font_string_subname:ClearAllPoints();
    pet_information_frame.font_string_subname:SetPoint("TOP", pet_information_frame);
    pet_information_frame.font_string_subname:SetPoint("LEFT", pet_information_frame.pet_button, "RIGHT", PetParty.PADDING, 0);
    pet_information_frame.font_string_subname:SetPoint("BOTTOMRIGHT", pet_information_frame);
    
    pet_information_frame.font_string_training_pet = pet_information_frame:CreateFontString();
    pet_information_frame.font_string_training_pet:SetFontObject("GameFontWhite");
    pet_information_frame.font_string_training_pet:SetJustifyH("LEFT");
    pet_information_frame.font_string_training_pet:ClearAllPoints();
    pet_information_frame.font_string_training_pet:SetPoint("TOP", pet_information_frame);
    pet_information_frame.font_string_training_pet:SetPoint("LEFT", pet_information_frame.pet_button, "RIGHT", PetParty.PADDING, 0);
    pet_information_frame.font_string_training_pet:SetPoint("BOTTOMRIGHT", pet_information_frame);
    pet_information_frame.font_string_training_pet:SetText("(" .. PetParty.L[PetParty.STRING_TRAINING_PET] .. ")");
    pet_information_frame.font_string_training_pet:Hide();
    
    -- Return the pet information frame.
    return pet_information_frame;
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
        for i = 1, #pet_information_frame.pet_ability_buttons_active do
            -- Get the pet ability button.
            local ability_button = pet_information_frame.pet_ability_buttons_active[i];
            
            -- Add the ability GUID to the array.
            table.insert(ability_guids, ability_button.ability_guid);
        end
    end
    
    -- Return the result.
    return ability_guids;
end

-- Called when the pet party information frame's activate button is clicked.
function PetParty.OnClickPetPartyInformationFrameButtonActivate()
    -- For each pet...
    for i = 1, PetParty.PETS_PER_PARTY do
        -- Get the pet information frame.
        local pet_information_frame = PetParty_PetPartyInformationFrame.pet_frames[i];
        
        if (pet_information_frame.pet_guid ~= nil) then
            -- Activate the pets from the UI.
            C_PetJournal.SetPetLoadOutInfo(i, pet_information_frame.pet_guid);
            
            -- Get the ability GUIDs.
            local ability_guids = PetParty.GetPetAbilityGUIDsPetInformationFrame(i);
            
            -- Activate the pets' abilities from the UI.
            for j = 1, PetParty.ABILITY_GROUPS_PER_PET do
                if (ability_guids[j] ~= nil) then
                    C_PetJournal.SetAbility(i, j, ability_guids[j]);
                end
            end
        end
    end
    
    -- Update Blizzard's pet journal.
    PetJournal_UpdatePetLoadOut();
end

-- Called when the pet party information frame's save button is clicked.
function PetParty.OnClickPetPartyInformationFrameButtonSave()
    -- Store the pets from the UI into the selected pet party frame.
    if (PetParty.pet_party_frame_selected ~= nil) then
        -- If there's a training pet...
        if (PetParty_PetPartyInformationFrame.training_pet_frame ~= nil) then
            -- Store the training pet's GUID.
            PetParty.pet_party_frame_selected.pet_training_frame_id = PetParty_PetPartyInformationFrame.training_pet_frame.id;
        else
            -- Reset the training pet's GUID.
            PetParty.pet_party_frame_selected.pet_training_frame_id = nil;
        end
        
        -- For each pet...
        for i = 1, PetParty.PETS_PER_PARTY do
            -- Get the pet information frame.
            local pet_information_frame = PetParty_PetPartyInformationFrame.pet_frames[i];
            
            -- Get the ability GUIDs.
            local ability_guids = PetParty.GetPetAbilityGUIDsPetInformationFrame(i);
            
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
            -- If the frame does not have a pet...
            if (PetParty_PetPartyInformationFrame.pet_frames[i].pet_guid == nil) then
                -- Load the pet in the corresponding pet load out into the frame.
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
    -- Register the per party information frame for events.
    PetParty_PetPartyInformationFrame:RegisterEvent("PET_JOURNAL_LIST_UPDATE");
    
    -- Set the per party information frame's scripts.
    PetParty_PetPartyInformationFrame:SetScript("OnEvent", PetParty.OnEventPetPartyInformationFrame);
    
    -- Configure the pet party information frame's background texture.
    local texture = PetParty_PetPartyInformationFrame:CreateTexture();
    texture:SetAllPoints();
    texture:SetTexture(PET_INFORMATION_R,
                       PET_INFORMATION_G,
                       PET_INFORMATION_B,
                       PET_INFORMATION_A);
    
    -- Initialize the pet party information frame's training pet frame variable.
    PetParty_PetPartyInformationFrame.training_pet_frame = nil;
    
    -- Initialize the pet party information frame's pet frames variable.
    PetParty_PetPartyInformationFrame.pet_frames = {};
    
    --
    -- Configure the pet party information frame's pet frames.
    --
    
    local parents = { PetParty_PetPartyInformationFrame };
    local anchors = { "TOPLEFT", "BOTTOMLEFT", "BOTTOMLEFT" };
    local offset_y_s = { -PetParty.FONT_STRING_HEIGHT - PetParty.PADDING - PetParty.BUTTON_HEIGHT - PetParty.PADDING, 0, 0 };
    
    -- For each pet...
    for i = 1, PetParty.PETS_PER_PARTY do
        -- Create a pet information frame.
        local pet_information_frame = PetParty.CreatePetInformationFrame(PetParty_PetPartyInformationFrame, "PetParty_PetInformationFrame_" .. tostring(i));
        
        -- Configure the pet information frame.
        pet_information_frame:ClearAllPoints();
        pet_information_frame:SetPoint("TOPLEFT", parents[i], anchors[i], 0, offset_y_s[i]);
        pet_information_frame:SetPoint("RIGHT", PetParty_PetPartyInformationFrame);
        pet_information_frame:SetHeight(PET_INFORMATION_HEIGHT);
        
        pet_information_frame.id = i;
        
        -- Update the parent array.
        parents[i + 1] = pet_information_frame;
        
        -- Store the pet information frame.
        PetParty_PetPartyInformationFrame.pet_frames[i] = pet_information_frame;
    end
    
    -- Localize the UI.
    PetParty_PetPartyInformationFrame_Font_String_Configuration:SetText(PetParty.L[PetParty.STRING_BATTLE_PETS_SLOTS_CONFIGURATION]);
    PetParty_PetPartyInformationFrame_Button_Activate:SetText(PetParty.L[PetParty.STRING_BUTTON_ACTIVATE]);
    PetParty_PetPartyInformationFrame_Button_Save:SetText(PetParty.L[PetParty.STRING_BUTTON_SAVE]);
    
    -- Update pet information frame layout.
    PetParty.UpdatePetInformationFrameLayout();
end

-- Called when the training pet changes.
function PetParty.OnTrainingPetChangedPetPartyInformationFrame()
    -- If there is a training pet in the active pet party...
    if (PetParty_PetPartyInformationFrame.training_pet_frame ~= nil) then
        -- Get the training pet's information.
        local pet_guid = PetParty.GetPetGUIDTrainingPetFrame();
        local ability_guids = PetParty.GetPetAbilityGUIDsTrainingPetFrame();
        
        -- Sanity.
        if (pet_guid ~= nil) and (pet_guid ~= "") then
            -- Cache the training pet frame.
            local training_pet_frame = PetParty_PetPartyInformationFrame.training_pet_frame;
            
            -- Clear the training pet frame.
            PetParty_PetPartyInformationFrame.training_pet_frame = nil;
            
            -- Update the training pet frame's pet GUID.
            PetParty.SetPetGUIDPetInformationFrame(training_pet_frame.id, pet_guid);
            PetParty.UpdatePetInformationPetInformationFrame(training_pet_frame.id);
            
            -- Update the training pet frame's pet's abilities GUIDs.
            PetParty.SetPetAbilityGUIDsPetInformationFrame(training_pet_frame.id, ability_guids);
            
            -- Reset the training pet frame.
            PetParty_PetPartyInformationFrame.training_pet_frame = training_pet_frame;
            
            -- Update the UI.
            for i = 1, PetParty.PETS_PER_PARTY do
                PetParty.UpdatePetInformationPetInformationFrame(i);
            end
        end
    end
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
            local ability_guids = PetParty.GetPetAbilityGUIDsPetInformationFrame(slot_index);
            
            -- Get the other pet information frames.
            local index_a = ((slot_index + 1) % PetParty.PETS_PER_PARTY) + 1;
            local petGUID_a, ability1_a, ability2_a, ability3_a, locked_a = C_PetJournal.GetPetLoadOutInfo(index_a);
            local pet_frame_a = PetParty_PetPartyInformationFrame.pet_frames[index_a];
            
            local index_b = ((index_a + 1) % PetParty.PETS_PER_PARTY) + 1;
            local petGUID_b, ability1_b, ability2_b, ability3_b, locked_b = C_PetJournal.GetPetLoadOutInfo(index_b);
            local pet_frame_b = PetParty_PetPartyInformationFrame.pet_frames[index_b];
            
            -- Create a helper function.
            local SetPetAbilityGUIDsPetInformationFrameButtons =
                function (frame)
                    local result = false;
                    
                    -- Sanity.
                    if (frame.pet_guid ~= nil) and (frame.pet_guid ~= "") then
                        -- Get the pet's information.
                        local speciesID, customName, level, XP, maxXP, displayID, isFavorite,
                            speciesName, icon, petType, companionID,
                            tooltip, description, isWild, canBattle, isTradable,
                            isUnique, isObtainable = C_PetJournal.GetPetInfoByPetID(frame.pet_guid);
                        
                        if (speciesID ~= nil) then
                            result = true;
                            
                            -- Get the pet's abilities.
                            local idTable, levelTable = C_PetJournal.GetPetAbilityList(speciesID);
                            
                            -- For each of the pet's abilities...
                            for i = 1, #frame.pet_ability_buttons do
                                -- Get the ability information.
                                local abilityName, abilityIcon, abilityType = C_PetJournal.GetPetAbilityInfo(idTable[i]);
                                
                                -- Update the pet ability button.
                                frame.pet_ability_buttons[i].ability_guid = idTable[i];
                                frame.pet_ability_buttons[i].texture:SetTexture(abilityIcon);
                                frame.pet_ability_buttons[i].icon:Hide();
                            end
                        end
                    end
                    
                    if (not result) then
                        -- For each of the pet's abilities...
                        for i = 1, #frame.pet_ability_buttons do
                            -- Update the pet ability button.
                            frame.pet_ability_buttons[i].ability_guid = nil;
                            frame.pet_ability_buttons[i].texture:SetTexture(nil);
                            frame.pet_ability_buttons[i].icon:Hide();
                        end
                    end
                end
            ;
            
            -- Sanity.
            if (pet_guid ~= nil) then
                -- This pet is already set in slot "a".
                if (not locked_a) and (pet_frame_a.pet_guid ~= nil) and (pet_guid == pet_frame_a.pet_guid) then
                    -- If a slot "a" is the training pet...
                    if (PetParty_PetPartyInformationFrame.training_pet_frame == pet_frame_a) then
                        -- Swap the training pet.
                        PetParty_PetPartyInformationFrame.training_pet_frame = pet_information_frame;
                    -- If the slot index is the training pet...
                    elseif (PetParty_PetPartyInformationFrame.training_pet_frame == pet_information_frame) then
                        -- Swap the training pet.
                        PetParty_PetPartyInformationFrame.training_pet_frame = pet_frame_a;
                    end
                    
                    -- Swap the pet information frames.
                    pet_information_frame.pet_guid, pet_frame_a.pet_guid = pet_frame_a.pet_guid, pet_information_frame.pet_guid;
                    
                    -- Update the ability buttons.
                    SetPetAbilityGUIDsPetInformationFrameButtons(pet_frame_a);
                    
                    -- Update the ability GUIDs.
                    PetParty.SetPetAbilityGUIDsPetInformationFrame(index_a, ability_guids);
                -- This pet is already set in slot "b".
                elseif (not locked_b) and (pet_frame_b.pet_guid ~= nil) and (pet_guid == pet_frame_b.pet_guid) then
                    -- If slot "b" is the training pet...
                    if (PetParty_PetPartyInformationFrame.training_pet_frame == pet_frame_b) then
                        -- Swap the training pet.
                        PetParty_PetPartyInformationFrame.training_pet_frame = pet_information_frame;
                    -- If the slot index is the training pet...
                    elseif (PetParty_PetPartyInformationFrame.training_pet_frame == pet_information_frame) then
                        -- Swap the training pet.
                        PetParty_PetPartyInformationFrame.training_pet_frame = pet_frame_b;
                    end
                    
                    -- Swap the pet information frames.
                    pet_information_frame.pet_guid, pet_frame_b.pet_guid = pet_frame_b.pet_guid, pet_information_frame.pet_guid;
                    
                    -- Update the ability buttons.
                    SetPetAbilityGUIDsPetInformationFrameButtons(pet_frame_b);
                    
                    -- Update the ability GUIDs.
                    PetParty.SetPetAbilityGUIDsPetInformationFrame(index_b, ability_guids);
                -- The normal case.
                else
                    pet_information_frame.pet_guid = pet_guid;
                end
            end
            
            -- Update the ability buttons.
            SetPetAbilityGUIDsPetInformationFrameButtons(pet_information_frame);
        end
    end
end

-- Call to set a pet's abilities in the pet information frame.
function PetParty.SetPetAbilityGUIDsPetInformationFrame(slot_index, ability_guids)
    -- Sanity.
    if (slot_index > 0) and (slot_index < PetParty.PETS_PER_PARTY + 1) then
        -- Get the pet information frame.
        local pet_information_frame = PetParty_PetPartyInformationFrame.pet_frames[slot_index];
        
        -- Reset the ability GUIDs.
        pet_information_frame.pet_ability_buttons_active = {};
        
        -- Sanity.
        if (ability_guids ~= nil) then
            -- For each ability GUID...
            for i = 1, #ability_guids do
                -- For each ability button...
                for j = 1, #pet_information_frame.pet_ability_buttons do
                    -- Get the ability GUID.
                    local ability_guid = ability_guids[i];
                    
                    -- Get the ability button.
                    local ability_button = pet_information_frame.pet_ability_buttons[j];
                    if (ability_button.ability_guid == ability_guid) then
                        table.insert(pet_information_frame.pet_ability_buttons_active, ability_button);
                    end
                end
            end
        end
    end
end

-- Call to update the pet information frame layout.
function PetParty.UpdatePetInformationFrameLayout()
    -- Configure the pet party information frame.
    PetParty_PetPartyInformationFrame:ClearAllPoints();
    PetParty_PetPartyInformationFrame:SetPoint("LEFT", PetParty_MainFrame, PetParty.MAIN_FRAME_OFFSET_LEFT, 0);
    PetParty_PetPartyInformationFrame:SetPoint("RIGHT", PetParty_MainFrame, PetParty.MAIN_FRAME_OFFSET_RIGHT, 0);
    PetParty_PetPartyInformationFrame:SetPoint("TOP", PetParty_TrainingPetInformationFrame, "BOTTOM", 0, -PetParty.PET_INFORMATION_FRAME_PADDING);
    PetParty_PetPartyInformationFrame:SetPoint("BOTTOM", PetParty_MainFrame, "BOTTOM", 0, PetParty.MAIN_FRAME_OFFSET_BOTTOM);
    
    -- Calculate the width of all the pet information buttons.
    local button_width = PetParty_PetPartyInformationFrame_Button_Activate:GetWidth() +
                         PetParty_PetPartyInformationFrame_Button_Save:GetWidth();
    
    -- Update the position of the pet information frame configuration label.
    PetParty_PetPartyInformationFrame_Font_String_Configuration:ClearAllPoints();
    PetParty_PetPartyInformationFrame_Font_String_Configuration:SetPoint("TOPLEFT", 0, 0);
    PetParty_PetPartyInformationFrame_Font_String_Configuration:SetPoint("RIGHT", 0, 0);
    PetParty_PetPartyInformationFrame_Font_String_Configuration:SetHeight(PetParty.FONT_STRING_HEIGHT);
    
    -- Calculate the offsets.
    local offset_x = (PetParty_PetPartyInformationFrame:GetWidth() - button_width ) / (PET_INFORMATION_BUTTON_COUNT + 1);
    local offset_y = -PetParty.FONT_STRING_HEIGHT - PetParty.PADDING;
    
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
        -- Get the pet slot information.
        local petGUID, ability1, ability2, ability3, locked = C_PetJournal.GetPetLoadOutInfo(slot_index);
        
        -- Get the pet information frame.
        local pet_information_frame = PetParty_PetPartyInformationFrame.pet_frames[slot_index];
        
        local result = false;
        
        -- Sanity.
        if (not locked) and (pet_information_frame.pet_guid ~= nil) then
            -- Get the pet's information.
            local speciesID, customName, level, XP, maxXP, displayID, isFavorite,
                speciesName, icon, petType, companionID,
                tooltip, description, isWild, canBattle, isTradable,
                isUnique, isObtainable = C_PetJournal.GetPetInfoByPetID(pet_information_frame.pet_guid);
            
            if (speciesID ~= nil) then
                result = true;
                
                -- Get the pet's statistics.
                local health, maxHealth, attack, speed, rarity = C_PetJournal.GetPetStats(pet_information_frame.pet_guid);
                
                -- If this pet has a custom name and is the training pet...
                if (customName ~= nil) and (customName ~= "") and
                   (PetParty_PetPartyInformationFrame.training_pet_frame == pet_information_frame) then
                    -- Update the name.
                    pet_information_frame.font_string_name:SetPoint("TOP", pet_information_frame, "TOP", 0, PetParty.PET_INFORMATION_FONT_STRING_OFFSET_Y * 2);
                    pet_information_frame.font_string_name:SetText(speciesName);
                    
                    -- Update the subname.
                    pet_information_frame.font_string_subname:SetPoint("TOP", pet_information_frame, "TOP", 0);
                    pet_information_frame.font_string_subname:SetText(customName);
                    
                    -- Update the training pet.
                    pet_information_frame.font_string_training_pet:SetPoint("TOP", pet_information_frame, "TOP", 0, -PetParty.PET_INFORMATION_FONT_STRING_OFFSET_Y * 2);
                    pet_information_frame.font_string_training_pet:SetText("(" .. PetParty.L[PetParty.STRING_TRAINING_PET] .. ")");
                    pet_information_frame.font_string_training_pet:Show();
                -- If this pet has a custom name...
                elseif (customName ~= nil) and (customName ~= "") then
                    -- Update the name.
                    pet_information_frame.font_string_name:SetPoint("TOP", pet_information_frame, "TOP", 0, PetParty.PET_INFORMATION_FONT_STRING_OFFSET_Y);
                    pet_information_frame.font_string_name:SetText(speciesName);
                    
                    -- Update the subname.
                    pet_information_frame.font_string_subname:SetPoint("TOP", pet_information_frame, "TOP", 0, -PetParty.PET_INFORMATION_FONT_STRING_OFFSET_Y);
                    pet_information_frame.font_string_subname:SetText(customName);
                    
                    -- Update the training pet.
                    pet_information_frame.font_string_training_pet:SetPoint("TOP", pet_information_frame);
                    pet_information_frame.font_string_training_pet:SetText("(" .. PetParty.L[PetParty.STRING_TRAINING_PET] .. ")");
                    pet_information_frame.font_string_training_pet:Hide();
                -- If this pet is the training pet...
                elseif (PetParty_PetPartyInformationFrame.training_pet_frame == pet_information_frame) then
                    -- Update the name.
                    pet_information_frame.font_string_name:SetPoint("TOP", pet_information_frame, "TOP", 0, PetParty.PET_INFORMATION_FONT_STRING_OFFSET_Y);
                    pet_information_frame.font_string_name:SetText(speciesName);
                    
                    -- Update the subname.
                    pet_information_frame.font_string_subname:SetPoint("TOP", pet_information_frame, "TOP");
                    pet_information_frame.font_string_subname:SetText("");
                    
                    -- Update the training pet.
                    pet_information_frame.font_string_training_pet:SetPoint("TOP", pet_information_frame, "TOP", 0, -PetParty.PET_INFORMATION_FONT_STRING_OFFSET_Y);
                    pet_information_frame.font_string_training_pet:SetText("(" .. PetParty.L[PetParty.STRING_TRAINING_PET] .. ")");
                    pet_information_frame.font_string_training_pet:Show();
                -- The normal case...
                else
                    -- Update the name.
                    pet_information_frame.font_string_name:SetPoint("TOP", pet_information_frame);
                    pet_information_frame.font_string_name:SetText(speciesName);
                    
                    -- Update the subname.
                    pet_information_frame.font_string_subname:SetPoint("TOP", pet_information_frame);
                    pet_information_frame.font_string_subname:SetText("");
                    
                    -- Update the training pet.
                    pet_information_frame.font_string_training_pet:SetPoint("TOP", pet_information_frame);
                    pet_information_frame.font_string_training_pet:SetText("(" .. PetParty.L[PetParty.STRING_TRAINING_PET] .. ")");
                    pet_information_frame.font_string_training_pet:Hide();
                end
                
                -- Update the pet button's icon.
                pet_information_frame.pet_button:Show();
                pet_information_frame.pet_button.background:Show();
                pet_information_frame.pet_button.icon:SetTexture(icon);
                pet_information_frame.pet_button.icon_border:Show();
                pet_information_frame.pet_button.icon_border:SetVertexColor(ITEM_QUALITY_COLORS[rarity - 1].r,
                                                                            ITEM_QUALITY_COLORS[rarity - 1].g,
                                                                            ITEM_QUALITY_COLORS[rarity - 1].b);
                
                -- If the pet is alive...
                if (health > 0) then
                    pet_information_frame.pet_button.is_dead:Hide();
                -- If the pet is dead...
                else
                    pet_information_frame.pet_button.is_dead:Show();
                end
                
                pet_information_frame.pet_button.level:SetShown(canBattle);
                pet_information_frame.pet_button.level:SetText(level);
                pet_information_frame.pet_button.level_background:Show();
                
                -- For each pet ability button...
                for i = 1, #pet_information_frame.pet_ability_buttons do
                    -- Update the pet ability button icon.
                    pet_information_frame.pet_ability_buttons[i].icon:Hide();
                end
                
                -- For each active pet ability button...
                for i = 1, #pet_information_frame.pet_ability_buttons_active do
                    -- Update the pet ability button icon.
                    pet_information_frame.pet_ability_buttons_active[i].icon:Show();
                end
            end
        end
        
        if (not result) then
            -- Update the strings.
            pet_information_frame.font_string_name:SetPoint("TOP", pet_information_frame, "TOP");
            pet_information_frame.font_string_name:SetText("");
            pet_information_frame.font_string_subname:SetPoint("TOP", pet_information_frame, "TOP");
            pet_information_frame.font_string_subname:SetText("");
            
            pet_information_frame.font_string_training_pet:SetPoint("TOP", pet_information_frame, "TOP");
            
            if (PetParty_PetPartyInformationFrame.training_pet_frame == pet_information_frame) then
                pet_information_frame.font_string_training_pet:SetText("(" .. PetParty.L[PetParty.STRING_TRAINING_PET] .. ")");
            else
                pet_information_frame.font_string_training_pet:SetText(PetParty.L[PetParty.STRING_DRAG]);
            end
            
            pet_information_frame.font_string_training_pet:Show();
            
            -- Update the pet button.
            pet_information_frame.pet_button:Hide();
            pet_information_frame.pet_button.background:Hide();
            pet_information_frame.pet_button.icon:SetTexture(nil);
            pet_information_frame.pet_button.icon_border:Hide();
            pet_information_frame.pet_button.is_dead:Hide();
            pet_information_frame.pet_button.level:Hide();
            pet_information_frame.pet_button.level_background:Hide();
            
            -- For each potential pet ability...
            for i = 1, #pet_information_frame.pet_ability_buttons do
                -- Update the pet ability button.
                pet_information_frame.pet_ability_buttons[i].texture:SetTexture(nil);
                
                -- Update the pet ability button icon.
                pet_information_frame.pet_ability_buttons[i].icon:Hide();
            end
        end
    end
end
