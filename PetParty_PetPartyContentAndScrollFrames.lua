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

local PET_PARTY_FRAME_FONT = "Fonts\\FRIZQT__.TTF";
local PET_PARTY_FRAME_FONT_SIZE = 18;
local PET_PARTY_FRAME_SIZE = 22;

local PET_PARTY_FRAME_TITLE_R = 1;
local PET_PARTY_FRAME_TITLE_G = 1;
local PET_PARTY_FRAME_TITLE_B = 1;
local PET_PARTY_FRAME_TITLE_A = 1;

local PET_PARTY_FRAME_TITLE_HIGHLIGHT_R = 0;
local PET_PARTY_FRAME_TITLE_HIGHLIGHT_G = 0;
local PET_PARTY_FRAME_TITLE_HIGHLIGHT_B = 1;
local PET_PARTY_FRAME_TITLE_HIGHLIGHT_A = 1;

local PET_PARTY_FRAME_TITLE_SELECTED_R = 0;
local PET_PARTY_FRAME_TITLE_SELECTED_G = 1;
local PET_PARTY_FRAME_TITLE_SELECTED_B = 0;
local PET_PARTY_FRAME_TITLE_SELECTED_A = 1;

local SCROLL_FRAME_OFFSET_RIGHT = PetParty.MAIN_FRAME_OFFSET_X;
local SCROLL_FRAME_OFFSET_TOP = PetParty.MAIN_FRAME_OFFSET_Y - 26;
local SCROLL_FRAME_OFFSET_BOTTOM = -PetParty.MAIN_FRAME_OFFSET_Y + PetParty.PET_INFORMATION_PARTY_FRAME_HEIGHT;

local SCROLL_BAR_ALPHA = 0.4;

local SCROLL_BAR_OFFSET_LEFT = -16;
local SCROLL_BAR_OFFSET_RIGHT = -16;
local SCROLL_BAR_OFFSET_TOP = -16;
local SCROLL_BAR_OFFSET_BOTTOM = 16;

local SCROLL_BAR_SCROLL_STEP = 1;
local SCROLL_BAR_STEPS_PER_PAGE = 1;

local SCROLL_BAR_WIDTH = 16;

-- The currently selected pet party frame.
local pet_party_frame_selected = nil;

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
        pet_party_frame = PetParty_PetPartyContentFrame.content.frames[PetParty_PetPartyContentFrame.content.frame_count];
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
        
        pet_party_frame.texture_background = pet_party_frame:CreateTexture();
        pet_party_frame.texture_background:SetAllPoints();
        pet_party_frame.texture_background:SetTexture(0, 0, 0, 0);
        
        -- Create the pet party title frame.
        pet_party_frame.font_string_title = pet_party_frame:CreateFontString();
        
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
        pet_party_frame:SetPoint("BOTTOMLEFT", PetParty_PetPartyContentFrame.content.frames[PetParty_PetPartyContentFrame.content.frame_count - 1], "BOTTOMLEFT", 0, -PET_PARTY_FRAME_SIZE);
    end
    
    pet_party_frame:SetPoint("RIGHT", PetParty_PetPartyScrollFrame);
    
    pet_party_frame.font_string_title:SetFont(PET_PARTY_FRAME_FONT, PET_PARTY_FRAME_FONT_SIZE);
    pet_party_frame.font_string_title:SetText(name);
    pet_party_frame.font_string_title:SetTextColor(PET_PARTY_FRAME_TITLE_R,
                                                   PET_PARTY_FRAME_TITLE_G,
                                                   PET_PARTY_FRAME_TITLE_B,
                                                   PET_PARTY_FRAME_TITLE_A);
    pet_party_frame.font_string_title:ClearAllPoints();
    pet_party_frame.font_string_title:SetPoint("CENTER", pet_party_frame);
    
    -- Update the pet party frame's index.
    pet_party_frame.id = PetParty_PetPartyContentFrame.content.frame_count;
    
    -- Update the pet party frame's pet information.
    pet_party_frame.pet_guids = {};
    pet_party_frame.pet_guids[1] = PetParty.GetPetGUIDPetInformationFrame(1);
    pet_party_frame.pet_guids[2] = PetParty.GetPetGUIDPetInformationFrame(2);
    pet_party_frame.pet_guids[3] = PetParty.GetPetGUIDPetInformationFrame(3);
    
    -- Store the pet party frame.
    PetParty_PetPartyContentFrame.content.frames[PetParty_PetPartyContentFrame.content.frame_count] = pet_party_frame;
    
    -- Select the new pet party frame.
    local pet_party_frame_previously_selected = pet_party_frame_selected;
    pet_party_frame_selected = pet_party_frame;
    
    -- Update the previously selected frame. 
    if (pet_party_frame_previously_selected ~= nil) then
        PetParty.OnLeavePetPartyFrame(pet_party_frame_previously_selected, false);
    end
    
    -- Update the selected frame.
    if (pet_party_frame_selected ~= nil) then
        PetParty.OnLeavePetPartyFrame(pet_party_frame_selected, false);
    end
    
    -- Update the frame count.
    PetParty_PetPartyContentFrame.content.frame_count = PetParty_PetPartyContentFrame.content.frame_count + 1;
    
    -- Update the scroll bar layout.
    PetParty.UpdatePetPartyScrollBarLayout();
end

