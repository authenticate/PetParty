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

local BUTTON_ICON_R = 0;
local BUTTON_ICON_G = 1;
local BUTTON_ICON_B = 0;
local BUTTON_ICON_A = 1;

local TRAINING_PET_R = 0;
local TRAINING_PET_G = 0;
local TRAINING_PET_B = 0;
local TRAINING_PET_A = 0;

-- A flag if the training pet has been deserialized.
local is_deserialized = false;

-- A flag if the training pet is the cursor.
PetParty.training_pet_cursor = false;

-- Call to deserialize the training pet.
function PetParty.DeserializeTrainingPet()
    if (PetPartyDB ~= nil) and
       (PetPartyDB.training_pet ~= nil) then
        -- Cache the values.
        local training_pet = PetPartyDB.training_pet;
        
        -- Store the training pet's GUID.
        PetParty.SetPetGUIDTrainingPetFrame(training_pet.guid);
        
        -- Store the training pet's ability GUIDs.
        PetParty.SetPetAbilityGUIDsTrainingPetFrame(training_pet.ability_guids)
        
        -- Update the pet frame's information.
        PetParty.UpdateTrainingPetInformationFrame();
    end
end

-- Call to get a pet's GUID from a training pet frame.
function PetParty.GetPetGUIDTrainingPetFrame()
    -- The result.
    local pet_guid = nil;
    
    -- Get the pet information frame.
    local pet_information_frame = PetParty_TrainingPetInformationFrame.pet_frame;
    
    -- Return the result.
    return pet_information_frame.pet_guid;
end

-- Call to get a pet's abilities' GUIDs from the training pet information frame.
function PetParty.GetPetAbilityGUIDsTrainingPetFrame()
    -- The result.
    local ability_guids = {};
    
    -- Get the pet information frame.
    local pet_information_frame = PetParty_TrainingPetInformationFrame.pet_frame;
    if (pet_information_frame ~= nil) then
        for i = 1, #pet_information_frame.pet_ability_buttons_active do
            -- Get the pet ability button.
            local ability_button = pet_information_frame.pet_ability_buttons_active[i];
            
            -- Add the ability GUID to the array.
            table.insert(ability_guids, ability_button.ability_id);
        end
    end
    
    -- Return the result.
    return ability_guids;
end

-- Called when the training pet information frame receives an event.
function PetParty.OnEventTrainingPetInformationFrame(self, event, arg1, ...)
    if (event == "PLAYER_LOGOUT") then
        PetParty.SerializeTrainingPet()
    end
end

