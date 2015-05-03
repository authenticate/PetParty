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
-- Constants.
--

local PET_PARTY_FRAME_FONT = "GameFontNormal";

local PET_PARTY_FRAME_SIZE = 22;

local PET_PARTY_FRAME_TEXTURE_OFFSET_LEFT = 0;
local PET_PARTY_FRAME_TEXTURE_OFFSET_RIGHT = -3;
local PET_PARTY_FRAME_TEXTURE_OFFSET_TOP = -1;
local PET_PARTY_FRAME_TEXTURE_OFFSET_BOTTOM = 1;

local PET_PARTY_FRAME_HIGHLIGHT_R = 1.0;
local PET_PARTY_FRAME_HIGHLIGHT_G = 1.0;
local PET_PARTY_FRAME_HIGHLIGHT_B = 1.0;
local PET_PARTY_FRAME_HIGHLIGHT_A = 0.333;

local PET_PARTY_FRAME_PUSHED_R = 0.769;
local PET_PARTY_FRAME_PUSHED_G = 0.647;
local PET_PARTY_FRAME_PUSHED_B = 0.157;
local PET_PARTY_FRAME_PUSHED_A = 0.333;

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
        pet_party_frame = CreateFrame("Button", nil, PetParty_PetPartyContentFrame);
        pet_party_frame:SetHeight(PET_PARTY_FRAME_SIZE);
        
        -- Add a click handler for the pet party frame.
        pet_party_frame:SetScript("OnClick",
            function(self, button, down)
                PetParty.OnClickPetPartyFrame(self, button, down);
            end
        );
        
        pet_party_frame.time = 0;
        pet_party_frame.time_start = false;
        
        pet_party_frame:SetNormalFontObject(PET_PARTY_FRAME_FONT);
        
        local texture_highlight = pet_party_frame:CreateTexture(nil, "BACKGROUND");
        texture_highlight:ClearAllPoints();
        texture_highlight:SetPoint("TOPLEFT", PET_PARTY_FRAME_TEXTURE_OFFSET_LEFT, PET_PARTY_FRAME_TEXTURE_OFFSET_TOP);
        texture_highlight:SetPoint("BOTTOMRIGHT", PET_PARTY_FRAME_TEXTURE_OFFSET_RIGHT, PET_PARTY_FRAME_TEXTURE_OFFSET_BOTTOM);
        texture_highlight:SetTexture(PET_PARTY_FRAME_HIGHLIGHT_R,
                                     PET_PARTY_FRAME_HIGHLIGHT_G,
                                     PET_PARTY_FRAME_HIGHLIGHT_B,
                                     PET_PARTY_FRAME_HIGHLIGHT_A);
        pet_party_frame:SetHighlightTexture(texture_highlight);
        
        local texture_pushed = pet_party_frame:CreateTexture(nil, "BACKGROUND");
        texture_pushed:ClearAllPoints();
        texture_pushed:SetPoint("TOPLEFT", PET_PARTY_FRAME_TEXTURE_OFFSET_LEFT, PET_PARTY_FRAME_TEXTURE_OFFSET_TOP);
        texture_pushed:SetPoint("BOTTOMRIGHT", PET_PARTY_FRAME_TEXTURE_OFFSET_RIGHT, PET_PARTY_FRAME_TEXTURE_OFFSET_BOTTOM);
        texture_pushed:SetTexture(PET_PARTY_FRAME_PUSHED_R,
                                  PET_PARTY_FRAME_PUSHED_G,
                                  PET_PARTY_FRAME_PUSHED_B,
                                  PET_PARTY_FRAME_PUSHED_A);
        pet_party_frame:SetPushedTexture(texture_pushed);
        
        local texture_toggled = pet_party_frame:CreateTexture(nil, "BACKGROUND");
        texture_toggled:ClearAllPoints();
        texture_toggled:SetPoint("TOPLEFT", PET_PARTY_FRAME_TEXTURE_OFFSET_LEFT, PET_PARTY_FRAME_TEXTURE_OFFSET_TOP);
        texture_toggled:SetPoint("BOTTOMRIGHT", PET_PARTY_FRAME_TEXTURE_OFFSET_RIGHT, PET_PARTY_FRAME_TEXTURE_OFFSET_BOTTOM);
        texture_toggled:SetTexture(PET_PARTY_FRAME_PUSHED_R,
                                   PET_PARTY_FRAME_PUSHED_G,
                                   PET_PARTY_FRAME_PUSHED_B,
                                   PET_PARTY_FRAME_PUSHED_A);
        pet_party_frame.texture_toggled = texture_toggled;
        
        -- Update the allocated frame count.
        PetParty_PetPartyContentFrame.content.frame_count_allocated = PetParty_PetPartyContentFrame.content.frame_count_allocated + 1;
    end
    
    -- Update the pet party frame's name.
    pet_party_frame:SetText(name);
    
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
    
    --
    -- Cache the active pet party frames.
    --
    
    local active_pet_party_frames = {};
    for i = 1, PetParty_PetPartyContentFrame.content.frame_count do
        active_pet_party_frames[i] = PetParty_PetPartyContentFrame.content.frames[i];
    end
    
    --
    -- Sort the active pet party frames by name.
    --
    
    table.sort(active_pet_party_frames,
        function(frame_a, frame_b)
            local result = false;
            
            if (frame_a:GetText() < frame_b:GetText()) then
                result = true;
            end
            
            return result;
        end
    );
    
    --
    -- Store the sorted active pet party frames.
    --
    
    for i = 1, PetParty_PetPartyContentFrame.content.frame_count do
        PetParty_PetPartyContentFrame.content.frames[i] = active_pet_party_frames[i];
    end
    
    --
    -- Update the sorted pet party frames' IDs and anchors.
    --
    
    for i = 1, #PetParty_PetPartyContentFrame.content.frames do
        -- Get the frame.
        local frame = PetParty_PetPartyContentFrame.content.frames[i];
        
        --
        -- Update the pet party frame's ID.
        --
        
        frame.id = i;
        
        --
        -- Update the pet party frame's anchors.
        --
        
        frame:ClearAllPoints();
        
        if (i == 1) then
            -- Anchor the frame to the content frame.
            frame:SetPoint("TOPLEFT", PetParty_PetPartyContentFrame);
        else
            -- Get the previous frame.
            local previous_frame = PetParty_PetPartyContentFrame.content.frames[i - 1];
            
            -- Anchor the frame to the previous frame.
            frame:SetPoint("BOTTOMLEFT", previous_frame, "BOTTOMLEFT", 0, -PET_PARTY_FRAME_SIZE);
        end
        
        frame:SetPoint("RIGHT", PetParty_PetPartyScrollFrame);
    end
    
    -- Select the new pet party frame.
    PetParty.OnClickPetPartyFrame(pet_party_frame, "LeftButton", false);
    
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
    PetParty_PetPartyScrollFrame:SetWidth(PetParty_PetPartyScrollFrame:GetParent():GetWidth() -
                                          PetParty.MAIN_FRAME_OFFSET_LEFT +
                                          PetParty.MAIN_FRAME_OFFSET_RIGHT -
                                          SCROLL_BAR_WIDTH);
    
    local texture = PetParty_PetPartyScrollFrame:CreateTexture();
    texture:SetAllPoints();
    texture:SetTexture(0, 0, 0, 0);
    
    -- Create the scroll bar.
    CreateFrame("Slider", "PetParty_PetPartyScrollBar", PetParty_PetPartyScrollFrame, "UIPanelScrollBarTemplate");
    PetParty_PetPartyScrollBar:SetPoint("TOPLEFT", PetParty_PetPartyScrollFrame, "TOPRIGHT", 0, SCROLL_BAR_OFFSET_TOP);
    PetParty_PetPartyScrollBar:SetPoint("BOTTOMLEFT", PetParty_PetPartyScrollFrame, "BOTTOMRIGHT", SCROLL_BAR_OFFSET_RIGHT, SCROLL_BAR_OFFSET_BOTTOM);
    PetParty_PetPartyScrollBar:SetMinMaxValues(0, 0);
    PetParty_PetPartyScrollBar:SetValueStep(0);
    PetParty_PetPartyScrollBar.scrollStep = PET_PARTY_FRAME_SIZE;
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
        -- Remove the frame from the scroll area.
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
        
        -- Update the scroll bar layout.
        PetParty.UpdatePetPartyScrollBarLayout();
    end
