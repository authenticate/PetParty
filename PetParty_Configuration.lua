--
-- Pet Party
-- Copyright 2014 - 2016 James Lammlein
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
PetParty.ADDON_VERSION = "7.0.3";

PetParty.ART_FILE_NAME = "Interface\\AddOns\\PetParty\\PetParty_Art.tga";

PetParty.ART_FRAME_HIGHLIGHT_LEFT = 0.0;
PetParty.ART_FRAME_HIGHLIGHT_RIGHT = 1.0;
PetParty.ART_FRAME_HIGHLIGHT_TOP = 0.0;
PetParty.ART_FRAME_HIGHLIGHT_BOTTOM = 0.0546875;

PetParty.ART_FRAME_PUSHED_LEFT = 0.0;
PetParty.ART_FRAME_PUSHED_RIGHT = 1.0;
PetParty.ART_FRAME_PUSHED_TOP = 0.0625;
PetParty.ART_FRAME_PUSHED_BOTTOM = 0.1171875;

PetParty.ABILITY_GROUPS_PER_PET = 3;
PetParty.ABILITIES_PER_ABILITY_GROUP = 2;
PetParty.PETS_PER_PARTY = 3;

PetParty.PADDING = 2;

PetParty.BUTTON_WIDTH = 22;
PetParty.BUTTON_HEIGHT = 22;

PetParty.EDIT_BOX_WIDTH = 174;
PetParty.EDIT_BOX_HEIGHT = 32;

PetParty.FONT_STRING_HEIGHT = 18;
PetParty.FONT_STRING_PADDING = 4;

PetParty.MAIN_FRAME_WIDTH = 400;
PetParty.MAIN_FRAME_OFFSET_LEFT = 14;
PetParty.MAIN_FRAME_OFFSET_RIGHT = -14;
PetParty.MAIN_FRAME_OFFSET_TOP = -34;
PetParty.MAIN_FRAME_OFFSET_BOTTOM = 14;

PetParty.PET_INFORMATION_FONT_STRING_OFFSET_Y = 12;
PetParty.PET_INFORMATION_FRAME_HEIGHT = 175;
PetParty.PET_INFORMATION_FRAME_PADDING = 2;

PetParty.STRING_BUTTON_ACTIVATE = "Activate";
PetParty.STRING_BUTTON_ACTIVATE_TOOLTIP = "Loads the configuration into the Battle Pet Slots.";

PetParty.STRING_BUTTON_CANCEL = "Cancel";

PetParty.STRING_BUTTON_CREATE = "Create";
PetParty.STRING_BUTTON_CREATE_TOOLTIP = "Creates a new Pet Party.";

PetParty.STRING_BUTTON_RENAME = "Rename";
PetParty.STRING_BUTTON_RENAME_TOOLTIP = "Renames the currently selected Pet Party.";

PetParty.STRING_BUTTON_DELETE = "Delete";
PetParty.STRING_BUTTON_DELETE_TOOLTIP = "Deletes the currently selected Pet Party.";

PetParty.STRING_BUTTON_HIDE_TOOLTIP = "Hides the Pet Party frame.";

PetParty.STRING_BUTTON_JOURNAL_TOOLTIP = "Creates groups of pets for the pet battle system.";

PetParty.STRING_BUTTON_SAVE = "Save";
PetParty.STRING_BUTTON_SAVE_TOOLTIP = "Stores the configuration into the currently selected Pet Party.";

PetParty.STRING_DIALOG_NAME_CREATE_PET_PARTY = "PetParty_CreatePetPartyDialog";
PetParty.STRING_DIALOG_TITLE_CREATE_PET_PARTY = "Create a pet party.";

PetParty.STRING_DIALOG_NAME_RENAME_PET_PARTY = "PetParty_RenamePetPartyDialog";
PetParty.STRING_DIALOG_TITLE_RENAME_PET_PARTY = "Rename the pet party.";

PetParty.STRING_BATTLE_PETS_SLOTS_CONFIGURATION = "Battle Pet Slots' Configuration";
PetParty.STRING_DRAG = "Drag a battle pet here.";
PetParty.STRING_DRAG_BATTLE = "Drag a battle pet to train here.";
PetParty.STRING_PET_PARTY = "Pet Party";
PetParty.STRING_PET_PARTIES = "Pet Parties";
PetParty.STRING_TRAINING_PET = "Training Pet";

PetParty.TRAINING_PET_INFORMATION_FRAME_HEIGHT = 40;

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
