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

-- Pet Party US English localization.
PetParty.L_enUS = {};

-- The translation function.
function PetParty.translate_enUS(L, key)
    -- For US English, just return the key.
    return key;
end

-- Update the metatable.
setmetatable(PetParty.L_enUS, {__index=PetParty.translate_enUS});
