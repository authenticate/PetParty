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

-- Called when the main frame starts dragging.
function PetParty.OnDragStartMainFrame()
    PetParty_MainFrame:StartMoving();
end

-- Called when the main frame stops dragging.
function PetParty.OnDragStopMainFrame()
    PetParty_MainFrame:StopMovingOrSizing();
end

-- Called when the main frame receives an event.
function PetParty.OnEventMainFrame(event)
    if (event == "ADDON_LOADED") then
        if (PetPartyCharacterDB ~= nil) then
            if (PetPartyCharacterDB.main_frame_hidden ~= nil) then
                if (PetPartyCharacterDB.main_frame_hidden) then
                    PetParty_MainFrame:Hide();
                else
                    PetParty_MainFrame:Show();
                end
            end
        end
    elseif (event == "PLAYER_LOGOUT") then
        PetPartyCharacterDB.main_frame_hidden = not PetParty_MainFrame:IsShown();
    end
end

-- Called when the main frame loads.
function PetParty.OnLoadMainFrame()
    PetParty_MainFrame:SetClampedToScreen(true);
    PetParty_MainFrame:SetUserPlaced(true);
    
    PetParty_MainFrame:RegisterEvent("ADDON_LOADED");
    PetParty_MainFrame:RegisterEvent("PLAYER_LOGOUT");
    PetParty_MainFrame:RegisterForDrag("LeftButton");
    
    PetParty.CreateContentAndScrollFrames();
end

-- Called when the main frame is shown.
function PetParty.OnShowMainFrame()
    PetParty_MainFrame_Title_Font_String:SetText(PetParty.L["Pet Party"]);
    PetParty_MainFrame_Button_Close:SetText(PetParty.L["Close"]);
end
