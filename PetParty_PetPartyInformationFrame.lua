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

local BUTTON_HEIGHT = 22;

local PET_INFORMATION_PARTY_PET_INFORMATION_HEIGHT = (PetParty.PET_INFORMATION_PARTY_FRAME_HEIGHT - BUTTON_HEIGHT) /
                                                     PetParty.PETS_PER_PARTY;

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

-- The hovered pet information frame.
PetParty.pet_information_frame_hovered = nil;

-- Called when the pet party information frame's activate button is clicked.
function PetParty.OnClickPetPartyInformationFrameButtonActivate()
    -- Activate the pets from the UI.
    for i = 1, PetParty.PETS_PER_PARTY do
        C_PetJournal.SetPetLoadOutInfo(i, PetParty_PetPartyInformationFrame.pet_frames[i].pet_guid);
    end
end

-- Called when the pet party information frame's save button is clicked.
function PetParty.OnClickPetPartyInformationFrameButtonSave()
    -- Store the pets from the UI into the selected pet party frame.
    if (PetParty.pet_party_frame_selected ~= nil) then
        for i = 1, PetParty.PETS_PER_PARTY do
            PetParty.pet_party_frame_selected.pet_guids[i] = PetParty_PetPartyInformationFrame.pet_frames[i].pet_guid;
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
                end
            end
        end
    end
end

-- Called when the pet party information frame is loaded.
function PetParty.OnLoadPetPartyInformationFrame()
    -- Configure the pet party information frame.
    PetParty_PetPartyInformationFrame:ClearAllPoints();
    PetParty_PetPartyInformationFrame:SetPoint("LEFT", PetParty_PetPartyScrollFrame, PADDING, 0);
    PetParty_PetPartyInformationFrame:SetPoint("RIGHT", PetParty_PetPartyScrollFrame);
    PetParty_PetPartyInformationFrame:SetPoint("TOP", PetParty_PetPartyScrollFrame, "BOTTOM", 0, -PADDING);
    PetParty_PetPartyInformationFrame:SetPoint("BOTTOM", PetParty_MainFrame, "BOTTOM", 0, (-PetParty.MAIN_FRAME_OFFSET_Y) + PADDING);
    
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
    
    --
    -- Pet frame one.
    --
    
    local pet_information_frame = CreateFrame("Frame", nil, PetParty_PetPartyInformationFrame);
    pet_information_frame:ClearAllPoints();
    pet_information_frame:SetPoint("TOPLEFT", PetParty_PetPartyInformationFrame, 0, -BUTTON_HEIGHT);
    pet_information_frame:SetPoint("RIGHT", PetParty_PetPartyInformationFrame);
    pet_information_frame:SetHeight(PET_INFORMATION_PARTY_PET_INFORMATION_HEIGHT);
    
    -- Add a handler for when the mouse enters the pet information frame.
    pet_information_frame:SetScript("OnEnter",
        function(self)
            PetParty.OnEnterPetInformationFrame(self);
        end
    );
    
    -- Add a handler for when the mouse leaves the pet information frame.
    pet_information_frame:SetScript("OnLeave",
        function(self)
            PetParty.OnLeavePetInformationFrame(self);
        end
    );
    
    pet_information_frame.id = 1;
    pet_information_frame.pet_guid = nil;
    
    texture = pet_information_frame:CreateTexture();
    texture:SetAllPoints();
    texture:SetTexture(PET_INFORMATION_PARTY_PET_INFORMATION_R,
                       PET_INFORMATION_PARTY_PET_INFORMATION_G,
                       PET_INFORMATION_PARTY_PET_INFORMATION_B,
                       PET_INFORMATION_PARTY_PET_INFORMATION_A);
    
    pet_information_frame.font_string_title = pet_information_frame:CreateFontString();
    pet_information_frame.font_string_title:SetFont(PET_INFORMATION_FONT, PET_INFORMATION_FONT_SIZE);
    pet_information_frame.font_string_title:SetTextColor(PET_INFORMATION_TITLE_R,
                                                         PET_INFORMATION_TITLE_G,
                                                         PET_INFORMATION_TITLE_B,
                                                         PET_INFORMATION_TITLE_A);
    pet_information_frame.font_string_title:ClearAllPoints();
    pet_information_frame.font_string_title:SetPoint("CENTER", pet_information_frame);
    
    PetParty_PetPartyInformationFrame.pet_frames[1] = pet_information_frame;
    
    --
    -- Pet frame two.
    --
    
    pet_information_frame = CreateFrame("Frame", nil, PetParty_PetPartyInformationFrame);
    pet_information_frame:ClearAllPoints();
    pet_information_frame:SetPoint("TOPLEFT", PetParty_PetPartyInformationFrame.pet_frames[1], "BOTTOMLEFT");
    pet_information_frame:SetPoint("RIGHT", PetParty_PetPartyInformationFrame);
    pet_information_frame:SetHeight(PET_INFORMATION_PARTY_PET_INFORMATION_HEIGHT);
    
    -- Add a handler for when the mouse enters the pet information frame.
    pet_information_frame:SetScript("OnEnter",
        function(self)
            PetParty.OnEnterPetInformationFrame(self);
        end
    );
    
    -- Add a handler for when the mouse leaves the pet information frame.
    pet_information_frame:SetScript("OnLeave",
        function(self)
            PetParty.OnLeavePetInformationFrame(self);
        end
    );
    
    pet_information_frame.id = 2;
    pet_information_frame.pet_guid = nil;
    
    texture = pet_information_frame:CreateTexture();
    texture:SetAllPoints();
    texture:SetTexture(PET_INFORMATION_PARTY_PET_INFORMATION_R,
                       PET_INFORMATION_PARTY_PET_INFORMATION_G,
                       PET_INFORMATION_PARTY_PET_INFORMATION_B,
                       PET_INFORMATION_PARTY_PET_INFORMATION_A);
    
    pet_information_frame.font_string_title = pet_information_frame:CreateFontString();
    pet_information_frame.font_string_title:SetFont(PET_INFORMATION_FONT, PET_INFORMATION_FONT_SIZE);
    pet_information_frame.font_string_title:SetTextColor(PET_INFORMATION_TITLE_R,
                                                         PET_INFORMATION_TITLE_G,
                                                         PET_INFORMATION_TITLE_B,
                                                         PET_INFORMATION_TITLE_A);
    pet_information_frame.font_string_title:ClearAllPoints();
    pet_information_frame.font_string_title:SetPoint("CENTER", pet_information_frame);
    
    PetParty_PetPartyInformationFrame.pet_frames[2] = pet_information_frame;
    
    -- Pet frame three.
    pet_information_frame = CreateFrame("Frame", nil, PetParty_PetPartyInformationFrame);
    pet_information_frame:ClearAllPoints();
    pet_information_frame:SetPoint("TOPLEFT", PetParty_PetPartyInformationFrame.pet_frames[2], "BOTTOMLEFT");
    pet_information_frame:SetPoint("BOTTOMRIGHT", PetParty_PetPartyInformationFrame);
    
    -- Add a handler for when the mouse enters the pet information frame.
    pet_information_frame:SetScript("OnEnter",
        function(self)
            PetParty.OnEnterPetInformationFrame(self);
        end
    );
    
    -- Add a handler for when the mouse leaves the pet information frame.
    pet_information_frame:SetScript("OnLeave",
        function(self)
            PetParty.OnLeavePetInformationFrame(self);
        end
    );
    
    pet_information_frame.id = 3;
    pet_information_frame.pet_guid = nil;
    
    texture = pet_information_frame:CreateTexture();
    texture:SetAllPoints();
    texture:SetTexture(PET_INFORMATION_PARTY_PET_INFORMATION_R,
                       PET_INFORMATION_PARTY_PET_INFORMATION_G,
                       PET_INFORMATION_PARTY_PET_INFORMATION_B,
                       PET_INFORMATION_PARTY_PET_INFORMATION_A);
    
    pet_information_frame.font_string_title = pet_information_frame:CreateFontString();
    pet_information_frame.font_string_title:SetFont(PET_INFORMATION_FONT, PET_INFORMATION_FONT_SIZE);
    pet_information_frame.font_string_title:SetTextColor(PET_INFORMATION_TITLE_R,
                                                         PET_INFORMATION_TITLE_G,
                                                         PET_INFORMATION_TITLE_B,
                                                         PET_INFORMATION_TITLE_A);
    pet_information_frame.font_string_title:ClearAllPoints();
    pet_information_frame.font_string_title:SetPoint("CENTER", pet_information_frame);
    
    PetParty_PetPartyInformationFrame.pet_frames[3] = pet_information_frame;
    
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

