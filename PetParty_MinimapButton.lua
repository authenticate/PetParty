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

-- Constants.
local ICON_OFFSET = 70;
local ICON_OFFSET_X = 52;
local ICON_OFFSET_Y = 80;

-- The icon position.
local icon_position = 45;

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

-- Called when the minimap button is loaded.
function PetParty.OnLoadMinimapButton()
    PetParty_MinimapButton:RegisterForClicks("LeftButtonUp");
    PetParty_MinimapButton:RegisterForDrag("LeftButton");
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

-- Repositions the minimap button.
function PetParty.OnRepositionMinimapButton()
    PetParty_MinimapButton:SetPoint("TOPLEFT",
                                    "Minimap",
                                    "TOPLEFT",
                                    ICON_OFFSET_X - (ICON_OFFSET_Y * cos(icon_position)),
                                    (ICON_OFFSET_Y * sin(icon_position)) - ICON_OFFSET_X);
end

-- Called when the dragging frame is updated.
function PetParty.OnUpdateMinimapButtonDraggingFrame()
    local x_pos, y_pos = GetCursorPosition();
    local x_min, y_min = Minimap:GetLeft(), Minimap:GetBottom();
    
    x_pos = x_min - x_pos / UIParent:GetScale() + ICON_OFFSET;
    y_pos = y_pos / UIParent:GetScale() - y_min - ICON_OFFSET;
    
    icon_position = math.deg(math.atan2(y_pos, x_pos));
    PetParty.OnRepositionMinimapButton();
end
