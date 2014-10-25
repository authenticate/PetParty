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

local PET_PARTY_FRAME_PET_FRAME_HEIGHT = PetParty.PET_PARTY_FRAME_HEIGHT / PetParty.PETS_PER_PARTY;

local PET_PARTY_FRAME_R = 0;
local PET_PARTY_FRAME_G = 0;
local PET_PARTY_FRAME_B = 0;
local PET_PARTY_FRAME_A = 0;

local PET_PARTY_FRAME_PET_FRAME_R = 0.2;
local PET_PARTY_FRAME_PET_FRAME_G = 0.2;
local PET_PARTY_FRAME_PET_FRAME_B = 0.2;
local PET_PARTY_FRAME_PET_FRAME_A = 0.5;

local PET_FRAME_FONT = "Fonts\\FRIZQT__.TTF";
local PET_FRAME_FONT_SIZE = 18;

local PET_FRAME_TITLE_R = 1;
local PET_FRAME_TITLE_G = 1;
local PET_FRAME_TITLE_B = 1;
local PET_FRAME_TITLE_A = 1;

-- The hovered pet party frame.
PetParty.pet_party_frame_hovered = nil;

-- Called when the pet party frame receives an event.
function PetParty.OnEventPetPartyFrame(event)
    if (event == "PET_JOURNAL_LIST_UPDATE") then
        -- Load some initial pets into the pet frames.
        for i = 1, PetParty.PETS_PER_PARTY do
            local petGUID, ability1, ability2, ability3, locked = C_PetJournal.GetPetLoadOutInfo(i);
            if (not locked) and (petGUID ~= nil) then
                PetParty.SetPetPetPartyFrame(i, petGUID);
            end
        end
    end
end