-- Called when the mouse enters a pet information frame.
function PetParty.OnEnterPetInformationFrame(self)
    PetParty.pet_information_frame_hovered = self;
end

-- Called when the mouse leaves a pet information frame.
function PetParty.OnLeavePetInformationFrame(self)
    PetParty.pet_information_frame_hovered = nil;
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

-- Call to set the pets in the pet information frame.
function PetParty.SetPetGUIDsPetInformationFrame(pet_guid_one, pet_guid_two, pet_guid_three)
    -- Sanity.
    if (pet_guid_one ~= nil) then
        -- Enforce uniqueness.
        if (pet_guid_one ~= pet_guid_two) and (pet_guid_one ~= pet_guid_three) then
            PetParty.SetPetGUIDPetInformationFrame(1, pet_guid_one);
        end
    end
    
    -- Sanity.
    if (pet_guid_two ~= nil) then
        -- Enforce uniqueness.
        if (pet_guid_two ~= pet_guid_one) and (pet_guid_two ~= pet_guid_three) then
            PetParty.SetPetGUIDPetInformationFrame(2, pet_guid_two);
        end
    end
    
    -- Sanity.
    if (pet_guid_three ~= nil) then
        -- Enforce uniqueness.
        if (pet_guid_three ~= pet_guid_one) and (pet_guid_three ~= pet_guid_two) then
            PetParty.SetPetGUIDPetInformationFrame(3, pet_guid_three);
        end
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
    
    -- Update the position of the active pet information frame button.
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
        end
    end
end
