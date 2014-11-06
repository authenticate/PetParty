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

local PET_PARTY_FRAME_FONT = "GameFontNormal";
local PET_PARTY_FRAME_FONT_HIGHLIGHT = "GameFontHighlight";
local PET_PARTY_FRAME_FONT_SELECTED = "GameFontGreen";

local PET_PARTY_FRAME_SIZE = 22;

local SCROLL_FRAME_OFFSET_TOP = PetParty.MAIN_FRAME_OFFSET_TOP -
                                PetParty.TRAINING_PET_INFORMATION_FRAME_HEIGHT -
                                PetParty.FONT_STRING_HEIGHT -
                                PetParty.FONT_STRING_PADDING -
                                PetParty.FONT_STRING_HEIGHT -
                                PetParty.FONT_STRING_PADDING -
                                PetParty.PADDING -
                                20;

local SCROLL_FRAME_OFFSET_BOTTOM = PetParty.PET_INFORMATION_PARTY_FRAME_HEIGHT -
                                   PetParty.MAIN_FRAME_OFFSET_TOP +
                                   PetParty.MAIN_FRAME_OFFSET_BOTTOM -
                                   PetParty.FONT_STRING_HEIGHT -
                                   PetParty.BUTTON_HEIGHT;

local SCROLL_BAR_ALPHA = 0.4;

local SCROLL_BAR_OFFSET_LEFT = -16;
local SCROLL_BAR_OFFSET_RIGHT = -16;
local SCROLL_BAR_OFFSET_TOP = -16;
local SCROLL_BAR_OFFSET_BOTTOM = 16;

local SCROLL_BAR_SCROLL_STEP = 1;
local SCROLL_BAR_STEPS_PER_PAGE = 1;

local SCROLL_BAR_WIDTH = 16;

-- The currently entered pet party frame.
local pet_party_frame_entered = nil;

-- The currently pressed pet party frame.
local pet_party_frame_pressed = nil;