-- Called when the training pet information frame is loaded.
function PetParty.OnLoadTrainingPetInformationFrame()
    -- Register the training pet information frame for events.
    PetParty_TrainingPetInformationFrame:RegisterEvent("PLAYER_LOGOUT");
    
    -- Set the training pet information frame's scripts.
    PetParty_TrainingPetInformationFrame:SetScript("OnEvent", PetParty.OnEventTrainingPetInformationFrame);
    
    -- Configure the training pet information frame.
    PetParty_TrainingPetInformationFrame:ClearAllPoints();
    PetParty_TrainingPetInformationFrame:SetPoint("LEFT", PetParty_MainFrame, PetParty.MAIN_FRAME_OFFSET_LEFT, 0);
    PetParty_TrainingPetInformationFrame:SetPoint("RIGHT", PetParty_MainFrame, PetParty.MAIN_FRAME_OFFSET_RIGHT, 0);
    PetParty_TrainingPetInformationFrame:SetPoint("TOP", PetParty_MainFrame, "TOP", 0, PetParty.MAIN_FRAME_OFFSET_TOP);
    PetParty_TrainingPetInformationFrame:SetHeight(PetParty.TRAINING_PET_INFORMATION_FRAME_HEIGHT);
    
    local texture = PetParty_TrainingPetInformationFrame:CreateTexture();
    texture:SetAllPoints();
    texture:SetTexture(TRAINING_PET_R,
                       TRAINING_PET_G,
                       TRAINING_PET_B,
                       TRAINING_PET_A);
    
    -- Initialize the training pet information frame's pet frame variable.
    PetParty_TrainingPetInformationFrame.pet_frame = PetParty.CreatePetInformationFrame(PetParty_TrainingPetInformationFrame, "PetParty_TrainingPetInformationFrame_1");
    
    -- Configure the training pet information frame.
    PetParty_TrainingPetInformationFrame.pet_frame:ClearAllPoints();
    PetParty_TrainingPetInformationFrame.pet_frame:SetPoint("TOPLEFT", PetParty_TrainingPetInformationFrame);
    PetParty_TrainingPetInformationFrame.pet_frame:SetPoint("BOTTOMRIGHT", PetParty_TrainingPetInformationFrame);
    
    -- Update the handler for when the mouse is released on the training pet information frame.
    PetParty_TrainingPetInformationFrame.pet_frame:SetScript("OnMouseUp",
        function(self, button)
            local cursorType, petID = GetCursorInfo();
            if cursorType == "battlepet" then
                -- If this is the training pet...
                if (PetParty.training_pet_cursor) then
                    -- Store the pet GUID.
                    PetParty.SetPetGUIDTrainingPetFrame(petID);
                    
                    -- Store the pet's abilities' GUIDs.
                    local ability_guids = PetParty.GetPetAbilityGUIDsTrainingPetFrame();
                    PetParty.SetPetAbilityGUIDsTrainingPetFrame(ability_guids);
                -- If this is an information pet...
                elseif (PetParty.pet_information_frame_cursor ~= nil) then
                    -- Store the pet's abilities' GUIDs.
                    local ability_guids = PetParty.GetPetAbilityGUIDsPetInformationFrame(PetParty.pet_information_frame_cursor.id);
                    
                    -- Store the pet GUID.
                    PetParty.SetPetGUIDTrainingPetFrame(petID);
                    
                    -- Update the pet's abilities' GUIDs.
                    PetParty.SetPetAbilityGUIDsTrainingPetFrame(ability_guids);
                -- If this is a pet from Blizzard's UI...
                else
                    -- Store the pet GUID.
                    PetParty.SetPetGUIDTrainingPetFrame(petID);
                    
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
                    PetParty.SetPetAbilityGUIDsTrainingPetFrame(ability_guids);
                end
                
                -- Reset the cursor.
                ClearCursor();
                
                -- Update the flags.
                PetParty.pet_information_frame_cursor = nil;
                PetParty.training_pet_cursor = false;
                
                -- Signal the training pet has changed.
                PetParty.OnTrainingPetChangedPetPartyInformationFrame();
            end
        end
    );
    
    -- Update the pet button on click handler.
    PetParty_TrainingPetInformationFrame.pet_frame.pet_button:SetScript("OnClick",
        function (self, button, down)
            local cursorType, petID = GetCursorInfo();
            if (cursorType == "battlepet") then
                -- If this is the training pet...
                if (PetParty.training_pet_cursor) then
                    -- Store the pet GUID.
                    PetParty.SetPetGUIDTrainingPetFrame(petID);
                    
                    -- Store the pet's abilities' GUIDs.
                    local ability_guids = PetParty.GetPetAbilityGUIDsTrainingPetFrame();
                    PetParty.SetPetAbilityGUIDsTrainingPetFrame(ability_guids);
                -- If this is an information pet...
                elseif (PetParty.pet_information_frame_cursor ~= nil) then
                    -- Store the pet's abilities' GUIDs.
                    local ability_guids = PetParty.GetPetAbilityGUIDsPetInformationFrame(PetParty.pet_information_frame_cursor.id);
                    
                    -- Store the pet GUID.
                    PetParty.SetPetGUIDTrainingPetFrame(petID);
                    
                    -- Update the pet's abilities' GUIDs.
                    PetParty.SetPetAbilityGUIDsTrainingPetFrame(ability_guids);
                -- If this is a pet from Blizzard's UI...
                else
                    -- Store the pet GUID.
                    PetParty.SetPetGUIDTrainingPetFrame(petID);
                    
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
                    PetParty.SetPetAbilityGUIDsTrainingPetFrame(ability_guids);
                end
                
                -- Reset the cursor.
                ClearCursor();
                
                -- Update the flags.
                PetParty.pet_information_frame_cursor = nil;
                PetParty.training_pet_cursor = false;
                
                -- Signal the training pet has changed.
                PetParty.OnTrainingPetChangedPetPartyInformationFrame();
            elseif (button == "LeftButton") and (self:GetParent().pet_guid ~= nil) then
                -- Pick up the training pet.
                C_PetJournal.PickupPet(self:GetParent().pet_guid);
                
                -- Update the training pet cursor flag.
                PetParty.training_pet_cursor = true;
            end
        end
    );
    
    -- Update the training pet button handlers.
    for j = 1, PetParty.ABILITY_GROUPS_PER_PET do
        for k = 1, PetParty.ABILITIES_PER_ABILITY_GROUP do
            -- Get the button.
            local button = PetParty_TrainingPetInformationFrame.pet_frame.pet_ability_buttons[((j - 1) + ((k - 1) * PetParty.ABILITY_GROUPS_PER_PET)) + 1];
            
            -- Update the handler for when the mouse clicks a training pet information ability button.
            button:SetScript("OnClick",
                function(self)
                    -- Activate this ability.
                    self:GetParent().pet_ability_buttons_active[self.ability_group] = self;
                    
                    -- Signal the training pet has changed.
                    PetParty.OnTrainingPetChangedPetPartyInformationFrame();
                    
                    -- Update the display.
                    PetParty.UpdateTrainingPetInformationFrame();
                end
            );
            
            -- Update the handler for when the mouse enters a training pet information ability button.
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
                        PetJournal_ShowAbilityTooltip(self, self.ability_id, speciesID, self:GetParent().pet_guid, nil);
                    end
                end
            );
            
            -- Update the handler for when the mouse leaves a training pet information ability button.
            button:SetScript("OnLeave",
                function(self)
                    -- Hide the tooltip.
                    PetJournalPrimaryAbilityTooltip:Hide();
                end
            );
        end
    end
end

