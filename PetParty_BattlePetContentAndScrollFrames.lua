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

-- Call to create the battle pet content and scroll frames.
function PetParty.CreateBattlePetContentAndScrollFrames()
    -- Clean up the old UI elements.
    if (PetParty_BattlePetScrollFrame ~= nil) then
        PetParty_BattlePetScrollFrame:Hide();
        PetParty_BattlePetScrollFrame:SetParent(nil);
        PetParty_BattlePetScrollFrame = nil;
    end
    
    if (PetParty_BattlePetScrollBar ~= nil) then
        PetParty_BattlePetScrollBar:Hide();
        PetParty_BattlePetScrollBar:SetParent(nil);
        PetParty_BattlePetScrollBar = nil;
    end
    
    if (PetParty_BattlePetContentFrame ~= nil) then
        PetParty_BattlePetContentFrame:Hide();
        PetParty_BattlePetContentFrame:SetParent(nil);
        PetParty_BattlePetContentFrame = nil;
    end
    
    -- Create the scroll frame.
    CreateFrame("ScrollFrame", "PetParty_BattlePetScrollFrame", PetParty_MainFrame);
    PetParty_BattlePetScrollFrame:SetPoint("TOPLEFT", SCROLL_FRAME_OFFSET_LEFT, SCROLL_FRAME_OFFSET_TOP);
    PetParty_BattlePetScrollFrame:SetPoint("BOTTOM", 0, SCROLL_FRAME_OFFSET_BOTTOM);
    PetParty_BattlePetScrollFrame:EnableMouseWheel(true);
    PetParty_BattlePetScrollFrame:SetWidth((PetParty_BattlePetScrollFrame:GetParent():GetWidth() / 2) - SCROLL_FRAME_OFFSET_LEFT);
    
    local texture = PetParty_BattlePetScrollFrame:CreateTexture();
    texture:SetAllPoints();
    texture:SetTexture(0, 0, 0, 0);
    
    -- Create the scroll bar.
    CreateFrame("Slider", "PetParty_BattlePetScrollBar", PetParty_BattlePetScrollFrame, "UIPanelScrollBarTemplate");
    PetParty_BattlePetScrollBar:SetPoint("TOPLEFT", PetParty_BattlePetScrollFrame, "TOPRIGHT", SCROLL_BAR_OFFSET_LEFT, SCROLL_BAR_OFFSET_TOP);
    PetParty_BattlePetScrollBar:SetPoint("BOTTOMLEFT", PetParty_BattlePetScrollFrame, "BOTTOMRIGHT", SCROLL_BAR_OFFSET_RIGHT, SCROLL_BAR_OFFSET_BOTTOM);
    PetParty_BattlePetScrollBar:SetMinMaxValues(0, 0);
    PetParty_BattlePetScrollBar:SetValueStep(0);
    PetParty_BattlePetScrollBar.scrollStep = BATTLE_PET_FRAME_SIZE;
    PetParty_BattlePetScrollBar:SetStepsPerPage(SCROLL_BAR_STEPS_PER_PAGE);
    PetParty_BattlePetScrollBar:SetValue(0);
    PetParty_BattlePetScrollBar:SetWidth(SCROLL_BAR_WIDTH);
    PetParty_BattlePetScrollBar:SetObeyStepOnDrag(true);
    
    -- Add a mouse wheel handler for the scroll frame.
    PetParty_BattlePetScrollFrame:SetScript("OnMouseWheel",
        function(self, delta)
            PetParty_BattlePetScrollBar:SetValue(PetParty_BattlePetScrollBar:GetValue() - (delta * PetParty_BattlePetScrollBar:GetValueStep()));
        end
    );
    
    -- Add a size changed handler for the scroll frame.
    PetParty_BattlePetScrollFrame:SetScript("OnSizeChanged",
        function(self, width, height)
            PetParty.UpdateBattlePetScrollBarLayout();
        end
    );
    
    local texture_background = PetParty_BattlePetScrollBar:CreateTexture(nil, "BACKGROUND");
    texture_background:SetAllPoints(PetParty_BattlePetScrollBar);
    texture_background:SetTexture(0, 0, 0, SCROLL_BAR_ALPHA);
    
    -- Create the content frame.
    CreateFrame("Frame", "PetParty_BattlePetContentFrame", PetParty_BattlePetScrollFrame);
    PetParty_BattlePetContentFrame:SetWidth(1);
    PetParty_BattlePetContentFrame:SetHeight(1);
    
    -- Set up the scroll child.
    PetParty_BattlePetScrollFrame:SetScrollChild(PetParty_BattlePetContentFrame);
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
            local font_string = PetParty_BattlePetContentFrame:CreateFontString();
            font_string:SetFont(BATTLE_PET_FRAME_FONT, BATTLE_PET_FRAME_FONT_SIZE);
            font_string:SetHeight(BATTLE_PET_FRAME_SIZE);
            font_string:SetText(speciesName);
            
            -- Store this battle pet's ID.
            font_string.battle_pet_id = petID;
            
            if (previous_battle_pet_frame == nil) then
                -- Anchor the frame to the content frame.
                font_string:SetPoint("TOPLEFT", PetParty_BattlePetContentFrame);
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
    
    -- Update the scroll bar layout.
    PetParty.UpdateBattlePetScrollBarLayout();
end

-- Call to update the battle pet scroll bar layout.
function PetParty.UpdateBattlePetScrollBarLayout()
    -- Update the width of the battle pet scroll frame.
    PetParty_BattlePetScrollFrame:SetWidth((PetParty_BattlePetScrollFrame:GetParent():GetWidth() / 2) - SCROLL_FRAME_OFFSET_LEFT);
    
    -- Update the battle pet scroll bar.
    if (height_content_frame < PetParty_BattlePetScrollFrame:GetHeight()) then
        PetParty_BattlePetScrollBar:SetMinMaxValues(0, 0);
        PetParty_BattlePetScrollBar:SetValueStep(0);
    else
        PetParty_BattlePetScrollBar:SetMinMaxValues(1, height_content_frame - PetParty_BattlePetScrollFrame:GetHeight());
        PetParty_BattlePetScrollBar:SetValueStep(BATTLE_PET_FRAME_SIZE);
    end
end