-- Call to add a pet party frame.
function PetParty.AddPetPartyFrame(name)
    -- Initialize the battle pet frame variables.
    if (PetParty_PetPartyContentFrame.content == nil) then
        PetParty_PetPartyContentFrame.content = {};
        PetParty_PetPartyContentFrame.content.frames = {};
        PetParty_PetPartyContentFrame.content.frame_count = 0;
        PetParty_PetPartyContentFrame.content.frame_count_allocated = 0;
    end
    
    -- Create or reuse a pet party frame.
    local pet_party_frame = nil;
    
    -- Reuse any old frames.
    if (PetParty_PetPartyContentFrame.content.frame_count_allocated > PetParty_PetPartyContentFrame.content.frame_count) then
        pet_party_frame = PetParty_PetPartyContentFrame.content.frames[PetParty_PetPartyContentFrame.content.frame_count + 1];
        pet_party_frame:SetParent(PetParty_PetPartyContentFrame);
        pet_party_frame:Show();
    else
        -- Create the pet party frame.
        pet_party_frame = CreateFrame("Frame", nil, PetParty_PetPartyContentFrame);
        pet_party_frame:SetHeight(PET_PARTY_FRAME_SIZE);
        
        -- Add an enter handler for the pet party frame.
        pet_party_frame:SetScript("OnEnter",
            function(self, motion)
                PetParty.OnEnterPetPartyFrame(self, motion);
            end
        );
        
        -- Add a leave handler for the pet party frame.
        pet_party_frame:SetScript("OnLeave",
            function(self, motion)
                PetParty.OnLeavePetPartyFrame(self, motion);
            end
        );
        
        -- Add a mouse down handler for the pet party frame.
        pet_party_frame:SetScript("OnMouseDown",
            function(self, button)
                PetParty.OnMouseDownPetPartyFrame(self, button);
            end
        );
        
        -- Add a mouse up handler for the pet party frame.
        pet_party_frame:SetScript("OnMouseUp",
            function(self, button)
                PetParty.OnMouseUpPetPartyFrame(self, button);
            end
        );
        
        pet_party_frame.time = 0;
        pet_party_frame.time_start = false;
        
        pet_party_frame.texture_background = pet_party_frame:CreateTexture();
        pet_party_frame.texture_background:SetAllPoints();
        pet_party_frame.texture_background:SetTexture(0, 0, 0, 0);
        
        -- Create the pet party title frame.
        pet_party_frame.font_string_name = pet_party_frame:CreateFontString();
        
        -- Update the allocated frame count.
        PetParty_PetPartyContentFrame.content.frame_count_allocated = PetParty_PetPartyContentFrame.content.frame_count_allocated + 1;
    end
    
    -- Update the pet party frame's anchors.
    pet_party_frame:ClearAllPoints();
    
    if (PetParty_PetPartyContentFrame.content.frame_count == 0) then
        -- Anchor the frame to the content frame.
        pet_party_frame:SetPoint("TOPLEFT", PetParty_PetPartyContentFrame);
    else
        -- Anchor the frame to the previous frame.
        pet_party_frame:SetPoint("BOTTOMLEFT", PetParty_PetPartyContentFrame.content.frames[PetParty_PetPartyContentFrame.content.frame_count], "BOTTOMLEFT", 0, -PET_PARTY_FRAME_SIZE);
    end
    
    pet_party_frame:SetPoint("RIGHT", PetParty_PetPartyScrollFrame);
    
    pet_party_frame.font_string_name:SetFontObject(PET_PARTY_FRAME_FONT);
    pet_party_frame.font_string_name:SetText(name);
    pet_party_frame.font_string_name:ClearAllPoints();
    pet_party_frame.font_string_name:SetPoint("CENTER", pet_party_frame);
    
    -- Update the pet party frame's pet information.
    pet_party_frame.pet_training_frame_id = nil;
    pet_party_frame.pet_guids = {};
    pet_party_frame.ability_guids = {};
    
    -- Initialize the current pets into the pet party.
    for i = 1, PetParty.PETS_PER_PARTY do
        pet_party_frame.pet_guids[i] = PetParty.GetPetGUIDPetInformationFrame(i);
        pet_party_frame.ability_guids[i] = PetParty.GetPetAbilityGUIDsPetInformationFrame(i);
    end
    
    --
    -- Initialize the current training pet into the pet party.
    --
    
    -- If there is a training pet frame...
    if (PetParty_PetPartyInformationFrame.training_pet_frame ~= nil) then
        -- Set the training pet frame's ID to the new pet party frame.
        pet_party_frame.pet_training_frame_id = PetParty_PetPartyInformationFrame.training_pet_frame.id;
    end
    
    -- Update the frame count.
    PetParty_PetPartyContentFrame.content.frame_count = PetParty_PetPartyContentFrame.content.frame_count + 1;
    
    -- Store the pet party frame's index.
    pet_party_frame.id = PetParty_PetPartyContentFrame.content.frame_count;
    
    -- Store the pet party frame.
    PetParty_PetPartyContentFrame.content.frames[PetParty_PetPartyContentFrame.content.frame_count] = pet_party_frame;
    
    -- Select the new pet party frame.
    local pet_party_frame_previously_selected = PetParty.pet_party_frame_selected;
    PetParty.pet_party_frame_selected = pet_party_frame;
    
    -- Update the previously selected frame. 
    if (pet_party_frame_previously_selected ~= nil) then
        PetParty.OnLeavePetPartyFrame(pet_party_frame_previously_selected, false);
    end
    
    -- Update the selected frame.
    if (PetParty.pet_party_frame_selected ~= nil) then
        PetParty.OnLeavePetPartyFrame(PetParty.pet_party_frame_selected, false);
    end
    
    -- Update the scroll bar layout.
    PetParty.UpdatePetPartyScrollBarLayout();
end

