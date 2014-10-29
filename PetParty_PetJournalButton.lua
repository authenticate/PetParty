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

local BUTTON_OFFSET_X = -49;
local BUTTON_OFFSET_Y = 2;

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

-- Called when the pet journal button is clicked.
function PetParty.OnClickPetJournalButton(button, down)
    if (button == "LeftButton") and (not down) then
        if (PetParty_MainFrame:IsShown()) then
            PetParty_MainFrame:Hide();
        else
            PetParty_MainFrame:Show();
        end
    end
end

-- Called when the mouse enters the pet journal button.
function PetParty.OnEnterPetJournalButton()
    PetParty_PetJournalButton_Tooltip:ClearLines();
    PetParty_PetJournalButton_Tooltip:SetOwner(PetParty_PetJournalButton_Tooltip:GetParent(), "ANCHOR_RIGHT");
    PetParty_PetJournalButton_Tooltip:SetBackdropColor(TOOLTIP_BACKGROUND_R, TOOLTIP_BACKGROUND_G, TOOLTIP_BACKGROUND_B);
    PetParty_PetJournalButton_Tooltip:AddLine(PetParty.L["Pet Party"],
                                              TOOLTIP_TITLE_R,
                                              TOOLTIP_TITLE_G,
                                              TOOLTIP_TITLE_B);
    PetParty_PetJournalButton_Tooltip:AddLine(PetParty.L["Creates groups of pets for the pet battle system."],
                                              TOOLTIP_DESCRIPTION_R,
                                              TOOLTIP_DESCRIPTION_G,
                                              TOOLTIP_DESCRIPTION_B);
    PetParty_PetJournalButton_Tooltip:Show();
end

-- Called when the pet journal button receives an event.
function PetParty.OnEventPetJournalButton(self, event, arg1, ...)
    if (event == "ADDON_LOADED") and (arg1 == "Blizzard_PetJournal") then
        -- Anchor the pet journal button to Blizzard's pet journal.
        PetParty_PetJournalButton:SetParent(PetJournal);
        PetParty_PetJournalButton:ClearAllPoints();
        PetParty_PetJournalButton:SetPoint("TOPLEFT", PetJournal, "TOPRIGHT", BUTTON_OFFSET_X, BUTTON_OFFSET_Y);
    end
end

-- Called when the mouse leaves the pet journal button.
function PetParty.OnLeavePetJournalButton()
    PetParty_PetJournalButton_Tooltip:Hide();
end

-- Called when the pet journal button is loaded.
function PetParty.OnLoadPetJournalButton()
    -- Register the pet journal button for events.
    PetParty_PetJournalButton:RegisterEvent("ADDON_LOADED");
    PetParty_PetJournalButton:RegisterForClicks("LeftButtonUp");
    
    -- Set the pet journal button's scripts.
    PetParty_PetJournalButton:SetScript("OnEvent", PetParty.OnEventPetJournalButton);
end
