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

--
-- Static Popup Definitions.
--

StaticPopupDialogs[PetParty.STRING_DIALOG_NAME_ERROR_BATTLE_PET_TRAINING] = {
    text = PetParty.L[PetParty.STRING_DIALOG_TITLE_ERROR_BATTLE_PET_TRAINING],
    button1 = PetParty.L[PetParty.STRING_BUTTON_OK],
    exclusive = true,
    hasEditBox = false,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3,
};

StaticPopupDialogs[PetParty.STRING_DIALOG_NAME_CREATE_PET_PARTY] = {
    text = PetParty.L[PetParty.STRING_DIALOG_TITLE_CREATE_PET_PARTY],
    button1 = PetParty.L[PetParty.STRING_BUTTON_CREATE],
    button2 = PetParty.L[PetParty.STRING_BUTTON_CANCEL],
    OnAccept =
        function (self)
            local text = self.editBox:GetText();
            if (text ~= nil) and (text ~= "") then
                -- Create a pet party frame.
                PetParty.AddPetPartyFrame(text);
                
                -- Store the pet parties.
                PetParty.SerializePetParties();
            end
        end
    ,
    OnShow =
        function (self, data)
            self.editBox:SetText("");
            self.button1:Disable();
        end
    ,
    EditBoxOnTextChanged =
        function (self)
            local text = self:GetText();
            if (text ~= nil) and (text ~= "") then
                self:GetParent().button1:Enable();
            else
                self:GetParent().button1:Disable();
            end
        end
    ,
    EditBoxOnEnterPressed =
        function (self)
            if (self:GetParent().button1:IsEnabled()) then
                self:GetParent().button1:Click("LeftButton", false);
            end
        end
    ,
    EditBoxOnEscapePressed =
        function (self)
            self:GetParent():Hide();
        end
    ,
    exclusive = true,
    hasEditBox = true,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3,
};

StaticPopupDialogs[PetParty.STRING_DIALOG_NAME_RENAME_PET_PARTY] = {
    text = PetParty.L[PetParty.STRING_DIALOG_TITLE_RENAME_PET_PARTY],
    button1 = PetParty.L[PetParty.STRING_BUTTON_RENAME],
    button2 = PetParty.L[PetParty.STRING_BUTTON_CANCEL],
    OnAccept =
        function (self)
            local text = self.editBox:GetText();
            if (text ~= nil) and (text ~= "") then
                if (PetParty.pet_party_frame_selected ~= nil) then
                    -- Rename the pet party.
                    PetParty.pet_party_frame_selected:SetText(text);
                    PetParty.SerializePetParties();
                end
            end
        end
    ,
    OnShow =
        function (self, data)
            if (PetParty.pet_party_frame_selected ~= nil) then
                local text = PetParty.pet_party_frame_selected:GetText();
                self.editBox:SetText(text);
                self.button1:Disable();
            else
                self:Hide();
            end
        end
    ,
    EditBoxOnTextChanged =
        function (self)
            self:GetParent().button1:Disable();
            
            local text = self:GetText();
            if (text ~= nil) and (text ~= "") then
                if (PetParty.pet_party_frame_selected ~= nil) then
                    local text_current = PetParty.pet_party_frame_selected:GetText();
                    if (text ~= text_current) then
                        self:GetParent().button1:Enable();
                    end
                end
            end
        end
    ,
    EditBoxOnEnterPressed =
        function (self)
            if (self:GetParent().button1:IsEnabled()) then
                self:GetParent().button1:Click("LeftButton", false);
            end
        end
    ,
    EditBoxOnEscapePressed =
        function (self)
            self:GetParent():Hide();
        end
    ,
    exclusive = true,
    hasEditBox = true,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3,
};

--
-- Helper functions.
--

-- Call to hide all pop-ups.
function PetParty.HidePopups()
    StaticPopup_Hide(PetParty.STRING_DIALOG_NAME_CREATE_PET_PARTY);
    StaticPopup_Hide(PetParty.STRING_DIALOG_NAME_RENAME_PET_PARTY);
end

-- Call to determine if the player's account has Battle Pet Training unlocked.
function PetParty.IsBattlePetTrainingUnlocked()
    local petID, petSpellID_slot1, petSpellID_slot2, petSpellID_slot3, locked = C_PetJournal.GetPetLoadOutInfo(1);
    return not locked;
end