-- Call to create the pet party content and scroll frames.
function PetParty.CreatePetPartyContentAndScrollFrames()
    -- Create the scroll frame.
    CreateFrame("ScrollFrame", "PetParty_PetPartyScrollFrame", PetParty_MainFrame);
    PetParty_PetPartyScrollFrame:SetPoint("TOPLEFT", PetParty.MAIN_FRAME_OFFSET_LEFT, SCROLL_FRAME_OFFSET_TOP);
    PetParty_PetPartyScrollFrame:SetPoint("BOTTOM", 0, SCROLL_FRAME_OFFSET_BOTTOM);
    PetParty_PetPartyScrollFrame:EnableMouseWheel(true);
    PetParty_PetPartyScrollFrame:SetWidth(PetParty_PetPartyScrollFrame:GetParent():GetWidth() - PetParty.MAIN_FRAME_OFFSET_LEFT + PetParty.MAIN_FRAME_OFFSET_RIGHT);
    
    local texture = PetParty_PetPartyScrollFrame:CreateTexture();
    texture:SetAllPoints();
    texture:SetTexture(0, 0, 0, 0);
    
    -- Create the scroll bar.
    CreateFrame("Slider", "PetParty_PetPartyScrollBar", PetParty_PetPartyScrollFrame, "UIPanelScrollBarTemplate");
    PetParty_PetPartyScrollBar:SetPoint("TOPLEFT", PetParty_PetPartyScrollFrame, "TOPRIGHT", SCROLL_BAR_OFFSET_LEFT, SCROLL_BAR_OFFSET_TOP);
    PetParty_PetPartyScrollBar:SetPoint("BOTTOMLEFT", PetParty_PetPartyScrollFrame, "BOTTOMRIGHT", SCROLL_BAR_OFFSET_RIGHT, SCROLL_BAR_OFFSET_BOTTOM);
    PetParty_PetPartyScrollBar:SetMinMaxValues(0, 0);
    PetParty_PetPartyScrollBar:SetValueStep(0);
    PetParty_PetPartyScrollBar.scrollStep = BATTLE_PET_FRAME_SIZE;
    PetParty_PetPartyScrollBar:SetStepsPerPage(SCROLL_BAR_STEPS_PER_PAGE);
    PetParty_PetPartyScrollBar:SetValue(0);
    PetParty_PetPartyScrollBar:SetObeyStepOnDrag(true);
    
    -- Add a mouse wheel handler for the scroll frame.
    PetParty_PetPartyScrollFrame:SetScript("OnMouseWheel",
        function(self, delta)
            PetParty_PetPartyScrollBar:SetValue(PetParty_PetPartyScrollBar:GetValue() - (delta * PetParty_PetPartyScrollBar:GetValueStep()));
        end
    );
    
    -- Add a size changed handler for the scroll frame.
    PetParty_PetPartyScrollFrame:SetScript("OnSizeChanged",
        function(self, width, height)
            PetParty.UpdatePetPartyScrollBarLayout();
        end
    );
    
    local texture_background = PetParty_PetPartyScrollBar:CreateTexture(nil, "BACKGROUND");
    texture_background:SetAllPoints(PetParty_PetPartyScrollBar);
    texture_background:SetTexture(0, 0, 0, SCROLL_BAR_ALPHA);
    
    -- Create the content frame.
    CreateFrame("Frame", "PetParty_PetPartyContentFrame", PetParty_PetPartyScrollFrame);
    PetParty_PetPartyContentFrame:SetWidth(1);
    PetParty_PetPartyContentFrame:SetHeight(1);
    
    -- Set up the scroll child.
    PetParty_PetPartyScrollFrame:SetScrollChild(PetParty_PetPartyContentFrame);
end

