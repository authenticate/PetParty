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
local SCROLL_FRAME_OFFSET_TOP = -60;
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
            PetParty.UpdatePetPartyScrollBarLayout();
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
    -- Reset the height of the content frame.
    height_content_frame = 0;
    
    -- Update the scroll bar layout.
    PetParty.UpdatePetPartyScrollBarLayout();
end

-- Call to update the pet party scroll bar layout.
function PetParty.UpdatePetPartyScrollBarLayout()
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
