----------------------------------------------------------------------------------
-- Total RP 3
--	---------------------------------------------------------------------------
--	Copyright 2015 Sylvain Cossement (telkostrasz@totalrp3.info)
--
--	Licensed under the Apache License, Version 2.0 (the "License");
--	you may not use this file except in compliance with the License.
--	You may obtain a copy of the License at
--
--		http://www.apache.org/licenses/LICENSE-2.0
--
--	Unless required by applicable law or agreed to in writing, software
--	distributed under the License is distributed on an "AS IS" BASIS,
--	WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
--	See the License for the specific language governing permissions and
--	limitations under the License.
----------------------------------------------------------------------------------
local Globals, Events, Utils = TRP3_API.globals, TRP3_API.events, TRP3_API.utils;
local Comm = TRP3_API.communication;
local tinsert, tostring, _G, wipe, pairs = tinsert, tostring, _G, wipe, pairs;
local getClass, isContainerByClassID, isUsableByClass = TRP3_API.extended.getClass, TRP3_API.inventory.isContainerByClassID, TRP3_API.inventory.isUsableByClass;
local loc = TRP3_API.locale.getText;
local EMPTY = TRP3_API.globals.empty;
local CreateFrame = CreateFrame;

local inspectionFrame = TRP3_InspectionFrame;
local decorateSlot;

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- DATA EXCHANGE
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local INSPECTION_REQUEST = "IIRQ";
local INSPECTION_RESPONSE = "IIRS";
local REQUEST_PRIORITY = "NORMAL";
local RESPONSE_PRIORITY = "BULK";

local loadingTemplate;

local function receiveResponse(response, sender)
	if sender == inspectionFrame.current then
		-- Weight and value
		local weight = TRP3_API.extended.formatWeight(response.totalWeight or 0) .. Utils.str.texture("Interface\\GROUPFRAME\\UI-Group-MasterLooter", 15);
		local formatedValue = ("%s: %s"):format(loc("INV_PAGE_TOTAL_VALUE"), GetCoinTextureString(response.totalValue or 0));
		inspectionFrame.Main.Model.WeightText:SetText(weight);
		inspectionFrame.Main.Model.ValueText:SetText(formatedValue);
		inspectionFrame.Main.Model.WeightText:Show();
		inspectionFrame.Main.Model.ValueText:Show();

		for _, button in pairs(inspectionFrame.Main.slots) do
			local slotInfo = (response.slots or EMPTY)[button.slotID];
			if slotInfo then
				button.info = {
					count = slotInfo.count,
					id = slotInfo.id,
					noAlt = true,
				};
				button.class = {
					BA = slotInfo.BA,
					CO = slotInfo.CO,
					US = slotInfo.US,
				};
			end
		end
	end
end

local function receiveRequest(request, sender)
	local reservedMessageID = request[1];
	local playerInventory = TRP3_API.inventory.getInventory();

	local response = {
		totalWeight = playerInventory.totalWeight,
		totalValue = playerInventory.totalValue,
		slots = {},
	};
	for slotID, slot in pairs(playerInventory.content or EMPTY) do
		-- Don't send the default bag
		if slotID ~= "17" then
			local class = getClass(slot.id);
			response.slots[slotID] = {
				count = slot.count,
				id = slot.id,
				BA = class.BA;
			};
			if isContainerByClassID(slot.id) then
				response.slots[slotID].CO = class.CO;
			end
			if isUsableByClass(class) then
				response.slots[slotID].US = class.US;
			end
		end
	end

	Comm.sendObject(INSPECTION_RESPONSE, response, sender, RESPONSE_PRIORITY, reservedMessageID);
end

local function sendRequest()
	local reservedMessageID = Comm.getMessageIDAndIncrement();
	local data = {reservedMessageID};
	Comm.addMessageIDHandler(inspectionFrame.current, reservedMessageID, function(_, total, current)
		inspectionFrame.Main.Model.Loading:SetText(loadingTemplate:format(current / total * 100));
		if current == total then
			inspectionFrame.Main.Model.Loading:Hide();
		end
	end);
	Comm.sendObject(INSPECTION_REQUEST, data, inspectionFrame.current, REQUEST_PRIORITY);