-- Call to delete the currently selected pet party frame.
function PetParty.DeletePetPartyFrame()
    if (PetParty.pet_party_frame_selected ~= nil) then
        -- Remove the frame the scroll area.
        PetParty.pet_party_frame_selected:Hide();
        PetParty.pet_party_frame_selected:SetParent(nil);
        
        -- Get the previous frame.
        local frame_previous = nil;
        if (PetParty.pet_party_frame_selected.id - 1 > 0) then
            frame_previous = PetParty_PetPartyContentFrame.content.frames[PetParty.pet_party_frame_selected.id - 1];
        end
        
        -- Update the other frames.
        for i = PetParty.pet_party_frame_selected.id + 1, PetParty_PetPartyContentFrame.content.frame_count do
            -- Get the frame.
            local frame = PetParty_PetPartyContentFrame.content.frames[i];
            
            -- Update the pet party frame's anchors.
            frame:ClearAllPoints();
            
            if (frame_previous == nil) then
                -- Anchor the frame to the content frame.
                frame:SetPoint("TOPLEFT", PetParty_PetPartyContentFrame);
            else
                -- Anchor the frame to the previous frame.
                frame:SetPoint("BOTTOMLEFT", frame_previous, "BOTTOMLEFT", 0, -PET_PARTY_FRAME_SIZE);
            end
            
            frame:SetPoint("RIGHT", PetParty_PetPartyScrollFrame);
            
            -- Update the previous frame.
            frame_previous = frame;
        end
        
        -- Cache the original ID of the selected frame.
        local original_id = PetParty.pet_party_frame_selected.id;
        
        -- Move the selected frame to the end of the array.
        for i = PetParty.pet_party_frame_selected.id, PetParty_PetPartyContentFrame.content.frame_count - 1 do
            --  Swap the frames.
            PetParty_PetPartyContentFrame.content.frames[i], PetParty_PetPartyContentFrame.content.frames[i + 1] =
            PetParty_PetPartyContentFrame.content.frames[i + 1], PetParty_PetPartyContentFrame.content.frames[i];
            
            -- Update the frames' IDs.
            PetParty_PetPartyContentFrame.content.frames[i].id = i;
            PetParty_PetPartyContentFrame.content.frames[i + 1].id = i + 1;
        end
        
        -- Decrement the frame count.
        PetParty_PetPartyContentFrame.content.frame_count = PetParty_PetPartyContentFrame.content.frame_count - 1;
        
        -- Update the selected frame.
        if (PetParty_PetPartyContentFrame.content.frame_count > 0) and (original_id < PetParty_PetPartyContentFrame.content.frame_count) then
            PetParty.pet_party_frame_selected = PetParty_PetPartyContentFrame.content.frames[original_id];
        elseif (PetParty_PetPartyContentFrame.content.frame_count > 0) then
            PetParty.pet_party_frame_selected = PetParty_PetPartyContentFrame.content.frames[PetParty_PetPartyContentFrame.content.frame_count];
        else
            PetParty.pet_party_frame_selected = nil;
        end
        
        if (PetParty.pet_party_frame_selected ~= nil) then
            PetParty.OnLeavePetPartyFrame(PetParty.pet_party_frame_selected, false);
            
            -- For each pet...
            for i = 1, PetParty.PETS_PER_PARTY do
                -- Update the pet frames.
                PetParty.SetPetGUIDPetInformationFrame(i, PetParty.pet_party_frame_selected.pet_guids[i]);
                PetParty.SetPetAbilityGUIDsPetInformationFrame(i, PetParty.pet_party_frame_selected.ability_guids[i]);
            end
        end
        
        -- Store the pet parties.
        PetParty.SerializePetParties();
    end
end

