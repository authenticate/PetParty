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

local BATTLE_PET_FRAME_FONT = "Fonts\\FRIZQT__.TTF";
local BATTLE_PET_FRAME_FONT_SIZE = 18;
local BATTLE_PET_FRAME_SIZE = 18;

local SCROLL_FRAME_OFFSET_RIGHT = 14;
local SCROLL_FRAME_OFFSET_TOP = -36;
local SCROLL_FRAME_OFFSET_BOTTOM = 34;

local SCROLL_BAR_ALPHA = 0.4;

local SCROLL_BAR_OFFSET_LEFT = -16;
local SCROLL_BAR_OFFSET_RIGHT = -16;
local SCROLL_BAR_OFFSET_TOP = -16;
local SCROLL_BAR_OFFSET_BOTTOM = 16;

local SCROLL_BAR_SCROLL_STEP = 1;
local SCROLL_BAR_STEPS_PER_PAGE = 1;

local SCROLL_BAR_WIDTH = 16;

-- The height of the content frame.
local height_content_frame = 0;

-- Call to create the pet party content and scroll frames.
function PetParty.CreatePetPartyContentAndScrollFrames()
    -- Clean up the old UI elements.
    if (PetParty_PetPartyScrollFrame ~= nil) then
        PetParty_PetPartyScrollFrame:Hide();
        PetParty_PetPartyScrollFrame:SetParent(nil);
        PetParty_PetPartyScrollFrame = nil;
    end
    
    if (PetParty_PetPartyScrollBar ~= nil) then
        PetParty_PetPartyScrollBar:Hide();
        PetParty_PetPartyScrollBar:SetParent(nil);
        PetParty_PetPartyScrollBar = nil;
    end
    
    if (PetParty_PetPartyContentFrame ~= nil) then
        PetParty_PetPartyContentFrame:Hide();
        PetParty_PetPartyContentFrame:SetParent(nil);
        PetParty_PetPartyContentFrame = nil;
    end
    
    -- Create the scroll frame.
    CreateFrame("ScrollFrame", "PetParty_PetPartyScrollFrame", PetParty_MainFrame);
    PetParty_PetPartyScrollFrame:SetPoint("TOPLEFT", PetParty_PetPartyScrollFrame:GetParent():GetWidth() / 2, SCROLL_FRAME_OFFSET_TOP);
    PetParty_PetPartyScrollFrame:SetPoint("BOTTOM", 0, SCROLL_FRAME_OFFSET_BOTTOM);
    PetParty_PetPartyScrollFrame:EnableMouseWheel(true);
    PetParty_PetPartyScrollFrame:SetWidth((PetParty_PetPartyScrollFrame:GetParent():GetWidth() / 2) - SCROLL_FRAME_OFFSET_RIGHT);
    
    local texture = PetParty_PetPartyScrollFrame:CreateTexture();
    texture:SetAllPoints();
    texture:SetTexture(0, 0, 0, 0);
    
    -- Create the scroll bar.
    CreateFrame("Slider", "PetParty_PetPartyScrollBar", PetParty_PetPartyScrollFrame, "UIPanelScrollBarTemplate");
    PetParty_PetPartyScrollBar:SetPoint("TOPLEFT", PetParty_PetPartyScrollFrame, "TOPRIGHT", SCROLL_BAR_OFFSET_LEFT, SCROLL_BAR_OFFSET_TOP);
    PetParty_PetPartyScrollBar:SetPoint("BOTTOMLEFT", PetParty_PetPartyScrollFrame, "BOTTOMRIGHT", SCROLL_BAR_OFFSET_RIGHT, SCROLL_BAR_OFFSET_BOTTOM);
    PetParty_PetPartyScrollBar:SetMinMaxValues(0, 0);
    PetParty_PetPartyScrollBar:SetValueStep(0);
    PetParty_PetPartyScrollBar.scrollStep = BATTLE_PET_FRAME_SIZE;
    PetParty_PetPartyScrollBar:SetStepsPerPage(SCROLL_BAR_STEPS_PER_PAGE);
    PetParty_PetPartyScrollBar:SetValue(0);
    PetParty_PetPartyScrollBar:SetWidth(SCROLL_BAR_WIDTH);
    PetParty_PetPartyScrollBar:SetObeyStepOnDrag(true);
    
    -- Add a mouse wheel handler for the scroll frame.
    PetParty_PetPartyScrollFrame:SetScript("OnMouseWheel",
        function(self, delta)
            PetParty_PetPartyScrollBar:SetValue(PetParty_PetPartyScrollBar:GetValue() - (delta * PetParty_PetPartyScrollBar:GetValueStep()));
        end
    );
    
    -- Add a size changed handler for the scroll frame.
    PetParty_PetPartyScrollFrame:SetScript("OnSizeChanged",
        function(self, width, height)
            PetParty.UpdatePetPartyScrollBar();
        end
    );
    
    local texture_background = PetParty_PetPartyScrollBar:CreateTexture(nil, "BACKGROUND");
    texture_background:SetAllPoints(PetParty_PetPartyScrollBar);
    texture_background:SetTexture(0, 0, 0, SCROLL_BAR_ALPHA);
    
    -- Create the content frame.
    CreateFrame("Frame", "PetParty_PetPartyContentFrame", PetParty_PetPartyScrollFrame);
    PetParty_PetPartyContentFrame:SetWidth(1);
    PetParty_PetPartyContentFrame:SetHeight(1);
    
    -- Set up the scroll child.
    PetParty_PetPartyScrollFrame:SetScrollChild(PetParty_PetPartyContentFrame);
