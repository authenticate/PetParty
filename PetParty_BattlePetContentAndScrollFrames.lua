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

local BATTLE_PET_FRAME_FONT = "Fonts\\FRIZQT__.TTF";
local BATTLE_PET_FRAME_FONT_SIZE = 18;
local BATTLE_PET_FRAME_SIZE = 18;

local BATTLE_PET_FRAME_TITLE_R = 1;
local BATTLE_PET_FRAME_TITLE_G = 1;
local BATTLE_PET_FRAME_TITLE_B = 1;
local BATTLE_PET_FRAME_TITLE_A = 1;

local SCROLL_FRAME_OFFSET_LEFT = PetParty.MAIN_FRAME_OFFSET_X;
local SCROLL_FRAME_OFFSET_TOP = PetParty.MAIN_FRAME_OFFSET_Y - 2;
local SCROLL_FRAME_OFFSET_BOTTOM = -PetParty.MAIN_FRAME_OFFSET_Y;

local SCROLL_BAR_ALPHA = 0.4;

local SCROLL_BAR_OFFSET_LEFT = 0;
local SCROLL_BAR_OFFSET_RIGHT = 16;
local SCROLL_BAR_OFFSET_TOP = -16;
local SCROLL_BAR_OFFSET_BOTTOM = 16;

local SCROLL_BAR_SCROLL_STEP = 1;
local SCROLL_BAR_STEPS_PER_PAGE = 1;

local SCROLL_BAR_WIDTH = 16;

-- The pet being dragged.
local pet_guid_dragged = nil;

-- Call to create the battle pet content and scroll frames.
function PetParty.CreateBattlePetContentAndScrollFrames()
    -- Create the scroll frame.
    CreateFrame("ScrollFrame", "PetParty_BattlePetScrollFrame", PetParty_MainFrame);
    PetParty_BattlePetScrollFrame:SetPoint("TOPLEFT", SCROLL_FRAME_OFFSET_LEFT, SCROLL_FRAME_OFFSET_TOP);
    PetParty_BattlePetScrollFrame:SetPoint("BOTTOM", 0, SCROLL_FRAME_OFFSET_BOTTOM);
    PetParty_BattlePetScrollFrame:EnableMouseWheel(true);
    PetParty_BattlePetScrollFrame:SetWidth((PetParty_BattlePetScrollFrame:GetParent():GetWidth() / 2) - SCROLL_FRAME_OFFSET_LEFT - SCROLL_BAR_WIDTH);
    
    local texture = PetParty_BattlePetScrollFrame:CreateTexture();
    texture:SetAllPoints();
    texture:SetTexture(0, 0, 0, 0);
    
    -- Create the scroll bar.
    CreateFrame("Slider", "PetParty_BattlePetScrollBar", PetParty_BattlePetScrollFrame, "UIPanelScrollBarTemplate");
    PetParty_BattlePetScrollBar:SetPoint("TOPLEFT", PetParty_BattlePetScrollFrame, "TOPRIGHT", SCROLL_BAR_OFFSET_LEFT, SCROLL_BAR_OFFSET_TOP);
    PetParty_BattlePetScrollBar:SetPoint("BOTTOMLEFT", PetParty_BattlePetScrollFrame, "BOTTOMRIGHT", SCROLL_BAR_OFFSET_RIGHT, SCROLL_BAR_OFFSET_BOTTOM);
    PetParty_BattlePetScrollBar:SetMinMaxValues(0, 0);
    PetParty_BattlePetScrollBar:SetValueStep(0);
    PetParty_BattlePetScrollBar.scrollStep = BATTLE_PET_FRAME_SIZE;
    PetParty_BattlePetScrollBar:SetStepsPerPage(SCROLL_BAR_STEPS_PER_PAGE);
    PetParty_BattlePetScrollBar:SetValue(0);
    PetParty_BattlePetScrollBar:SetObeyStepOnDrag(true);
    
    -- Add a mouse wheel handler for the scroll frame.
    PetParty_BattlePetScrollFrame:SetScript("OnMouseWheel",
        function(self, delta)
            PetParty_BattlePetScrollBar:SetValue(PetParty_BattlePetScrollBar:GetValue() - (delta * PetParty_BattlePetScrollBar:GetValueStep()));
        end
    );
    
    -- Add a size changed handler for the scroll frame.
    PetParty_BattlePetScrollFrame:SetScript("OnSizeChanged",
        function(self, width, height)
            PetParty.UpdateBattlePetScrollBarLayout();
        end
    );
    
    local texture_background = PetParty_BattlePetScrollBar:CreateTexture(nil, "BACKGROUND");
    texture_background:SetAllPoints(PetParty_BattlePetScrollBar);
    texture_background:SetTexture(0, 0, 0, SCROLL_BAR_ALPHA);
    
    -- Create the content frame.
    CreateFrame("Frame", "PetParty_BattlePetContentFrame", PetParty_BattlePetScrollFrame);
    PetParty_BattlePetContentFrame:SetWidth(1);
    PetParty_BattlePetContentFrame:SetHeight(1);
    
    -- Set up the scroll child.
    PetParty_BattlePetScrollFrame:SetScrollChild(PetParty_BattlePetContentFrame);
