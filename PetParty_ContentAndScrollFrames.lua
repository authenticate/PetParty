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

local SCROLL_BAR_VALUE_MINIMUM = 1;
local SCROLL_BAR_VALUE_MAXIMUM = 200;
local SCROLL_BAR_VALUE_STEP = 1;

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
    PetParty_ScrollBar:SetMinMaxValues(SCROLL_BAR_VALUE_MINIMUM, SCROLL_BAR_VALUE_MAXIMUM);
    PetParty_ScrollBar:SetValueStep(SCROLL_BAR_VALUE_STEP);
    PetParty_ScrollBar:SetValue(0);
    PetParty_ScrollBar:SetWidth(SCROLL_BAR_WIDTH);
    PetParty_ScrollBar:SetScript("OnValueChanged",
        function (self, value)
            self:GetParent():SetVerticalScroll(value);
        end
    );
    
    -- Add a mouse wheel handler for the scroll frame.
    PetParty_ScrollFrame:SetScript("OnMouseWheel",
        function(self, delta)
            PetParty_ScrollBar:SetValue(PetParty_ScrollBar:GetValue() - delta);
        end
    );
    
    local texture_background = PetParty_ScrollBar:CreateTexture(nil, "BACKGROUND");
    texture_background:SetAllPoints(PetParty_ScrollBar);
    texture_background:SetTexture(0, 0, 0, SCROLL_BAR_ALPHA);
    
    -- Create the content frame.
    CreateFrame("Frame", "PetParty_ContentFrame", PetParty_ScrollFrame);
    
    --
    -- TODO: This is temporary debugging code.
    --
    
    PetParty_ContentFrame:SetSize(128, 128);
    
    local texture_content = PetParty_ContentFrame:CreateTexture();
    texture_content:SetAllPoints();
    texture_content:SetTexture("Interface\\GLUES\\MainMenu\\Glues-BlizzardLogo");
    
    -- Set up the scroll child.
    PetParty_ScrollFrame:SetScrollChild(PetParty_ContentFrame);
end
