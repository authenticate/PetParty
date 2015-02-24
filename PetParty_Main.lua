--
-- Pet Party
-- Copyright 2014 - 2015 James Lammlein
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
-- Globals.
--

-- Pet Party localization.  Use US English as the default localization.
PetParty.L = PetParty.L_enUS;

-- A flag if the pet parties have been deserialized.
PetParty.are_pet_parties_deserialized = false;

-- A flag if the training pet has been deserialized.
PetParty.is_training_pet_deserialized = false;

-- The currently selected pet party frame.
PetParty.pet_party_frame_selected = nil;

-- A flag if a pet information frame is the cursor.
PetParty.pet_information_frame_cursor = nil;

-- A flag if the training pet is the cursor.
PetParty.training_pet_cursor = false;