end

-- Call to create the pet party frames.
function PetParty.CreatePetPartyFrames()
    -- Get the total number of pets.
    local number_of_pets = C_PetJournal.GetNumPets();
    
    -- Cache the previous battle pet frame.
    local previous_battle_pet_frame = nil;
    
    -- Reset the height of the content frame.
    height_content_frame = 0;
    
    -- For each battle pet...
    for i = 1, number_of_pets do
        -- Get the battle pet information.
        local petID, speciesID, owned, customName, level, favorite,
              isRevoked, speciesName, icon, petType, companionID,
              tooltip, description, isWild, canBattle, isTradeable,
              isUnique, obtainable = C_PetJournal.GetPetInfoByIndex(i);
        
        -- If the player owns this pet and it is a battle pet...
        if (owned) and (canBattle) then
            --  Create a battle pet frame.
            local font_string = PetParty_PetPartyContentFrame:CreateFontString();
            font_string:SetFont(BATTLE_PET_FRAME_FONT, BATTLE_PET_FRAME_FONT_SIZE);
            font_string:SetHeight(BATTLE_PET_FRAME_SIZE);
            font_string:SetText(speciesName);
            
            -- Store this battle pet's ID.
            font_string.battle_pet_id = petID;
            
            if (previous_battle_pet_frame == nil) then
                -- Anchor the frame to the content frame.
                font_string:SetPoint("TOPLEFT", PetParty_PetPartyContentFrame);
            else
                -- Anchor the frame to the previous frame.
                font_string:SetPoint("BOTTOMLEFT", previous_battle_pet_frame, "BOTTOMLEFT", 0, -BATTLE_PET_FRAME_SIZE);
            end
            
            -- Cache the previous battle pet frame.
            previous_battle_pet_frame = font_string;
            
            -- Update the height of the content frame.
            height_content_frame = height_content_frame + font_string:GetHeight();
        end
    end
    
    -- Update the scroll bar.
    PetParty.UpdatePetPartyScrollBar();
end

-- Call to update the pet party scroll bar.
function PetParty.UpdatePetPartyScrollBar()
    -- Update the anchors of the pet party scroll frame.
    PetParty_PetPartyScrollFrame:SetPoint("TOPLEFT", PetParty_PetPartyScrollFrame:GetParent():GetWidth() / 2, SCROLL_FRAME_OFFSET_TOP);
    PetParty_PetPartyScrollFrame:SetPoint("BOTTOM", 0, SCROLL_FRAME_OFFSET_BOTTOM);
    
    -- Update the width of the pet party scroll frame.
    PetParty_PetPartyScrollFrame:SetWidth((PetParty_PetPartyScrollFrame:GetParent():GetWidth() / 2) - SCROLL_FRAME_OFFSET_RIGHT);
    
    -- Update the pet party scroll bar.
    if (height_content_frame < PetParty_PetPartyScrollFrame:GetHeight()) then
        PetParty_PetPartyScrollBar:SetMinMaxValues(0, 0);
        PetParty_PetPartyScrollBar:SetValueStep(0);
    else
        PetParty_PetPartyScrollBar:SetMinMaxValues(1, height_content_frame - PetParty_PetPartyScrollFrame:GetHeight());
        PetParty_PetPartyScrollBar:SetValueStep(BATTLE_PET_FRAME_SIZE);
    end
end
