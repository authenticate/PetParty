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

local PET_PARTY_FRAME_R = 0;
local PET_PARTY_FRAME_G = 1;
local PET_PARTY_FRAME_B = 0;
local PET_PARTY_FRAME_A = 0.5;

-- Called when the pet party frame is loaded.
function PetParty.OnLoadPetPartyFrame()
    PetParty_PetPartyFrame:ClearAllPoints();
    PetParty_PetPartyFrame:SetPoint("LEFT", PetParty_BattlePetScrollFrame, "RIGHT", PADDING, 0);
    PetParty_PetPartyFrame:SetPoint("RIGHT", PetParty_PetPartyScrollFrame);
    PetParty_PetPartyFrame:SetPoint("TOP", PetParty_PetPartyScrollFrame, "BOTTOM", 0, -PADDING);
    PetParty_PetPartyFrame:SetPoint("BOTTOM", PetParty_MainFrame, "BOTTOM", 0, (-PetParty.MAIN_FRAME_OFFSET_Y) + PADDING);
    
    local texture = PetParty_PetPartyFrame:CreateTexture();
    texture:SetAllPoints();
    texture:SetTexture(PET_PARTY_FRAME_R,
                       PET_PARTY_FRAME_G,
                       PET_PARTY_FRAME_B,
                       PET_PARTY_FRAME_A);
end
