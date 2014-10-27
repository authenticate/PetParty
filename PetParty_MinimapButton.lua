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

local ICON_OFFSET = 70;
local ICON_OFFSET_X = 52;
local ICON_OFFSET_Y = 80;

local ICON_POSITION = 45;

-- TODO: This color is inconsistent with Blizzard's default tooltips.  Does anyone know the correct color?
local TOOLTIP_BACKGROUND_R = 0;
local TOOLTIP_BACKGROUND_G = 0;
local TOOLTIP_BACKGROUND_B = 0;

local TOOLTIP_TITLE_R = 1;
local TOOLTIP_TITLE_G = 1;
local TOOLTIP_TITLE_B = 1;

-- TODO: This color is inconsistent with Blizzard's default tooltips.  Does anyone know the correct color?
local TOOLTIP_DESCRIPTION_R = 1;
local TOOLTIP_DESCRIPTION_G = 210 / 255;
local TOOLTIP_DESCRIPTION_B = 0;

-- Called when the minimap button is clicked.
function PetParty.OnClickMinimapButton(button, down)
    if (button == "LeftButton") and (not down) then
        if (PetParty_MainFrame:IsShown()) then
            PetParty_MainFrame:Hide();
        else
            PetParty_MainFrame:Show();
        end
    end
end

-- Called when the minimap button is started dragging.
function PetParty.OnDragStartMinimapButton()
    PetParty_MinimapButton:LockHighlight();
    PetParty_MinimapButton_DraggingFrame:Show();
end

-- Called when the minimap button is stopped dragging.
function PetParty.OnDragStopMinimapButton()
    PetParty_MinimapButton:UnlockHighlight();
    PetParty_MinimapButton_DraggingFrame:Hide();
end

-- Called when the mouse enters the minimap button.
function PetParty.OnEnterMinimapButton()
    PetParty_MinimapButton_Tooltip:ClearLines();
    PetParty_MinimapButton_Tooltip:SetOwner(PetParty_MinimapButton_Tooltip:GetParent(), "ANCHOR_LEFT");
    PetParty_MinimapButton_Tooltip:SetBackdropColor(TOOLTIP_BACKGROUND_R, TOOLTIP_BACKGROUND_G, TOOLTIP_BACKGROUND_B);
    PetParty_MinimapButton_Tooltip:AddLine(PetParty.L["Pet Party"],
                                           TOOLTIP_TITLE_R,
                                           TOOLTIP_TITLE_G,
                                           TOOLTIP_TITLE_B);
    PetParty_MinimapButton_Tooltip:AddLine(PetParty.L["Creates groups of pets for the pet battle system."],
                                           TOOLTIP_DESCRIPTION_R,
                                           TOOLTIP_DESCRIPTION_G,
                                           TOOLTIP_DESCRIPTION_B);
    PetParty_MinimapButton_Tooltip:Show();
end

-- Called when the minimap button receives an event.
function PetParty.OnEventMinimapButton(self, event, arg1, ...)
    if (event == "ADDON_LOADED") and (arg1 == PetParty.ADDON_NAME) then
        if (PetPartyCharacterDB ~= nil) then
            if (PetPartyCharacterDB.icon_position == nil) then
                PetPartyCharacterDB.icon_position = ICON_POSITION;
            end
        end
    elseif (event == "PLAYER_ENTERING_WORLD") then
        PetParty.OnRepositionMinimapButton();
    end
end

-- Called when the mouse leaves the minimap button.
function PetParty.OnLeaveMinimapButton()
    PetParty_MinimapButton_Tooltip:Hide();
end

-- Called when the minimap button is loaded.
function PetParty.OnLoadMinimapButton()
    -- Register the minimap button for events.
    PetParty_MinimapButton:RegisterEvent("ADDON_LOADED");
    PetParty_MinimapButton:RegisterEvent("PLAYER_ENTERING_WORLD");
    PetParty_MinimapButton:RegisterForClicks("LeftButtonUp");
    PetParty_MinimapButton:RegisterForDrag("RightButton");
    
    -- Set the minimap button's scripts.
    PetParty_MinimapButton:SetScript("OnEvent", PetParty.OnEventMinimapButton);
end

-- Repositions the minimap button.
function PetParty.OnRepositionMinimapButton()
    PetParty_MinimapButton:SetPoint("TOPLEFT",
                                    "Minimap",
                                    "TOPLEFT",
                                    ICON_OFFSET_X - (ICON_OFFSET_Y * cos(PetPartyCharacterDB.icon_position)),
                                    (ICON_OFFSET_Y * sin(PetPartyCharacterDB.icon_position)) - ICON_OFFSET_X);
end

-- Called when the dragging frame is updated.
function PetParty.OnUpdateMinimapButtonDraggingFrame()
    local x_pos, y_pos = GetCursorPosition();
    local x_min, y_min = Minimap:GetLeft(), Minimap:GetBottom();
    
    x_pos = x_min - x_pos / UIParent:GetScale() + ICON_OFFSET;
    y_pos = y_pos / UIParent:GetScale() - y_min - ICON_OFFSET;
    
    PetPartyCharacterDB.icon_position = math.deg(math.atan2(y_pos, x_pos));
    
    PetParty.OnRepositionMinimapButton();
end