-- Called when the training pet information frame is shown.
function PetParty.OnShowTrainingPetInformationFrame()
    -- If the training pet has not been deserialized.
    if (not is_deserialized) then
        -- Update the flag.
        is_deserialized = true;
        
        -- Deserialize the training pet.
        PetParty.DeserializeTrainingPet();
        
        -- Update the pet frame's information.
        PetParty.UpdateTrainingPetInformationFrame();
    end
end

-- Call to serialize the training pet.
function PetParty.SerializeTrainingPet()
    if (PetPartyDB == nil) then
        PetPartyDB = {};
    end
    
    -- Clear any old data.
    PetPartyDB.training_pet = {};
    
    -- Store the training pet's GUID.
    PetPartyDB.training_pet.guid = PetParty.GetPetGUIDTrainingPetFrame();
    
    -- Store the training pet's ability GUIDs.
    PetPartyDB.training_pet.ability_guids = PetParty.GetPetAbilityGUIDsTrainingPetFrame();
end

-- Call to set a pet in the training pet information frame.
function PetParty.SetPetGUIDTrainingPetFrame(pet_guid)
    -- Get the pet information frame.
    local pet_information_frame = PetParty_TrainingPetInformationFrame.pet_frame;
    
    -- Store the new pet.
    pet_information_frame.pet_guid = pet_guid;
    
    -- Update the pet frame's information.
    PetParty.UpdateTrainingPetInformationFrame();
end

-- Call to set a pet's abilities in the training pet information frame.
function PetParty.SetPetAbilityGUIDsTrainingPetFrame(ability_guids)
    -- Get the pet information frame.
    local pet_information_frame = PetParty_TrainingPetInformationFrame.pet_frame;
    
    -- Reset the ability GUIDs.
    pet_information_frame.pet_ability_buttons_active = {};
    
    -- For each ability GUID...
    for i = 1, #ability_guids do
        -- For each ability button...
        for j = 1, #pet_information_frame.pet_ability_buttons do
            -- Get the ability GUID.
            local ability_guid = ability_guids[i];
            
            -- Get the ability button.
            local ability_button = pet_information_frame.pet_ability_buttons[j];
            if (ability_button.ability_id == ability_guid) then
                table.insert(pet_information_frame.pet_ability_buttons_active, ability_button);
            end
        end
    end
    
    -- Update the pet frame's information.
    PetParty.UpdateTrainingPetInformationFrame();
end

-- Call to update the pet information in a pet information frame.
function PetParty.UpdateTrainingPetInformationFrame()
    -- Get the pet information frame.
    local pet_information_frame = PetParty_TrainingPetInformationFrame.pet_frame;
    
    -- If there is a training pet...
    if (pet_information_frame.pet_guid ~= nil) then
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
        
        -- Get the pet's statistics.
        local health, maxHealth, attack, speed, rarity = C_PetJournal.GetPetStats(pet_information_frame.pet_guid);
        
        -- Update the pet button.
        pet_information_frame.pet_button.icon:SetTexture(icon);
        pet_information_frame.pet_button.level:SetShown(canBattle);
        pet_information_frame.pet_button.level:SetText(level);
        pet_information_frame.pet_button.iconBorder:Show();
        pet_information_frame.pet_button.iconBorder:SetVertexColor(ITEM_QUALITY_COLORS[rarity - 1].r,
                                                                   ITEM_QUALITY_COLORS[rarity - 1].g,
                                                                   ITEM_QUALITY_COLORS[rarity - 1].b);
        
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
            
            pet_information_frame.pet_ability_buttons[i].icon.texture:SetTexture(0, 0, 0, 0);
        end
        
        -- For each activated pet ability.
        for i = 1, #pet_information_frame.pet_ability_buttons_active do
            -- Get the ability button.
            local ability_button = pet_information_frame.pet_ability_buttons_active[i];
            
            -- Update the pet ability button icon.
            ability_button.icon.texture:SetTexture(BUTTON_ICON_R,
                                                   BUTTON_ICON_G,
                                                   BUTTON_ICON_B,
                                                   BUTTON_ICON_A);
        end
    -- If there is not a training pet...
    else
        -- Update the title.
        pet_information_frame.font_string_title:SetText(PetParty.L["Training Pet"]);
        
        -- Update the pet button.
        pet_information_frame.pet_button.icon:SetTexture("INTERFACE\\ICONS\\Ability_ambush");
        pet_information_frame.pet_button.level:Hide();
        pet_information_frame.pet_button.iconBorder:Hide();
        
        -- For each potential pet ability...
        local ability_count = PetParty.ABILITY_GROUPS_PER_PET * PetParty.ABILITIES_PER_ABILITY_GROUP;
        for i = 1, ability_count do
            -- Update the pet ability button.
            pet_information_frame.pet_ability_buttons[i].ability_id = nil;
            pet_information_frame.pet_ability_buttons[i].texture:SetTexture(nil);
            
            -- Update the pet ability button icon.
            pet_information_frame.pet_ability_buttons[i].icon.texture:SetTexture(0, 0, 0, 0);
        end
    end
end