-- Called when the pet party frame is loaded.
function PetParty.OnLoadPetPartyFrame()
    -- Configure the pet party frame.
    PetParty_PetPartyFrame:ClearAllPoints();
    PetParty_PetPartyFrame:SetPoint("LEFT", PetParty_BattlePetScrollFrame, "RIGHT", PADDING, 0);
    PetParty_PetPartyFrame:SetPoint("RIGHT", PetParty_PetPartyScrollFrame);
    PetParty_PetPartyFrame:SetPoint("TOP", PetParty_PetPartyScrollFrame, "BOTTOM", 0, -PADDING);
    PetParty_PetPartyFrame:SetPoint("BOTTOM", PetParty_MainFrame, "BOTTOM", 0, (-PetParty.MAIN_FRAME_OFFSET_Y) + PADDING);
    
    -- Register the per party frame for events.
    PetParty_PetPartyFrame:RegisterEvent("PET_JOURNAL_LIST_UPDATE");
    
    -- Configure the pet party frame's background texture.
    local texture = PetParty_PetPartyFrame:CreateTexture();
    texture:SetAllPoints();
    texture:SetTexture(PET_PARTY_FRAME_R,
                       PET_PARTY_FRAME_G,
                       PET_PARTY_FRAME_B,
                       PET_PARTY_FRAME_A);
    
    -- Initialize the pet party frame's pet frames variable.
    PetParty_PetPartyFrame.pet_frames = {};
    
    --
    -- Configure the pet party frame's pet frames.
    --
    
    --
    -- Pet frame one.
    --
    
    local pet_frame = CreateFrame("Frame", nil, PetParty_PetPartyFrame);
    pet_frame:ClearAllPoints();
    pet_frame:SetPoint("TOPLEFT", PetParty_PetPartyFrame);
    pet_frame:SetPoint("RIGHT", PetParty_PetPartyFrame);
    pet_frame:SetHeight(PET_PARTY_FRAME_PET_FRAME_HEIGHT);
    
    -- Add a handler for when the mouse enters the pet party frame.
    pet_frame:SetScript("OnEnter",
        function(self)
            PetParty.OnEnterPetPartyFrame(self);
        end
    );
    
    -- Add a handler for when the mouse leaves the pet party frame.
    pet_frame:SetScript("OnLeave",
        function(self)
            PetParty.OnLeavePetPartyFrame(self);
        end
    );
    
    pet_frame.id = 1;
    pet_frame.pet_guid = 0;
    
    texture = pet_frame:CreateTexture();
    texture:SetAllPoints();
    texture:SetTexture(PET_PARTY_FRAME_PET_FRAME_R,
                       PET_PARTY_FRAME_PET_FRAME_G,
                       PET_PARTY_FRAME_PET_FRAME_B,
                       PET_PARTY_FRAME_PET_FRAME_A);
    
    pet_frame.font_string_title = pet_frame:CreateFontString();
    pet_frame.font_string_title:SetFont(PET_FRAME_FONT, PET_FRAME_FONT_SIZE);
    pet_frame.font_string_title:SetTextColor(PET_FRAME_TITLE_R,
                                             PET_FRAME_TITLE_G,
                                             PET_FRAME_TITLE_B,
                                             PET_FRAME_TITLE_A);
    pet_frame.font_string_title:ClearAllPoints();
    pet_frame.font_string_title:SetPoint("CENTER", pet_frame);
    
    PetParty_PetPartyFrame.pet_frames[1] = pet_frame;
    
    --
    -- Pet frame two.
    --
    
    pet_frame = CreateFrame("Frame", nil, PetParty_PetPartyFrame);
    pet_frame:ClearAllPoints();
    pet_frame:SetPoint("TOPLEFT", PetParty_PetPartyFrame.pet_frames[1], "BOTTOMLEFT");
    pet_frame:SetPoint("RIGHT", PetParty_PetPartyFrame);
    pet_frame:SetHeight(PET_PARTY_FRAME_PET_FRAME_HEIGHT);
    
    -- Add a handler for when the mouse enters the pet party frame.
    pet_frame:SetScript("OnEnter",
        function(self)
            PetParty.OnEnterPetPartyFrame(self);
        end
    );
    
    -- Add a handler for when the mouse leaves the pet party frame.
    pet_frame:SetScript("OnLeave",
        function(self)
            PetParty.OnLeavePetPartyFrame(self);
        end
    );
    
    pet_frame.id = 2;
    pet_frame.pet_guid = 0;
    
    texture = pet_frame:CreateTexture();
    texture:SetAllPoints();
    texture:SetTexture(PET_PARTY_FRAME_PET_FRAME_R,
                       PET_PARTY_FRAME_PET_FRAME_G,
                       PET_PARTY_FRAME_PET_FRAME_B,
                       PET_PARTY_FRAME_PET_FRAME_A);
    
    pet_frame.font_string_title = pet_frame:CreateFontString();
    pet_frame.font_string_title:SetFont(PET_FRAME_FONT, PET_FRAME_FONT_SIZE);
    pet_frame.font_string_title:SetTextColor(PET_FRAME_TITLE_R,
                                             PET_FRAME_TITLE_G,
                                             PET_FRAME_TITLE_B,
                                             PET_FRAME_TITLE_A);
    pet_frame.font_string_title:ClearAllPoints();
    pet_frame.font_string_title:SetPoint("CENTER", pet_frame);
    
    PetParty_PetPartyFrame.pet_frames[2] = pet_frame;
    
    -- Pet frame three.
    pet_frame = CreateFrame("Frame", nil, PetParty_PetPartyFrame);
    pet_frame:ClearAllPoints();
    pet_frame:SetPoint("TOPLEFT", PetParty_PetPartyFrame.pet_frames[2], "BOTTOMLEFT");
    pet_frame:SetPoint("BOTTOMRIGHT", PetParty_PetPartyFrame);
    
    -- Add a handler for when the mouse enters the pet party frame.
    pet_frame:SetScript("OnEnter",
        function(self)
            PetParty.OnEnterPetPartyFrame(self);
        end
    );
    
    -- Add a handler for when the mouse leaves the pet party frame.
    pet_frame:SetScript("OnLeave",
        function(self)
            PetParty.OnLeavePetPartyFrame(self);
        end
    );
    
    pet_frame.id = 3;
    pet_frame.pet_guid = 0;
    
    texture = pet_frame:CreateTexture();
    texture:SetAllPoints();
    texture:SetTexture(PET_PARTY_FRAME_PET_FRAME_R,
                       PET_PARTY_FRAME_PET_FRAME_G,
                       PET_PARTY_FRAME_PET_FRAME_B,
                       PET_PARTY_FRAME_PET_FRAME_A);
    
    pet_frame.font_string_title = pet_frame:CreateFontString();
    pet_frame.font_string_title:SetFont(PET_FRAME_FONT, PET_FRAME_FONT_SIZE);
    pet_frame.font_string_title:SetTextColor(PET_FRAME_TITLE_R,
                                             PET_FRAME_TITLE_G,
                                             PET_FRAME_TITLE_B,
                                             PET_FRAME_TITLE_A);
    pet_frame.font_string_title:ClearAllPoints();
    pet_frame.font_string_title:SetPoint("CENTER", pet_frame);
    
    PetParty_PetPartyFrame.pet_frames[3] = pet_frame;