end

-- Call to deserialize the pet parties.
function PetParty.DeserializePetParties()
    if (PetPartyDB ~= nil) and
       (PetPartyDB.pet_parties ~= nil) then
        -- Cache the values.
        local pet_parties = PetPartyDB.pet_parties;
        local pet_party_selected_id = PetPartyDB.pet_party_selected_id;
        
        -- Delete any current pet parties.
        while (PetParty.pet_party_frame_selected ~= nil) do
            PetParty.DeletePetPartyFrame();
        end
        
        -- For each pet party...
        for i = 1, #pet_parties do
            -- Get the pet party.
            local pet_party = pet_parties[i];
            
            -- Create a pet party frame.
            PetParty.AddPetPartyFrame(pet_party.name);
            
            -- Store the pet party's training pet's ID.
            PetParty.pet_party_frame_selected.pet_training_frame_id = pet_party.pet_training_frame_id;
            
            -- For each pet...
            for j = 1, PetParty.PETS_PER_PARTY do
                -- Store the pet party's pet GUIDs.
                PetParty.pet_party_frame_selected.pet_guids[j] = pet_party.pet_guids[j];
                
                -- Store the pet party's ability GUIDs.
                PetParty.pet_party_frame_selected.ability_guids[j] = pet_party.ability_guids[j];
            end
        end
        
        -- If there's a selected pet party ID...
        if (pet_party_selected_id ~= nil) then
            local frame = PetParty_PetPartyContentFrame.content.frames[pet_party_selected_id];
            PetParty.OnClickPetPartyFrame(frame, "LeftButton", false);
        end
    end
