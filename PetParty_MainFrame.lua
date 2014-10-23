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

local BUTTON_WIDTH = 100;

local FRAME_MAXIMUM_WIDTH = 0;
local FRAME_MAXIMUM_HEIGHT = 0;
local FRAME_MINIMUM_WIDTH = 480;
local FRAME_MINIMUM_HEIGHT = 640;
local FRAME_OFFSET_X = 14;
local FRAME_OFFSET_Y = -34;

local PET_PARTY_BUTTON_COUNT = 2;

-- Called when the main frame's create pet party button is clicked.
function PetParty.OnClickMainFrameButtonCreatePetParty()
    StaticPopup_Show("PetParty_CreatePetPartyDialog");
end

-- Called when the main frame's delete pet party button is clicked.
function PetParty.OnClickMainFrameButtonDeletePetParty()
end

-- Called when the main frame starts dragging.
function PetParty.OnDragStartMainFrame()
    PetParty_MainFrame:StartMoving();
end

-- Called when the main frame stops dragging.
function PetParty.OnDragStopMainFrame()
    PetParty_MainFrame:StopMovingOrSizing();
end

-- Called when the main frame's resize button starts dragging.
function PetParty.OnDragStartMainFrameButtonResize()
    PetParty_MainFrame.is_sizing = true;
    PetParty_MainFrame:StartSizing();
end

-- Called when the main frame's resize button stops dragging.
function PetParty.OnDragStopMainFrameButtonResize()
    PetParty_MainFrame:StopMovingOrSizing();
    PetParty_MainFrame.is_sizing = false;
    
    PetParty.UpdateMainFrameLayout();
    PetParty.UpdateBattlePetScrollBarLayout();
    PetParty.UpdatePetPartyScrollBarLayout();
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
        
        PetParty.UpdateMainFrameLayout();
    elseif (event == "PET_JOURNAL_LIST_UPDATE") then
        PetParty.CreateBattlePetFrames();
    elseif (event == "PLAYER_LOGOUT") then
        PetPartyCharacterDB.main_frame_hidden = not PetParty_MainFrame:IsShown();
    end
end

-- Called when the main frame is hidden.
function PetParty.OnHideMainFrame()
    StaticPopup_Hide("PetParty_CreatePetPartyDialog");
end

-- Called when the main frame is loaded.
function PetParty.OnLoadMainFrame()
    -- Configure the main frame.
    tinsert(UISpecialFrames, PetParty_MainFrame:GetName());
    PetParty_MainFrame.is_sizing = false;
    PetParty_MainFrame:SetClampedToScreen(true);
    PetParty_MainFrame:SetUserPlaced(true);
    PetParty_MainFrame:SetMaxResize(FRAME_MAXIMUM_WIDTH, FRAME_MAXIMUM_HEIGHT);
    PetParty_MainFrame:SetMinResize(FRAME_MINIMUM_WIDTH, FRAME_MINIMUM_HEIGHT);
    
    -- Register the main frame for events.
    PetParty_MainFrame:RegisterEvent("ADDON_LOADED");
    PetParty_MainFrame:RegisterEvent("PET_JOURNAL_LIST_UPDATE");
    PetParty_MainFrame:RegisterEvent("PLAYER_LOGOUT");
    PetParty_MainFrame:RegisterForDrag("LeftButton");
    
    -- Register the main frame's resize button for events.
    PetParty_MainFrame_Button_Resize:RegisterForDrag("LeftButton");
    
    -- Create the main frame's scroll frames.
    PetParty.CreateBattlePetContentAndScrollFrames();
    PetParty.CreatePetPartyContentAndScrollFrames();
    
    -- Create the create pet party dialog box.
    StaticPopupDialogs["PetParty_CreatePetPartyDialog"] = {
        text = PetParty.L["Create a pet party."],
        button1 = PetParty.L["Create"],
        button2 = PetParty.L["Cancel"],
        OnAccept =
            function (self)
                local text = self.editBox:GetText();
                if (text ~= nil) and (text ~= "") then
                    PetParty.AddPetPartyFrame(text);
                end
            end
        ,
        OnShow =
            function (self, data)
                if (data ~= nil) then
                    self.editBox:SetText(data);
                else
                    self.button1:Disable();
                end
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
        hasEditBox = true,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
        preferredIndex = 3,
    };
    
    -- Configure the buttons.
    PetParty_MainFrame_Button_Create_Pet_Party:SetWidth(BUTTON_WIDTH);
    PetParty_MainFrame_Button_Delete_Pet_Party:SetWidth(BUTTON_WIDTH);
    
    -- Localize the UI.
    PetParty_MainFrame_Title_Font_String:SetText(PetParty.L["Pet Party"]);
    PetParty_MainFrame_Button_Create_Pet_Party:SetText(PetParty.L["Create"]);
    PetParty_MainFrame_Button_Delete_Pet_Party:SetText(PetParty.L["Delete"]);
end

-- Called when the main frame is updated.
function PetParty.OnUpdateMainFrame()
    if (PetParty_MainFrame.is_sizing) then
        PetParty.UpdateMainFrameLayout();
        PetParty.UpdateBattlePetScrollBarLayout();
        PetParty.UpdatePetPartyScrollBarLayout();
    end
end

-- Call to update the main frame layout.
function PetParty.UpdateMainFrameLayout()
    -- Calculate the main frame offsets.
    local offset_main_frame_x = PetParty_MainFrame:GetWidth() / 2;
    local offset_main_frame_y = FRAME_OFFSET_Y;
    
    -- Calculate the width of all the pet party buttons.
    local button_width = PetParty_MainFrame_Button_Create_Pet_Party:GetWidth() +
                         PetParty_MainFrame_Button_Delete_Pet_Party:GetWidth();
    
    -- Calculate the center offsets.
    local offset_center_x = (offset_main_frame_x - button_width - FRAME_OFFSET_X) / (PET_PARTY_BUTTON_COUNT + 1);
    local offset_center_y = 0;
    
    -- Calculate the current offsets.
    local offset_x = offset_main_frame_x + offset_center_x;
    local offset_y = offset_main_frame_y + offset_center_y;
    
    -- Update the position of the create pet party button.
    local width = PetParty_MainFrame_Button_Create_Pet_Party:GetWidth();
    PetParty_MainFrame_Button_Create_Pet_Party:ClearAllPoints();
    PetParty_MainFrame_Button_Create_Pet_Party:SetPoint("TOPLEFT", offset_x, offset_y);
    
    -- Update the current offsets.
    offset_x = offset_x + width + offset_center_x;
    
    -- Update the position of the delete pet party button.
    PetParty_MainFrame_Button_Delete_Pet_Party:ClearAllPoints();
    PetParty_MainFrame_Button_Delete_Pet_Party:SetPoint("TOPLEFT", offset_x, offset_y);
end