-- Call to deserialize the pet parties.
function PetParty.DeserializePetParties()
    if (PetPartyDB ~= nil) and
       (PetPartyDB.pet_party_count ~= nil) and
       (PetPartyDB.pet_parties ~= nil) then
        -- Cache the values.
        local pet_party_count = PetPartyDB.pet_party_count;
        local pet_parties = PetPartyDB.pet_parties;
        
        -- Delete any current pet parties.
        while (PetParty.pet_party_frame_selected ~= nil) do
            PetParty.DeletePetPartyFrame();
        end
        
        -- For each pet party...
        for i = 1, pet_party_count do
            -- Get the pet party.
            local pet_party = pet_parties[i];
            
            -- Create a pet party frame.
            PetParty.AddPetPartyFrame(pet_party.name);
            
            -- Get the pet party's training pet's ID.
            PetParty.pet_party_frame_selected.pet_training_frame_id = pet_party.pet_training_frame_id;
            
            -- For each pet...
            for j = 1, PetParty.PETS_PER_PARTY do
                -- Store the pet party's pet GUIDs.
                PetParty.pet_party_frame_selected.pet_guids[j] = pet_party.pet_guids[j];
                
                -- Store the pet party's ability GUIDs.
                PetParty.pet_party_frame_selected.ability_guids[j] = pet_party.ability_guids[j];
            end
        end
    end
end

-- Called when the mouse enters a pet party frame.
function PetParty.OnEnterPetPartyFrame(self, motion)
    -- Store the entered frame.
    if (motion) then
        pet_party_frame_entered = self;
    end
    
    self.font_string_name:SetFontObject(PET_PARTY_FRAME_FONT_HIGHLIGHT);
end

-- Called when the mouse leaves a pet party frame.
function PetParty.OnLeavePetPartyFrame(self, motion)
    -- Reset the entered frame.
    if (motion) then
        pet_party_frame_entered = nil;
    end
    
    if (self ~= PetParty.pet_party_frame_selected) then
        self.font_string_name:SetFontObject(PET_PARTY_FRAME_FONT);
    else
        self.font_string_name:SetFontObject(PET_PARTY_FRAME_FONT_SELECTED);
    end
end

-- Called when the mouse is pressed on a pet party frame.
function PetParty.OnMouseDownPetPartyFrame(self, button)
    pet_party_frame_pressed = self;
end

-- Called when the mouse is released on a pet party frame.
function PetParty.OnMouseUpPetPartyFrame(self, button)
    if (button == "LeftButton") and (pet_party_frame_entered == pet_party_frame_pressed) then
        -- Reset the old frame.
        if (PetParty.pet_party_frame_selected ~= nil) then
            -- Cache the old frame.
            local frame = PetParty.pet_party_frame_selected;
            PetParty.pet_party_frame_selected = nil;
            
            -- Store the new frame.
            PetParty.pet_party_frame_selected = self;
            
            -- Reset the old frame.
            PetParty.OnLeavePetPartyFrame(frame, false);
        end
        
        -- For each pet...
        for i = 1, PetParty.PETS_PER_PARTY do
            -- Update the pet frames.
            PetParty.SetPetGUIDPetInformationFrame(i, self.pet_guids[i]);
            PetParty.SetPetAbilityGUIDsPetInformationFrame(i, self.ability_guids[i]);
        end
        
        -- If there's a training pet frame ID.
        if (self.pet_training_frame_id ~= nil) then
            -- Update the training pet frame.
            PetParty_PetPartyInformationFrame.training_pet_frame = PetParty_PetPartyInformationFrame.pet_frames[self.pet_training_frame_id];
        else
            PetParty_PetPartyInformationFrame.training_pet_frame = nil;
        end
        
        -- Update the display.
        PetParty.UpdateTrainingPetInformationFrame();
        
        -- Signal the training pet has changed.
        PetParty.OnTrainingPetChangedPetPartyInformationFrame();
        
        -- For each pet...
        for i = 1, PetParty.PETS_PER_PARTY do
            -- Update the pet frames.
            PetParty.UpdatePetInformationPetInformationFrame(i);
        end
        
        -- Store the new frame.
        PetParty.pet_party_frame_selected = self;
        
        -- Update the new frame.
        PetParty.OnEnterPetPartyFrame(self, false);
        
        --
        -- Double click functionality.
        --
        
        if (self.time) < time() then
            self.time_start = false;
        end
        
        if (self.time == time()) and (self.time_start) then
            self.time_start = false
            
            -- Activate the pet party on a double click.
            PetParty.OnClickPetPartyInformationFrameButtonActivate();
        else
            self.time_start = true
            self.time = time()
        end
    end
    
    -- Reset the pressed frame.
    pet_party_frame_pressed = nil;
