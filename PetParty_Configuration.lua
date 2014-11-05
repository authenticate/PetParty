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

-- Pet Party table.
PetParty = {};

--
-- Constants.
--

PetParty.ADDON_NAME = "PetParty";
PetParty.ADDON_VERSION = "1.2";

PetParty.ABILITY_GROUPS_PER_PET = 3;
PetParty.ABILITIES_PER_ABILITY_GROUP = 2;
PetParty.PETS_PER_PARTY = 3;

PetParty.PADDING = 2;

PetParty.BUTTON_WIDTH = 22;
PetParty.BUTTON_HEIGHT = 22;

PetParty.FONT_STRING_HEIGHT = 18;
PetParty.FONT_STRING_PADDING = 4;

PetParty.MAIN_FRAME_WIDTH = 400;
PetParty.MAIN_FRAME_OFFSET_LEFT = 14;
PetParty.MAIN_FRAME_OFFSET_RIGHT = -14;
PetParty.MAIN_FRAME_OFFSET_TOP = -34;
PetParty.MAIN_FRAME_OFFSET_BOTTOM = 14;

PetParty.PET_INFORMATION_FONT_STRING_OFFSET_Y = 12;
PetParty.PET_INFORMATION_PARTY_FRAME_HEIGHT = 175;

PetParty.TRAINING_PET_INFORMATION_FRAME_HEIGHT = 42;

-- TODO: This color is inconsistent with Blizzard's default tooltips.  Does anyone know the correct color?
PetParty.TOOLTIP_BACKGROUND_R = 0;
PetParty.TOOLTIP_BACKGROUND_G = 0;
PetParty.TOOLTIP_BACKGROUND_B = 0;

PetParty.TOOLTIP_TITLE_R = 1;
PetParty.TOOLTIP_TITLE_G = 1;
PetParty.TOOLTIP_TITLE_B = 1;

-- TODO: This color is inconsistent with Blizzard's default tooltips.  Does anyone know the correct color?
PetParty.TOOLTIP_DESCRIPTION_R = 1;
PetParty.TOOLTIP_DESCRIPTION_G = 210 / 255;
PetParty.TOOLTIP_DESCRIPTION_B = 0;