end

-- Called when the user clicks on a pet party frame.
function PetParty.OnClickPetPartyFrame(self, button, down)
    if (button == "LeftButton") then
        PetParty.HidePopups();
        
        -- Reset the old frame.
        if (PetParty.pet_party_frame_selected ~= nil) then
            -- Cache the old frame.
            local frame = PetParty.pet_party_frame_selected;
            
            -- Store the new frame.
            PetParty.pet_party_frame_selected = self;
            
            -- Reset the old frame.
            frame.texture_toggled:Hide();
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
        self.texture_toggled:Show();
        
        -- Double click functionality.
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
    PetPartyDB.pet_parties = {};
    PetPartyDB.pet_party_selected_id = nil;
    
    -- For each pet party frame...
    for i = 1, PetParty_PetPartyContentFrame.content.frame_count do
        -- Get the pet party frame.
        local pet_party_frame = PetParty_PetPartyContentFrame.content.frames[i];
        
        -- Create a pet party storage variable.
        local pet_party = {};
        pet_party.pet_guids = {};
        pet_party.ability_guids = {};
        
        -- Store the pet party's name.
        pet_party.name = pet_party_frame:GetText();
        
        -- Store the pet party's training pet's GUID.
        pet_party.pet_training_frame_id = pet_party_frame.pet_training_frame_id;
        
        -- For each pet...
        for j = 1, PetParty.PETS_PER_PARTY do
            -- Store the pet party's pet GUIDs.
            pet_party.pet_guids[j] = pet_party_frame.pet_guids[j];
            
            -- Store the pet party's pets' abilities GUIDs.
            pet_party.ability_guids[j] = pet_party_frame.ability_guids[j];
        end
        
        -- Store the pet party.
        PetPartyDB.pet_parties[i] = pet_party;
    end
    
    -- If there's a selected pet party frame...
    if (PetParty.pet_party_frame_selected) then
        -- Store the selected pet party's ID.
        PetPartyDB.pet_party_selected_id = PetParty.pet_party_frame_selected.id;
    end
end

-- Call to update the pet party scroll bar layout.
function PetParty.UpdatePetPartyScrollBarLayout()
    -- Update the anchors of the pet party scroll frame.
    PetParty_PetPartyScrollFrame:SetPoint("TOPLEFT", PetParty.MAIN_FRAME_OFFSET_LEFT, SCROLL_FRAME_OFFSET_TOP);
    PetParty_PetPartyScrollFrame:SetPoint("BOTTOM", 0, SCROLL_FRAME_OFFSET_BOTTOM);
    
    -- Update the width of the pet party scroll frame.
    PetParty_PetPartyScrollFrame:SetWidth(PetParty_PetPartyScrollFrame:GetParent():GetWidth() -
                                          PetParty.MAIN_FRAME_OFFSET_LEFT +
                                          PetParty.MAIN_FRAME_OFFSET_RIGHT -
                                          SCROLL_BAR_WIDTH);
    
    -- The height of the content frame.
    local height_content_frame = 0;
    
    if (PetParty_PetPartyContentFrame.content ~= nil) then
        if (PetParty_PetPartyContentFrame.content.frame_count > 0) then
            -- Calculate the height of the content frame.
            height_content_frame = PET_PARTY_FRAME_SIZE * PetParty_PetPartyContentFrame.content.frame_count;
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