end

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- UI
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local function onToolbarButtonClicked()
	local unitID = Utils.str.getUnitID("target");
	if unitID and inspectionFrame.current ~= unitID then
		inspectionFrame.current = unitID

		for _, slot in pairs(inspectionFrame.Main.slots) do
			if slot.info then
				wipe(slot.info);
				slot.info = nil;
			end
			if slot.class then
				slot.class = nil;
			end
		end

		inspectionFrame.Main.Model:SetUnit("target");
		inspectionFrame.Main.Model.Title:SetText(UnitName("target"));
		inspectionFrame.Main.Model.WeightText:Hide();
		inspectionFrame.Main.Model.ValueText:Hide();
		inspectionFrame.Main.Model.Loading:Show();
		inspectionFrame.Main.Model.Loading:SetText(loadingTemplate:format(0));
		inspectionFrame:Show();

		sendRequest();
	end
end

function inspectionFrame.init()

	loadingTemplate = loc("INV_PAGE_CHARACTER_INSPECTION") .. ": %0.2f %%";

	-- Slots
	inspectionFrame.Main.slots = {};
	for i=1, 16 do
		local button = CreateFrame("Button", "TRP3_InspectionFrameSlot" .. i, inspectionFrame.Main, "TRP3_InventoryPageSlotTemplate");
		if i == 1 then
			button:SetPoint("TOPRIGHT", inspectionFrame.Main.Model, "TOPLEFT", -10, 4);
		elseif i == 9 then
			button:SetPoint("TOPLEFT", inspectionFrame.Main.Model, "TOPRIGHT", 12, 4);
		else
			button:SetPoint("TOP", _G["TRP3_InspectionFrameSlot" .. (i - 1)], "BOTTOM", 0, -11);
		end
		if i <= 8 then
			button.Locator:SetPoint("RIGHT", button, "LEFT", -5, 0);
		else
			button.Locator:SetPoint("LEFT", button, "RIGHT", 5, 0);
		end
		tinsert(inspectionFrame.Main.slots, button);
		button.slotNumber = i;
		button.slotID = tostring(i);
		TRP3_API.inventory.initContainerSlot(button, nil, function() end);
		button.First:ClearAllPoints();
		if i > 8 then
			button.tooltipRight = true;
			button.First:SetPoint("TOPLEFT", button, "TOPRIGHT", 5, -5);
			button.First:SetPoint("BOTTOMLEFT", button, "BOTTOMRIGHT", 5, 15);
			button.First:SetPoint("RIGHT", inspectionFrame, "RIGHT", -15, 0);
			button.First:SetJustifyH("LEFT");
			button.Second:SetPoint("TOPLEFT", button, "TOPRIGHT", 5, -10);
			button.Second:SetPoint("BOTTOMLEFT", button, "BOTTOMRIGHT", 5, -10);
			button.Second:SetPoint("RIGHT", inspectionFrame, "RIGHT", -15, 0);
			button.Second:SetJustifyH("LEFT");
		else
			button.First:SetPoint("TOPRIGHT", button, "TOPLEFT", -5, -5);
			button.First:SetPoint("BOTTOMRIGHT", button, "BOTTOMLEFT", -5, 15);
			button.First:SetPoint("LEFT", inspectionFrame, "LEFT", 15, 0);
			button.First:SetJustifyH("RIGHT");
			button.Second:SetPoint("TOPRIGHT", button, "TOPLEFT", -5, -10);
			button.Second:SetPoint("BOTTOMRIGHT", button, "BOTTOMLEFT", -5, -10);
			button.Second:SetPoint("LEFT", inspectionFrame, "LEFT", 15, 0);
			button.Second:SetJustifyH("RIGHT");
		end
	end
	TRP3_API.inventory.initContainerInstance(inspectionFrame.Main, 16);

	TRP3_API.events.listenToEvent(TRP3_API.events.WORKFLOW_ON_LOADED, function()
		inspectionFrame:Hide();
		if TRP3_API.target then
			TRP3_API.target.registerButton({
				id = "aa_player_e_inspect",
				onlyForType = TRP3_API.ui.misc.TYPE_CHARACTER,
				configText = loc("INV_PAGE_CHARACTER_INSPECTION"),
				onClick = function(_, _, buttonType, _)
					onToolbarButtonClicked();
				end,
				tooltip = loc("INV_PAGE_CHARACTER_INSPECTION"),
				tooltipSub = loc("INV_PAGE_CHARACTER_INSPECTION_TT"),
				icon = "inv_helmet_66"
			});
		end
	end);

	-- Register prefix for data exchange
	Comm.registerProtocolPrefix(INSPECTION_REQUEST, receiveRequest);
	Comm.registerProtocolPrefix(INSPECTION_RESPONSE, receiveResponse);
end