end

-- Call to serialize the pet parties.
function PetParty.SerializePetParties()
    if (PetPartyDB == nil) then
        PetPartyDB = {};
    end
    
    -- Clear any old data.
    PetPartyDB.pet_party_count = 0;
    PetPartyDB.pet_parties = {};
    
    -- For each pet party frame...
    for i = 1, PetParty_PetPartyContentFrame.content.frame_count do
        -- Get the pet party frame.
        local pet_party_frame = PetParty_PetPartyContentFrame.content.frames[i];
        
        -- Create a pet party storage variable.
        local pet_party = {};
        pet_party.pet_guids = {};
        pet_party.ability_guids = {};
        
        -- Store the pet party's name.
        pet_party.name = pet_party_frame.font_string_name:GetText();
        
        -- Store the pet party's training pet's GUID.
        pet_party.pet_training_frame_id = pet_party_frame.pet_training_frame_id;
        
        -- For each pet...
        for j = 1, PetParty.PETS_PER_PARTY do
            -- Store the pet party's pet GUIDs.
            pet_party.pet_guids[j] = pet_party_frame.pet_guids[j];
            
            -- Store the pet party's pets' abilities GUIDs.
            pet_party.ability_guids[j] = pet_party_frame.ability_guids[j];
        end
        
        PetPartyDB.pet_parties[i] = pet_party;
    end
    
    -- Store the number of pet parties.
    PetPartyDB.pet_party_count = PetParty_PetPartyContentFrame.content.frame_count;
end

-- Call to update the pet party scroll bar layout.
function PetParty.UpdatePetPartyScrollBarLayout()
    -- Update the anchors of the pet party scroll frame.
    PetParty_PetPartyScrollFrame:SetPoint("TOPLEFT", PetParty.MAIN_FRAME_OFFSET_LEFT, SCROLL_FRAME_OFFSET_TOP);
    PetParty_PetPartyScrollFrame:SetPoint("BOTTOM", 0, SCROLL_FRAME_OFFSET_BOTTOM);
    
    -- Update the width of the pet party scroll frame.
    PetParty_PetPartyScrollFrame:SetWidth(PetParty_PetPartyScrollFrame:GetParent():GetWidth() - PetParty.MAIN_FRAME_OFFSET_LEFT + PetParty.MAIN_FRAME_OFFSET_RIGHT);
    
    -- The height of the content frame.
    local height_content_frame = 0;
    
    if (PetParty_PetPartyContentFrame.content ~= nil) then
        if (PetParty_PetPartyContentFrame.content.frame_count > 0) then
            -- Calculate the height of the content frame.
            local frame = PetParty_PetPartyContentFrame.content.frames[PetParty_PetPartyContentFrame.content.frame_count];
            height_content_frame = frame.font_string_name:GetHeight() * PetParty_PetPartyContentFrame.content.frame_count;
        end
    end
    
    -- Update the pet party scroll bar.
    if (height_content_frame < PetParty_PetPartyScrollFrame:GetHeight()) then
        PetParty_PetPartyScrollBar:SetMinMaxValues(0, 0);
        PetParty_PetPartyScrollBar:SetValueStep(0);
    else
        PetParty_PetPartyScrollBar:SetMinMaxValues(1, height_content_frame - PetParty_PetPartyScrollFrame:GetHeight());
        PetParty_PetPartyScrollBar:SetValueStep(PET_PARTY_FRAME_SIZE);
    end
end
