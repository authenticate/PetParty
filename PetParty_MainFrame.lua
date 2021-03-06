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
-- Constants.
--

local PET_PARTY_BUTTON_COUNT = 3;

-- Called when the main frame's create pet party button is clicked.
function PetParty.OnClickMainFrameButtonCreatePetParty()
    PetParty.HidePopups();
    StaticPopup_Show(PetParty.STRING_DIALOG_NAME_CREATE_PET_PARTY);
end

-- Called when the main frame's rename pet party button is clicked.
function PetParty.OnClickMainFrameButtonRenamePetParty()
    PetParty.HidePopups();
    
    -- If there's a selected pet party frame...
    if (PetParty.pet_party_frame_selected ~= nil) then
        StaticPopup_Show(PetParty.STRING_DIALOG_NAME_RENAME_PET_PARTY);
    end
end

-- Called when the main frame's delete pet party button is clicked.
function PetParty.OnClickMainFrameButtonDeletePetParty()
    PetParty.HidePopups();
    
    -- Delete the selected pet party frame.
    PetParty.DeletePetPartyFrame();
    
    -- If there's a selected pet party frame...
    if (PetParty.pet_party_frame_selected ~= nil) then
        -- Simulate the selected pet party frame being selected.
        PetParty.OnClickPetPartyFrame(PetParty.pet_party_frame_selected, "LeftButton", false);
    end
    
    PetParty.SerializePetParties();
end

-- Called when the main frame receives an event.
function PetParty.OnEventMainFrame(self, event, arg1, ...)
    if (event == "ADDON_LOADED") and (arg1 == "Blizzard_Collections") then
        -- Initialize the battle pet frame variables.
        if (PetParty_PetPartyContentFrame.content == nil) then
            PetParty_PetPartyContentFrame.content = {};
            PetParty_PetPartyContentFrame.content.frames = {};
            PetParty_PetPartyContentFrame.content.frame_count = 0;
            PetParty_PetPartyContentFrame.content.frame_count_allocated = 0;
        end
        
        -- Anchor the main frame to Blizzard's pet journal.
        PetParty_MainFrame:SetParent(PetJournal);
        PetParty_MainFrame:ClearAllPoints();
        PetParty_MainFrame:SetPoint("TOPLEFT", PetJournal, "TOPRIGHT");
        PetParty_MainFrame:SetPoint("BOTTOM", PetJournal);
        PetParty_MainFrame:SetWidth(PetParty.MAIN_FRAME_WIDTH);
        
        -- Update the main frame.
        if (PetPartyCharacterDB ~= nil) then
            if (PetPartyCharacterDB.main_frame_hidden ~= nil) then
                if (PetPartyCharacterDB.main_frame_hidden) then
                    PetParty_MainFrame:Hide();
                else
                    PetParty_MainFrame:Show();
                end
            end
        end
        
        -- Update the layout.
        PetParty.UpdateMainFrameLayout();
    elseif (event == "PET_JOURNAL_LIST_UPDATE") then
        -- Update the training pet frame's information.
        PetParty.UpdateTrainingPetInformationFrame();
        
        -- Update all pet frames' information.
        for i = 1, PetParty.PETS_PER_PARTY do
            PetParty.UpdatePetInformationPetInformationFrame(i);
        end
    elseif (event == "PLAYER_LOGOUT") then
        if (PetPartyCharacterDB == nil) then
            PetPartyCharacterDB = {};
        end
        
        -- Serialize whether or not the main frame is hidden.
        PetPartyCharacterDB.main_frame_hidden = not PetParty_MainFrame:IsShown();
        
        -- If the pet parties have not been deserialized...
        if (not PetParty.are_pet_parties_deserialized) then
            PetParty.DeserializePetParties();
            PetParty.are_pet_parties_deserialized = true;
        end
        
        PetParty.SerializePetParties()
    end
end

-- Called when the main frame is hidden.
function PetParty.OnHideMainFrame()
    PetParty.HidePopups();
end

