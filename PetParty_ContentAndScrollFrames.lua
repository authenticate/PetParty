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

local SCROLL_FRAME_OFFSET_LEFT = 14;
local SCROLL_FRAME_OFFSET_RIGHT = -14;
local SCROLL_FRAME_OFFSET_TOP = -36;
local SCROLL_FRAME_OFFSET_BOTTOM = 34;

local SCROLL_BAR_ALPHA = 0.4;

local SCROLL_BAR_WIDTH = 16;

local SCROLL_BAR_OFFSET_LEFT = -30;
local SCROLL_BAR_OFFSET_RIGHT = -30;
local SCROLL_BAR_OFFSET_TOP = -52;
local SCROLL_BAR_OFFSET_BOTTOM = 50;

-- The height of the content frame.
local height_content_frame = 0;

-- Call to create the content and scroll frames.
function PetParty.CreateContentAndScrollFrames()
    -- Create the scroll frame.
    CreateFrame("ScrollFrame", "PetParty_ScrollFrame", PetParty_MainFrame);
    PetParty_ScrollFrame:SetPoint("TOPLEFT", SCROLL_FRAME_OFFSET_LEFT, SCROLL_FRAME_OFFSET_TOP);
    PetParty_ScrollFrame:SetPoint("BOTTOMRIGHT", SCROLL_FRAME_OFFSET_RIGHT, SCROLL_FRAME_OFFSET_BOTTOM);
    PetParty_ScrollFrame:EnableMouseWheel(true);
    
    local texture = PetParty_ScrollFrame:CreateTexture();
    texture:SetAllPoints();
    texture:SetTexture(0, 0, 0, 0);
    
    -- Create the scroll bar.
    CreateFrame("Slider", "PetParty_ScrollBar", PetParty_ScrollFrame, "UIPanelScrollBarTemplate");
    PetParty_ScrollBar:SetPoint("TOPLEFT", PetParty_MainFrame, "TOPRIGHT", SCROLL_BAR_OFFSET_LEFT, SCROLL_BAR_OFFSET_TOP);
    PetParty_ScrollBar:SetPoint("BOTTOMLEFT", PetParty_MainFrame, "BOTTOMRIGHT", SCROLL_BAR_OFFSET_RIGHT, SCROLL_BAR_OFFSET_BOTTOM);
    PetParty_ScrollBar:SetMinMaxValues(0, 0);
    PetParty_ScrollBar:SetValueStep(0);
    PetParty_ScrollBar:SetStepsPerPage(1);
    PetParty_ScrollBar:SetValue(0);
    PetParty_ScrollBar:SetWidth(SCROLL_BAR_WIDTH);
    PetParty_ScrollBar:SetObeyStepOnDrag(true);
    
    -- Add a mouse wheel handler for the scroll frame.
    PetParty_ScrollFrame:SetScript("OnMouseWheel",
        function(self, delta)
            PetParty_ScrollBar:SetValue(PetParty_ScrollBar:GetValue() - (delta * PetParty_ScrollBar:GetValueStep()));
        end
    );
    
    -- Add a size changed handler for the scroll frame.
    PetParty_ScrollFrame:SetScript("OnSizeChanged",
        function(self, width, height)
            PetParty.UpdateScrollBar();
        end
    );
    
    local texture_background = PetParty_ScrollBar:CreateTexture(nil, "BACKGROUND");
    texture_background:SetAllPoints(PetParty_ScrollBar);
    texture_background:SetTexture(0, 0, 0, SCROLL_BAR_ALPHA);
    
    -- Create the content frame.
    CreateFrame("Frame", "PetParty_ContentFrame", PetParty_ScrollFrame);
    PetParty_ContentFrame:SetWidth(1);
    PetParty_ContentFrame:SetHeight(1);
    
    -- Set up the scroll child.
    PetParty_ScrollFrame:SetScrollChild(PetParty_ContentFrame);
end

-- Call to create the battle pet frames.
function PetParty.CreateBattlePetFrames()
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
            local font_string = PetParty_ContentFrame:CreateFontString();
            font_string:SetFont(BATTLE_PET_FRAME_FONT, BATTLE_PET_FRAME_FONT_SIZE);
            font_string:SetHeight(BATTLE_PET_FRAME_SIZE);
            font_string:SetText(speciesName);
            
            -- Store this battle pet's ID.
            font_string.battle_pet_id = petID;
            
            if (previous_battle_pet_frame == nil) then
                -- Anchor the frame to the content frame.
                font_string:SetPoint("TOPLEFT", PetParty_ContentFrame);
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
    PetParty.UpdateScrollBar();
end

-- Call to update the scroll bar.
function PetParty.UpdateScrollBar()
    if (height_content_frame < PetParty_ScrollFrame:GetHeight()) then
        PetParty_ScrollBar:SetMinMaxValues(0, 0);
        PetParty_ScrollBar:SetValueStep(0);
    else
        PetParty_ScrollBar:SetMinMaxValues(1, height_content_frame - PetParty_ScrollFrame:GetHeight());
        PetParty_ScrollBar:SetValueStep(BATTLE_PET_FRAME_SIZE);
    end
end