end

-- Call to create the battle pet frames.
function PetParty.CreateBattlePetFrames()
    -- Initialize the battle pet frame variables.
    if (PetParty_BattlePetContentFrame.content == nil) then
        PetParty_BattlePetContentFrame.content = {};
        PetParty_BattlePetContentFrame.content.frames = {};
        PetParty_BattlePetContentFrame.content.frame_count = 0;
        PetParty_BattlePetContentFrame.content.frame_count_allocated = 0;
    end
    
    -- Clear the old frames.
    for i = 1, PetParty_BattlePetContentFrame.content.frame_count - 1 do
        local battle_pet_frame = PetParty_BattlePetContentFrame.content.frames[i];
        battle_pet_frame:Hide();
        battle_pet_frame:SetParent(nil);
    end
    
    -- Reset the frame count.
    PetParty_BattlePetContentFrame.content.frame_count = 0;
    
    -- Get the total number of pets.
    local number_of_pets = C_PetJournal.GetNumPets();
    
    -- For each battle pet...
    for i = 1, number_of_pets do
        -- Get the battle pet information.
        local petGUID, speciesID, owned, customName, level, isFavorite,
              isRevoked, speciesName, icon, petType, companionID,
              tooltip, description, isWild, canBattle, isTradeable,
              isUnique, isObtainable = C_PetJournal.GetPetInfoByIndex(i);
        
        -- If the player owns this pet and it is a battle pet...
        if (owned) and (canBattle) then
            --  Create or reuse a battle pet frame.
            local battle_pet_frame = nil;
            
            -- Reuse any old frames.
            if (PetParty_BattlePetContentFrame.content.frame_count_allocated > PetParty_BattlePetContentFrame.content.frame_count) then
                battle_pet_frame = PetParty_BattlePetContentFrame.content.frames[PetParty_BattlePetContentFrame.content.frame_count];
                battle_pet_frame:SetParent(PetParty_BattlePetContentFrame);
                battle_pet_frame:Show();
            else
                -- Create the battle pet frame.
                battle_pet_frame = CreateFrame("Frame", nil, PetParty_BattlePetContentFrame);
                battle_pet_frame:SetHeight(BATTLE_PET_FRAME_SIZE);
                battle_pet_frame:EnableMouse(true);
                battle_pet_frame:RegisterForDrag("LeftButton");
                
                -- Add a drag start handler for the battle pet frame.
                battle_pet_frame:SetScript("OnDragStart",
                    function(self)
                        PetParty.OnDragStartBattlePetFrame(self);
                    end
                );
                
                -- Add a drag stop handler for the battle pet frame.
                battle_pet_frame:SetScript("OnDragStop",
                    function(self)
                        PetParty.OnDragStopBattlePetFrame(self);
                    end
                );
                
                battle_pet_frame.texture_background = battle_pet_frame:CreateTexture();
                battle_pet_frame.texture_background:SetAllPoints();
                battle_pet_frame.texture_background:SetTexture(0, 0, 0, 0);
                
                -- Create the battle pet title frame.
                battle_pet_frame.font_string_title = battle_pet_frame:CreateFontString();
                
                -- Update the allocated frame count.
                PetParty_BattlePetContentFrame.content.frame_count_allocated = PetParty_BattlePetContentFrame.content.frame_count_allocated + 1;
            end
            
            -- Update the battle pet frame's anchors.
            battle_pet_frame:ClearAllPoints();
            
            if (PetParty_BattlePetContentFrame.content.frame_count == 0) then
                -- Anchor the frame to the content frame.
                battle_pet_frame:SetPoint("TOPLEFT", PetParty_BattlePetContentFrame);
            else
                -- Anchor the frame to the previous frame.
                battle_pet_frame:SetPoint("BOTTOMLEFT", PetParty_BattlePetContentFrame.content.frames[PetParty_BattlePetContentFrame.content.frame_count - 1], "BOTTOMLEFT", 0, -BATTLE_PET_FRAME_SIZE);
            end
            
            battle_pet_frame:SetPoint("RIGHT", PetParty_BattlePetScrollFrame);
            
            battle_pet_frame.font_string_title:SetFont(BATTLE_PET_FRAME_FONT, BATTLE_PET_FRAME_FONT_SIZE);
            
            -- If this pet has a custom name...
            if (customName ~= nil) and (customName ~= "") then
                battle_pet_frame.font_string_title:SetText(customName .. " (" .. speciesName .. ")");
            else
                battle_pet_frame.font_string_title:SetText(speciesName);
            end
            
            battle_pet_frame.font_string_title:SetJustifyH("LEFT");
            battle_pet_frame.font_string_title:SetTextColor(BATTLE_PET_FRAME_TITLE_R,
                                                            BATTLE_PET_FRAME_TITLE_G,
                                                            BATTLE_PET_FRAME_TITLE_B,
                                                            BATTLE_PET_FRAME_TITLE_A);
            battle_pet_frame.font_string_title:ClearAllPoints();
            battle_pet_frame.font_string_title:SetPoint("TOPLEFT", battle_pet_frame);
            battle_pet_frame.font_string_title:SetPoint("BOTTOMRIGHT", battle_pet_frame);
            
            -- Store this battle pet's GUID.
            battle_pet_frame.pet_guid = petGUID;
            
            -- Store the battle pet frame.
            PetParty_BattlePetContentFrame.content.frames[PetParty_BattlePetContentFrame.content.frame_count] = battle_pet_frame;
            
            -- Update the frame count.
            PetParty_BattlePetContentFrame.content.frame_count = PetParty_BattlePetContentFrame.content.frame_count + 1;
        end
    end
    
    -- Update the scroll bar layout.
    PetParty.UpdateBattlePetScrollBarLayout();