end

-- Call to get a pet's GUID from a pet party frame.
function PetParty.GetPetPetPartyFrame(slot_index)
    -- The result.
    local pet_guid = nil;
    
    -- Get the pet frame.
    local pet_frame = PetParty_PetPartyFrame.pet_frames[slot_index];
    if (pet_frame ~= nil) then
        pet_guid = pet_frame.pet_guid;
    end
    
    -- Return the result.
    return pet_guid;
end

-- Called when the mouse enters a pet party frame.
function PetParty.OnEnterPetPartyFrame(self)
    PetParty.pet_party_frame_hovered = self;
end

-- Called when the mouse leaves a pet party frame.
function PetParty.OnLeavePetPartyFrame(self)
    PetParty.pet_party_frame_hovered = nil;
end

-- Call to set a pet in the pet party frame.
function PetParty.SetPetPetPartyFrame(slot_index, pet_guid)
    -- Sanity.
    if (pet_guid ~= nil) then
        -- If the slot is not locked...
        local petGUID, ability1, ability2, ability3, locked = C_PetJournal.GetPetLoadOutInfo(slot_index);
        if (not locked) then
            -- Get the pet frame.
            local pet_frame = PetParty_PetPartyFrame.pet_frames[slot_index];
            
            -- Store the pet's GUID.
            pet_frame.pet_guid = pet_guid;
            
            -- Get the pet's information.
            local speciesID, customName, level, XP, maxXP, displayID, isFavorite,
                speciesName, icon, petType, companionID,
                tooltip, description, isWild, canBattle, isTradable,
                isUnique, isObtainable = C_PetJournal.GetPetInfoByPetID(pet_guid);
            
            -- If this pet has a custom name...
            if (customName ~= nil) and (customName ~= "") then
                pet_frame.font_string_title:SetText(customName .. " (" .. speciesName .. ")");
            else
                pet_frame.font_string_title:SetText(speciesName);
            end
        end
    end
end

-- Call to set the pets in the pet party frame.
function PetParty.SetPetsPetPartyFrame(pet_guid_one, pet_guid_two, pet_guid_three)
    -- Sanity.
    if (pet_guid_one ~= nil) then
        PetParty.SetPetPetPartyFrame(1, pet_guid_one);
    end
    
    -- Sanity.
    if (pet_guid_two ~= nil) then
        PetParty.SetPetPetPartyFrame(2, pet_guid_two);
    end
    
    -- Sanity.
    if (pet_guid_three ~= nil) then
        PetParty.SetPetPetPartyFrame(3, pet_guid_three);
    end
end