-- Called when the main frame is loaded.
function PetParty.OnLoadMainFrame()
    -- Register the main frame for events.
    PetParty_MainFrame:RegisterEvent("ADDON_LOADED");
    PetParty_MainFrame:RegisterEvent("PET_JOURNAL_LIST_UPDATE");
    PetParty_MainFrame:RegisterEvent("PLAYER_ENTERING_WORLD");
    PetParty_MainFrame:RegisterEvent("PLAYER_LOGOUT");
    
    -- Set the main frame's scripts.
    PetParty_MainFrame:SetScript("OnEvent", PetParty.OnEventMainFrame);
    
    -- Create the pet party scroll frame.
    PetParty.CreatePetPartyContentAndScrollFrames();
    
    -- Localize the UI.
    PetParty_MainFrame_Font_String_Title:SetText(PetParty.L[PetParty.STRING_PET_PARTY] .. " - " .. PetParty.L[PetParty.ADDON_VERSION]);
    PetParty_MainFrame_Font_String_Training_Pet:SetText(PetParty.L[PetParty.STRING_TRAINING_PET]);
    PetParty_MainFrame_Font_String_Pet_Parties:SetText(PetParty.L[PetParty.STRING_PET_PARTIES]);
    PetParty_MainFrame_Button_Create_Pet_Party:SetText(PetParty.L[PetParty.STRING_BUTTON_CREATE]);
    PetParty_MainFrame_Button_Rename_Pet_Party:SetText(PetParty.L[PetParty.STRING_BUTTON_RENAME]);
    PetParty_MainFrame_Button_Delete_Pet_Party:SetText(PetParty.L[PetParty.STRING_BUTTON_DELETE]);
end

-- Called when the main frame is shown.
function PetParty.OnShowMainFrame()
    -- If the pet parties have not been deserialized...
    if (not PetParty.are_pet_parties_deserialized) then
        -- Deserialize the pet parties.
        PetParty.DeserializePetParties();
        
        -- Update the flag.
        PetParty.are_pet_parties_deserialized = true;
        
        -- Sanity.
        if (PetParty.pet_party_frame_selected ~= nil) then
            -- Select an initial pet party.
            pet_party_frame_entered = PetParty.pet_party_frame_selected;
            pet_party_frame_pressed = PetParty.pet_party_frame_selected;
            
            PetParty.OnClickPetPartyFrame(PetParty.pet_party_frame_selected, "LeftButton", false);
            
            pet_party_frame_entered = nil;
            pet_party_frame_pressed = nil;
        end
    end
    
    -- Update all pet frames' information.
    for i = 1, PetParty.PETS_PER_PARTY do
        PetParty.UpdatePetInformationPetInformationFrame(i);
    end
end

-- Called when the main frame's search edit box's text is changed.
function PetParty.OnTextChangedMainFrameEditBoxSearch()
    -- Update the pet party content frames.
    PetParty.UpdatePetPartyContentFrames();
    
    -- Call the base class function.
    SearchBoxTemplate_OnTextChanged(PetParty_MainFrame_Edit_Box_Search);
end