end

-- Called when a battle pet frame starts dragging.
function PetParty.OnDragStartBattlePetFrame(self)
    -- Store the pet being dragged.
    pet_guid_dragged = self.pet_guid;
    
    -- Get the pet's information.
    local speciesID, customName, level, XP, maxXP, displayID, isFavorite,
          speciesName, icon, petType, companionID,
          tooltip, description, isWild, canBattle, isTradable,
          isUnique, isObtainable = C_PetJournal.GetPetInfoByPetID(self.pet_guid);
    
    -- Update the cursor.
    SetCursor(icon);
end

-- Called when a battle pet frame stops dragging.
function PetParty.OnDragStopBattlePetFrame(self)
    -- If the mouse is over a pet party frame...
    if (PetParty.pet_information_frame_hovered ~= nil) then
        -- Store the pet being dragged in the hovered pet party frame.
        PetParty.SetPetGUIDPetInformationFrame(PetParty.pet_information_frame_hovered.id, self.pet_guid);
    end
    
    -- Reset the pet being dragged.
    pet_guid_dragged = nil;
    
    -- Reset the cursor.
    SetCursor(nil);
end

-- Call to update the battle pet scroll bar layout.
function PetParty.UpdateBattlePetScrollBarLayout()
    -- Update the width of the battle pet scroll frame.
    PetParty_BattlePetScrollFrame:SetWidth((PetParty_BattlePetScrollFrame:GetParent():GetWidth() / 2) - SCROLL_FRAME_OFFSET_LEFT - SCROLL_BAR_WIDTH);
    
    -- The height of the content frame.
    local height_content_frame = 0;
    
    if (PetParty_BattlePetContentFrame.content ~= nil) then
        if (PetParty_BattlePetContentFrame.content.frame_count > 0) then
            -- Calculate the height of the content frame.
            height_content_frame = PetParty_BattlePetContentFrame.content.frames[PetParty_BattlePetContentFrame.content.frame_count - 1]:GetHeight() *
                                   PetParty_BattlePetContentFrame.content.frame_count;
        end
    end
    
    -- Update the battle pet scroll bar.
    if (height_content_frame < PetParty_BattlePetScrollFrame:GetHeight()) then
        PetParty_BattlePetScrollBar:SetMinMaxValues(0, 0);
        PetParty_BattlePetScrollBar:SetValueStep(0);
    else
        PetParty_BattlePetScrollBar:SetMinMaxValues(1, height_content_frame - PetParty_BattlePetScrollFrame:GetHeight());
        PetParty_BattlePetScrollBar:SetValueStep(BATTLE_PET_FRAME_SIZE);
    end
end