-- Call to create the pet party content and scroll frames.
function PetParty.CreatePetPartyContentAndScrollFrames()
    -- Create the scroll frame.
    CreateFrame("ScrollFrame", "PetParty_PetPartyScrollFrame", PetParty_MainFrame);
    PetParty_PetPartyScrollFrame:SetPoint("TOPLEFT", PetParty_PetPartyScrollFrame:GetParent():GetWidth() / 2, SCROLL_FRAME_OFFSET_TOP);
    PetParty_PetPartyScrollFrame:SetPoint("BOTTOM", 0, SCROLL_FRAME_OFFSET_BOTTOM);
    PetParty_PetPartyScrollFrame:EnableMouseWheel(true);
    PetParty_PetPartyScrollFrame:SetWidth((PetParty_PetPartyScrollFrame:GetParent():GetWidth() / 2) - SCROLL_FRAME_OFFSET_RIGHT);
    
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
    if (pet_party_frame_selected ~= nil) then
        -- Remove the frame the scroll area.
        pet_party_frame_selected:Hide();
        pet_party_frame_selected:SetParent(nil);
        
        -- Get the previous frame.
        local frame_previous = nil;
        if (pet_party_frame_selected.id - 1 >= 0) then
            frame_previous = PetParty_PetPartyContentFrame.content.frames[pet_party_frame_selected.id - 1];
        end
        
        -- Update the other frames.
        for i = pet_party_frame_selected.id + 1, PetParty_PetPartyContentFrame.content.frame_count - 1 do
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
        local original_id = pet_party_frame_selected.id;
        
        -- Move the selected frame to the end of the array.
        for i = pet_party_frame_selected.id, PetParty_PetPartyContentFrame.content.frame_count - 2 do
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
            pet_party_frame_selected = PetParty_PetPartyContentFrame.content.frames[original_id];
        elseif (PetParty_PetPartyContentFrame.content.frame_count > 0) then
            pet_party_frame_selected = PetParty_PetPartyContentFrame.content.frames[PetParty_PetPartyContentFrame.content.frame_count - 1];
        else
            pet_party_frame_selected = nil;
        end
        
        if (pet_party_frame_selected ~= nil) then
            PetParty.OnLeavePetPartyFrame(pet_party_frame_selected, false);
            
            -- Update the pet frames.
            PetParty.SetPetGUIDsPetInformationFrame(pet_party_frame_selected.pet_guids[1],
                                                    pet_party_frame_selected.pet_guids[2],
                                                    pet_party_frame_selected.pet_guids[3]);
        end
    end
end

-- Called when the mouse enters a pet party frame.
function PetParty.OnEnterPetPartyFrame(self, motion)
    -- Store the entered frame.
    if (motion) then
        pet_party_frame_entered = self;
    end
    
    self.font_string_title:SetTextColor(PET_PARTY_FRAME_TITLE_HIGHLIGHT_R,
                                        PET_PARTY_FRAME_TITLE_HIGHLIGHT_G,
                                        PET_PARTY_FRAME_TITLE_HIGHLIGHT_B,
                                        PET_PARTY_FRAME_TITLE_HIGHLIGHT_A);
end

-- Called when the mouse leaves a pet party frame.
function PetParty.OnLeavePetPartyFrame(self, motion)
    -- Reset the entered frame.
    if (motion) then
        pet_party_frame_entered = nil;
    end
    
    if (self ~= pet_party_frame_selected) then
        self.font_string_title:SetTextColor(PET_PARTY_FRAME_TITLE_R,
                                            PET_PARTY_FRAME_TITLE_G,
                                            PET_PARTY_FRAME_TITLE_B,
                                            PET_PARTY_FRAME_TITLE_A);
    else
        self.font_string_title:SetTextColor(PET_PARTY_FRAME_TITLE_SELECTED_R,
                                            PET_PARTY_FRAME_TITLE_SELECTED_G,
                                            PET_PARTY_FRAME_TITLE_SELECTED_B,
                                            PET_PARTY_FRAME_TITLE_SELECTED_A);
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
        if (pet_party_frame_selected ~= nil) then
            -- Cache the old frame.
            local frame = pet_party_frame_selected;
            pet_party_frame_selected = nil;
            
            -- Store the new frame.
            pet_party_frame_selected = self;
            
            -- Reset the old frame.
            PetParty.OnLeavePetPartyFrame(frame, false);
        end
        
        -- Update the pet frames.
        PetParty.SetPetGUIDsPetInformationFrame(self.pet_guids[1],
                                                self.pet_guids[2],
                                                self.pet_guids[3]);
        
        -- Store the new frame.
        pet_party_frame_selected = self;
        
        -- Update the new frame.
        PetParty.OnEnterPetPartyFrame(self, false);
    end
    
    -- Reset the pressed frame.
    pet_party_frame_pressed = nil;
end

-- Call to update the pet party scroll bar layout.
function PetParty.UpdatePetPartyScrollBarLayout()
    -- Update the anchors of the pet party scroll frame.
    PetParty_PetPartyScrollFrame:SetPoint("TOPLEFT", PetParty_PetPartyScrollFrame:GetParent():GetWidth() / 2, SCROLL_FRAME_OFFSET_TOP);
    PetParty_PetPartyScrollFrame:SetPoint("BOTTOM", 0, SCROLL_FRAME_OFFSET_BOTTOM);
    
    -- Update the width of the pet party scroll frame.
    PetParty_PetPartyScrollFrame:SetWidth((PetParty_PetPartyScrollFrame:GetParent():GetWidth() / 2) - SCROLL_FRAME_OFFSET_RIGHT);
    
    -- The height of the content frame.
    local height_content_frame = 0;
    
    if (PetParty_PetPartyContentFrame.content ~= nil) then
        if (PetParty_PetPartyContentFrame.content.frame_count > 0) then
            -- Calculate the height of the content frame.
            local frame = PetParty_PetPartyContentFrame.content.frames[PetParty_PetPartyContentFrame.content.frame_count - 1];
            height_content_frame = frame.font_string_title:GetHeight() *
                                   PetParty_PetPartyContentFrame.content.frame_count;
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