-- Call to update the main frame layout.
function PetParty.UpdateMainFrameLayout()
    -- Calculate the width of all the pet party buttons.
    local button_width = PetParty_MainFrame_Button_Create_Pet_Party:GetWidth() +
                         PetParty_MainFrame_Button_Rename_Pet_Party:GetWidth() +
                         PetParty_MainFrame_Button_Delete_Pet_Party:GetWidth();
    
    -- Starting location.
    local start_x = PetParty.MAIN_FRAME_OFFSET_LEFT;
    local start_y = PetParty.MAIN_FRAME_OFFSET_TOP;
    
    -- Update the position of the training pet label.
    PetParty_MainFrame_Font_String_Training_Pet:ClearAllPoints();
    PetParty_MainFrame_Font_String_Training_Pet:SetPoint("TOPLEFT", start_x, start_y);
    PetParty_MainFrame_Font_String_Training_Pet:SetPoint("RIGHT", PetParty.MAIN_FRAME_OFFSET_RIGHT, 0);
    PetParty_MainFrame_Font_String_Training_Pet:SetHeight(PetParty.FONT_STRING_HEIGHT);
    
    -- Update the starting location.
    start_y = start_y - PetParty.FONT_STRING_HEIGHT;
    
    -- Update the position of the training pet frame.
    PetParty_TrainingPetInformationFrame:ClearAllPoints();
    PetParty_TrainingPetInformationFrame:SetPoint("LEFT", PetParty_MainFrame, PetParty.MAIN_FRAME_OFFSET_LEFT, 0);
    PetParty_TrainingPetInformationFrame:SetPoint("RIGHT", PetParty_MainFrame, PetParty.MAIN_FRAME_OFFSET_RIGHT, 0);
    PetParty_TrainingPetInformationFrame:SetPoint("TOP", PetParty_MainFrame, "TOP", 0, start_y);
    PetParty_TrainingPetInformationFrame:SetHeight(PetParty.TRAINING_PET_INFORMATION_FRAME_HEIGHT);
    
    -- Update the starting location.
    start_y = start_y -
              PetParty.TRAINING_PET_INFORMATION_FRAME_HEIGHT -
              PetParty.PET_INFORMATION_FRAME_HEIGHT +
              PetParty.PADDING;
    
    -- Update the position of the pet parties label.
    PetParty_MainFrame_Font_String_Pet_Parties:ClearAllPoints();
    PetParty_MainFrame_Font_String_Pet_Parties:SetPoint("TOPLEFT", start_x, start_y);
    PetParty_MainFrame_Font_String_Pet_Parties:SetPoint("RIGHT", PetParty.MAIN_FRAME_OFFSET_RIGHT, 0);
    PetParty_MainFrame_Font_String_Pet_Parties:SetHeight(PetParty.FONT_STRING_HEIGHT);
    
    -- Update the starting location.
    start_y = start_y - PetParty.FONT_STRING_HEIGHT;
    
    -- Calculate the offsets.
    local offset_x = (PetParty_MainFrame:GetWidth() - PetParty.MAIN_FRAME_OFFSET_LEFT + PetParty.MAIN_FRAME_OFFSET_RIGHT - button_width ) /
                     (PET_PARTY_BUTTON_COUNT + 1);
    local offset_y = -PetParty.PADDING;
    
    -- Calculate the final position.
    local final_x = start_x + offset_x;
    local final_y = start_y + offset_y;
    
    -- Update the position of the create pet party button.
    PetParty_MainFrame_Button_Create_Pet_Party:ClearAllPoints();
    PetParty_MainFrame_Button_Create_Pet_Party:SetPoint("TOPLEFT", final_x, final_y);
    
    -- Update the final position.
    final_x = final_x + PetParty_MainFrame_Button_Create_Pet_Party:GetWidth() + offset_x;
    
    -- Update the position of the rename pet party button.
    PetParty_MainFrame_Button_Rename_Pet_Party:ClearAllPoints();
    PetParty_MainFrame_Button_Rename_Pet_Party:SetPoint("TOPLEFT", final_x, final_y);
    
    -- Update the final position.
    final_x = final_x + PetParty_MainFrame_Button_Rename_Pet_Party:GetWidth() + offset_x;
    
    -- Update the position of the delete pet party button.
    PetParty_MainFrame_Button_Delete_Pet_Party:ClearAllPoints();
    PetParty_MainFrame_Button_Delete_Pet_Party:SetPoint("TOPLEFT", final_x, final_y);
    
    -- Update the starting location.
    start_y = start_y - PetParty_MainFrame_Button_Create_Pet_Party:GetHeight() - PetParty.PADDING;
    
    -- Calculate the offset.
    offset_x = ((PetParty.MAIN_FRAME_WIDTH - PetParty.MAIN_FRAME_OFFSET_LEFT + PetParty.MAIN_FRAME_OFFSET_RIGHT) - PetParty_MainFrame_Edit_Box_Search:GetWidth()) / 2;
    
    -- Update the position of the search edit box.
    PetParty_MainFrame_Edit_Box_Search:ClearAllPoints();
    PetParty_MainFrame_Edit_Box_Search:SetPoint("TOPLEFT", offset_x, start_y);
    PetParty_MainFrame_Edit_Box_Search:SetPoint("RIGHT", -offset_x, 0);
end
