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

local PET_PARTY_FRAME_PET_FRAME_HEIGHT = PetParty.PET_PARTY_FRAME_HEIGHT / PetParty.PETS_PER_PARTY;

local PET_PARTY_FRAME_R = 0;
local PET_PARTY_FRAME_G = 0;
local PET_PARTY_FRAME_B = 0;
local PET_PARTY_FRAME_A = 0;

local PET_PARTY_FRAME_PET_FRAME_R = 0.2;
local PET_PARTY_FRAME_PET_FRAME_G = 0.2;
local PET_PARTY_FRAME_PET_FRAME_B = 0.2;
local PET_PARTY_FRAME_PET_FRAME_A = 0.5;

local PET_FRAME_FONT = "Fonts\\FRIZQT__.TTF";
local PET_FRAME_FONT_SIZE = 18;

local PET_FRAME_TITLE_R = 1;
local PET_FRAME_TITLE_G = 1;
local PET_FRAME_TITLE_B = 1;
local PET_FRAME_TITLE_A = 1;

-- Called when the pet party frame is loaded.
function PetParty.OnLoadPetPartyFrame()
    -- Configure the pet party frame.
    PetParty_PetPartyFrame:ClearAllPoints();
    PetParty_PetPartyFrame:SetPoint("LEFT", PetParty_BattlePetScrollFrame, "RIGHT", PADDING, 0);
    PetParty_PetPartyFrame:SetPoint("RIGHT", PetParty_PetPartyScrollFrame);
    PetParty_PetPartyFrame:SetPoint("TOP", PetParty_PetPartyScrollFrame, "BOTTOM", 0, -PADDING);
    PetParty_PetPartyFrame:SetPoint("BOTTOM", PetParty_MainFrame, "BOTTOM", 0, (-PetParty.MAIN_FRAME_OFFSET_Y) + PADDING);
    
    -- Configure the pet party frame's background texture.
    local texture = PetParty_PetPartyFrame:CreateTexture();
    texture:SetAllPoints();
    texture:SetTexture(PET_PARTY_FRAME_R,
                       PET_PARTY_FRAME_G,
                       PET_PARTY_FRAME_B,
                       PET_PARTY_FRAME_A);
    
    -- Initialize the pet party frame's pet frames variable.
    PetParty_PetPartyFrame.pet_frames = {};
    
    --
    -- Configure the pet party frame's pet frames.
    --
    
    --
    -- Pet frame one.
    --
    
    local pet_frame = CreateFrame("Frame", nil, PetParty_PetPartyFrame);
    pet_frame:ClearAllPoints();
    pet_frame:SetPoint("TOPLEFT", PetParty_PetPartyFrame);
    pet_frame:SetPoint("RIGHT", PetParty_PetPartyFrame);
    pet_frame:SetHeight(PET_PARTY_FRAME_PET_FRAME_HEIGHT);
    
    texture = pet_frame:CreateTexture();
    texture:SetAllPoints();
    texture:SetTexture(PET_PARTY_FRAME_PET_FRAME_R,
                       PET_PARTY_FRAME_PET_FRAME_G,
                       PET_PARTY_FRAME_PET_FRAME_B,
                       PET_PARTY_FRAME_PET_FRAME_A);
    
    pet_frame.font_string_title = pet_frame:CreateFontString();
    pet_frame.font_string_title:SetFont(PET_FRAME_FONT, PET_FRAME_FONT_SIZE);
    pet_frame.font_string_title:SetText("Hello World!");
    pet_frame.font_string_title:SetTextColor(PET_FRAME_TITLE_R,
                                             PET_FRAME_TITLE_G,
                                             PET_FRAME_TITLE_B,
                                             PET_FRAME_TITLE_A);
    pet_frame.font_string_title:ClearAllPoints();
    pet_frame.font_string_title:SetPoint("CENTER", pet_frame);
    
    PetParty_PetPartyFrame.pet_frames[0] = pet_frame;
    
    --
    -- Pet frame two.
    --
    
    pet_frame = CreateFrame("Frame", nil, PetParty_PetPartyFrame);
    pet_frame:ClearAllPoints();
    pet_frame:SetPoint("TOPLEFT", PetParty_PetPartyFrame.pet_frames[0], "BOTTOMLEFT");
    pet_frame:SetPoint("RIGHT", PetParty_PetPartyFrame);
    pet_frame:SetHeight(PET_PARTY_FRAME_PET_FRAME_HEIGHT);
    
    texture = pet_frame:CreateTexture();
    texture:SetAllPoints();
    texture:SetTexture(PET_PARTY_FRAME_PET_FRAME_R,
                       PET_PARTY_FRAME_PET_FRAME_G,
                       PET_PARTY_FRAME_PET_FRAME_B,
                       PET_PARTY_FRAME_PET_FRAME_A);
    
    pet_frame.font_string_title = pet_frame:CreateFontString();
    pet_frame.font_string_title:SetFont(PET_FRAME_FONT, PET_FRAME_FONT_SIZE);
    pet_frame.font_string_title:SetText("Hello World!");
    pet_frame.font_string_title:SetTextColor(PET_FRAME_TITLE_R,
                                             PET_FRAME_TITLE_G,
                                             PET_FRAME_TITLE_B,
                                             PET_FRAME_TITLE_A);
    pet_frame.font_string_title:ClearAllPoints();
    pet_frame.font_string_title:SetPoint("CENTER", pet_frame);
    
    PetParty_PetPartyFrame.pet_frames[1] = pet_frame;
    
    -- Pet frame three.
    pet_frame = CreateFrame("Frame", nil, PetParty_PetPartyFrame);
    pet_frame:ClearAllPoints();
    pet_frame:SetPoint("TOPLEFT", PetParty_PetPartyFrame.pet_frames[1], "BOTTOMLEFT");
    pet_frame:SetPoint("BOTTOMRIGHT", PetParty_PetPartyFrame);
    
    texture = pet_frame:CreateTexture();
    texture:SetAllPoints();
    texture:SetTexture(PET_PARTY_FRAME_PET_FRAME_R,
                       PET_PARTY_FRAME_PET_FRAME_G,
                       PET_PARTY_FRAME_PET_FRAME_B,
                       PET_PARTY_FRAME_PET_FRAME_A);
    
    pet_frame.font_string_title = pet_frame:CreateFontString();
    pet_frame.font_string_title:SetFont(PET_FRAME_FONT, PET_FRAME_FONT_SIZE);
    pet_frame.font_string_title:SetText("Hello World!");
    pet_frame.font_string_title:SetTextColor(PET_FRAME_TITLE_R,
                                             PET_FRAME_TITLE_G,
                                             PET_FRAME_TITLE_B,
                                             PET_FRAME_TITLE_A);
    pet_frame.font_string_title:ClearAllPoints();
    pet_frame.font_string_title:SetPoint("CENTER", pet_frame);
    
    PetParty_PetPartyFrame.pet_frames[2] = pet_frame;
end
