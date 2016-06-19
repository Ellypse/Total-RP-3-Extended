----------------------------------------------------------------------------------
-- Total RP 3: Extended features
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
local tonumber, tostring, type, tinsert, wipe, strtrim = tonumber, tostring, type, tinsert, wipe, strtrim;
local tsize, EMPTY = Utils.table.size, Globals.empty;
local getClass = TRP3_API.extended.getClass;
local stEtN = Utils.str.emptyToNil;
local loc = TRP3_API.locale.getText;
local initList = TRP3_API.ui.list.initList;
local handleMouseWheel = TRP3_API.ui.list.handleMouseWheel;
local setTooltipForSameFrame = TRP3_API.ui.tooltip.setTooltipForSameFrame;

local registerOperandEditor = TRP3_API.extended.tools.registerOperandEditor;
local getUnitText = TRP3_API.extended.tools.getUnitText;

local unitTypeEditor, stringEditor, numericEditor = TRP3_OperandEditorUnitType, TRP3_OperandEditorString, TRP3_OperandEditorNumeric;
local itemSelectionEditor = TRP3_OperandEditorItemSelection;

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- Shared editors
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local function initEnitTypeEditor()
	local unitType = {
		{TRP3_API.formats.dropDownElements:format(loc("OP_UNIT"), loc("OP_UNIT_PLAYER")), "player"},
		{TRP3_API.formats.dropDownElements:format(loc("OP_UNIT"), loc("OP_UNIT_TARGET")), "target"},
		{TRP3_API.formats.dropDownElements:format(loc("OP_UNIT"), loc("OP_UNIT_NPC")), "npc"},
	}
	TRP3_API.ui.listbox.setupListBox(unitTypeEditor.type, unitType, nil, nil, 180, true);

	function unitTypeEditor.load(args)
		unitTypeEditor.type:SetSelectedValue((args or EMPTY)[1] or "target");
	end

	function unitTypeEditor.save()
		return {unitTypeEditor.type:GetSelectedValue() or "target"};
	end
end

local function initItemSelectionEditor()

	itemSelectionEditor.browse:SetText(BROWSE);
	itemSelectionEditor.browse:SetScript("OnClick", function()
		TRP3_API.popup.showPopup(TRP3_API.popup.OBJECTS, {parent = itemSelectionEditor, point = "RIGHT", parentPoint = "LEFT"}, {function(id)
			itemSelectionEditor.id:SetText(id);
		end, TRP3_DB.types.ITEM});
	end);

	-- Text
	itemSelectionEditor.id.title:SetText(loc("ITEM_ID"));

	function itemSelectionEditor.load(args)
		itemSelectionEditor.id:SetText((args or EMPTY)[1] or "");
	end

	function itemSelectionEditor.save()
		return {strtrim(itemSelectionEditor.id:GetText()) or ""};
	end
end

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- Operands basic
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local function string_init()
	registerOperandEditor("string", {
		title = loc("OP_STRING"),
		noPreview = true,
		getText = function(args)
			local value = tostring(args or "");
			return loc("OP_STRING") .. ": \"" .. value .. "\"";
		end,
		editor = stringEditor,
	});

	-- Text
	stringEditor.input.title:SetText(loc("OP_STRING"));

	function stringEditor.load(value)
		stringEditor.input:SetText(value or "");
	end

	function stringEditor.save()
		return stringEditor.input:GetText();
	end
end

local function numeric_init()
	registerOperandEditor("numeric", {
		title = loc("OP_NUMERIC"),
		noPreview = true,
		getText = function(args)
			local value = tonumber(args or 0) or 0;
			return loc("OP_NUMERIC") .. ": " .. value .. "";
		end,
		editor = numericEditor,
	});

	-- Text
	numericEditor.input.title:SetText(loc("OP_NUMERIC"));

	function numericEditor.load(value)
		numericEditor.input:SetText(tonumber(value or 0) or 0);
	end

	function numericEditor.save()
		return tonumber(numericEditor.input:GetText()) or 0;
	end
end

local function boolean_init()
	registerOperandEditor("boolean_true", {
		title = loc("OP_BOOL") .. ": " .. loc("OP_BOOL_TRUE"),
		noPreview = true,
	});
	registerOperandEditor("boolean_false", {
		title = loc("OP_BOOL") .. ": " .. loc("OP_BOOL_FALSE"),
		noPreview = true,
	});
end

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- Unit value operands
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local function unit_name_init()
	registerOperandEditor("unit_name", {
		title = loc("OP_OP_UNIT_NAME"),
		description = loc("OP_OP_UNIT_NAME_TT"),
		returnType = "",
		getText = function(args)
			local unitID = (args or EMPTY)[1] or "target";
			return loc("OP_OP_UNIT_NAME") .. " (" .. getUnitText(unitID) .. ")";
		end,
		editor = unitTypeEditor,
	});
end

local function unit_id_init()
	registerOperandEditor("unit_id", {
		title = loc("OP_OP_UNIT_ID"),
		description = loc("OP_OP_UNIT_ID_TT"),
		returnType = "",
		getText = function(args)
			local unitID = (args or EMPTY)[1] or "target";
			return loc("OP_OP_UNIT_ID") .. " (" .. getUnitText(unitID) .. ")";
		end,
		editor = unitTypeEditor,
	});
end

local function unit_npc_id_init()
	registerOperandEditor("unit_npc_id", {
		title = loc("OP_OP_UNIT_NPC_ID"),
		description = loc("OP_OP_UNIT_NPC_ID_TT"),
		returnType = "",
		getText = function(args)
			local unitID = (args or EMPTY)[1] or "target";
			return loc("OP_OP_UNIT_NPC_ID") .. " (" .. getUnitText(unitID) .. ")";
		end,
		editor = unitTypeEditor,
	});
end

local function unit_guild_init()
	registerOperandEditor("unit_guild", {
		title = loc("OP_OP_UNIT_GUILD"),
		description = loc("OP_OP_UNIT_GUILD_TT"),
		returnType = "",
		getText = function(args)
			local unitID = (args or EMPTY)[1] or "target";
			return loc("OP_OP_UNIT_GUILD") .. " (" .. getUnitText(unitID) .. ")";
		end,
		editor = unitTypeEditor,
	});
end

local function unit_guild_rank_init()
	registerOperandEditor("unit_guild_rank", {
		title = loc("OP_OP_UNIT_GUILD_RANK"),
		description = loc("OP_OP_UNIT_GUILD_RANK_TT"),
		returnType = "",
		getText = function(args)
			local unitID = (args or EMPTY)[1] or "target";
			return loc("OP_OP_UNIT_GUILD_RANK") .. " (" .. getUnitText(unitID) .. ")";
		end,
		editor = unitTypeEditor,
	});
end

local function unit_race_init()
	registerOperandEditor("unit_race", {
		title = loc("OP_OP_UNIT_RACE"),
		description = loc("OP_OP_UNIT_RACE_TT"),
		returnType = "",
		getText = function(args)
			local unitID = (args or EMPTY)[1] or "target";
			return loc("OP_OP_UNIT_RACE") .. " (" .. getUnitText(unitID) .. ")";
		end,
		editor = unitTypeEditor,
	});
end

local function unit_class_init()
	registerOperandEditor("unit_class", {
		title = loc("OP_OP_UNIT_CLASS"),
		description = loc("OP_OP_UNIT_CLASS_TT"),
		returnType = "",
		getText = function(args)
			local unitID = (args or EMPTY)[1] or "target";
			return loc("OP_OP_UNIT_CLASS") .. " (" .. getUnitText(unitID) .. ")";
		end,
		editor = unitTypeEditor,
	});
end

local function unit_sex_init()
	registerOperandEditor("unit_sex", {
		title = loc("OP_OP_UNIT_SEX"),
		description = loc("OP_OP_UNIT_SEX_TT"),
		returnType = "",
		getText = function(args)
			local unitID = (args or EMPTY)[1] or "target";
			return loc("OP_OP_UNIT_SEX") .. " (" .. getUnitText(unitID) .. ")";
		end,
		editor = unitTypeEditor,
	});
end

local function unit_faction_init()
	registerOperandEditor("unit_faction", {
		title = loc("OP_OP_UNIT_FACTION"),
		description = loc("OP_OP_UNIT_FACTION_TT"),
		returnType = "",
		getText = function(args)
			local unitID = (args or EMPTY)[1] or "target";
			return loc("OP_OP_UNIT_FACTION") .. " (" .. getUnitText(unitID) .. ")";
		end,
		editor = unitTypeEditor,
	});
end

local function unit_classification_init()
	registerOperandEditor("unit_classification", {
		title = loc("OP_OP_UNIT_CLASSIFICATION"),
		description = loc("OP_OP_UNIT_CLASSIFICATION_TT"),
		returnType = "",
		getText = function(args)
			local unitID = (args or EMPTY)[1] or "target";
			return loc("OP_OP_UNIT_CLASSIFICATION") .. " (" .. getUnitText(unitID) .. ")";
		end,
		editor = unitTypeEditor,
	});
end

local function unit_health_init()
	registerOperandEditor("unit_health", {
		title = loc("OP_OP_UNIT_HEALTH"),
		description = loc("OP_OP_UNIT_HEALTH_TT"),
		returnType = 0,
		getText = function(args)
			local unitID = (args or EMPTY)[1] or "target";
			return loc("OP_OP_UNIT_HEALTH") .. " (" .. getUnitText(unitID) .. ")";
		end,
		editor = unitTypeEditor,
	});
end

local function unit_level_init()
	registerOperandEditor("unit_level", {
		title = loc("OP_OP_UNIT_LEVEL"),
		description = loc("OP_OP_UNIT_LEVEL_TT"),
		returnType = 0,
		getText = function(args)
			local unitID = (args or EMPTY)[1] or "target";
			return loc("OP_OP_UNIT_LEVEL") .. " (" .. getUnitText(unitID) .. ")";
		end,
		editor = unitTypeEditor,
	});
end

local function unit_speed_init()
	registerOperandEditor("unit_speed", {
		title = loc("OP_OP_UNIT_SPEED"),
		description = loc("OP_OP_UNIT_SPEED_TT"),
		returnType = 0,
		getText = function(args)
			local unitID = (args or EMPTY)[1] or "target";
			return loc("OP_OP_UNIT_SPEED") .. " (" .. getUnitText(unitID) .. ")";
		end,
		editor = unitTypeEditor,
	});
end

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- Unit checks operands
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local function unit_exists_init()
	registerOperandEditor("unit_exists", {
		title = loc("OP_OP_UNIT_EXISTS"),
		description = loc("OP_OP_UNIT_EXISTS_TT"),
		returnType = true,
		getText = function(args)
			local unitID = (args or EMPTY)[1] or "target";
			return loc("OP_OP_UNIT_EXISTS") .. " (" .. getUnitText(unitID) .. ")";
		end,
		editor = unitTypeEditor,
	});
end

local function unit_is_player_init()
	registerOperandEditor("unit_is_player", {
		title = loc("OP_OP_UNIT_ISPLAYER"),
		description = loc("OP_OP_UNIT_ISPLAYER_TT"),
		returnType = true,
		getText = function(args)
			local unitID = (args or EMPTY)[1] or "target";
			return loc("OP_OP_UNIT_ISPLAYER") .. " (" .. getUnitText(unitID) .. ")";
		end,
		editor = unitTypeEditor,
	});
end

local function unit_is_dead_init()
	registerOperandEditor("unit_is_dead", {
		title = loc("OP_OP_UNIT_DEAD"),
		description = loc("OP_OP_UNIT_DEAD_TT"),
		returnType = true,
		getText = function(args)
			local unitID = (args or EMPTY)[1] or "target";
			return loc("OP_OP_UNIT_DEAD") .. " (" .. getUnitText(unitID) .. ")";
		end,
		editor = unitTypeEditor,
	});
end

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- Inventory
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local function inv_item_count_init()
	registerOperandEditor("inv_item_count", {
		title = loc("OP_OP_INV_COUNT"),
		description = loc("OP_OP_INV_COUNT_TT"),
		returnType = 0,
		getText = function(args)
			local id = (args or EMPTY)[1] or "";
			return loc("OP_OP_INV_COUNT_PREVIEW"):format(TRP3_API.inventory.getItemLink(getClass(id)) .. "|cffffff00");
		end,
		editor = itemSelectionEditor,
	});
end

local function inv_item_count_con_init()
	registerOperandEditor("inv_item_count_con", {
		title = loc("OP_OP_INV_COUNT_CON"),
		description = loc("OP_OP_INV_COUNT_CON_TT"),
		returnType = 0,
		getText = function(args)
			local id = (args or EMPTY)[1] or "";
			return loc("OP_OP_INV_COUNT_CON_PREVIEW"):format(TRP3_API.inventory.getItemLink(getClass(id)) .. "|cffffff00");
		end,
		editor = itemSelectionEditor,
	});
end

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- INIT
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

function TRP3_ConditionEditor.initOperands()

	initEnitTypeEditor();
	initItemSelectionEditor();

	string_init();
	boolean_init();
	numeric_init();

	-- Unit string
	unit_name_init();
	unit_id_init();
	unit_npc_id_init();
	unit_guild_init();
	unit_guild_rank_init();
	unit_race_init();
	unit_class_init();
	unit_sex_init();
	unit_faction_init();
	unit_classification_init();

	-- Unit numeric
	unit_health_init();
	unit_level_init();
	unit_speed_init();

	-- Unit checks
	unit_exists_init();
	unit_is_player_init();
	unit_is_dead_init();

	-- Inventory
	inv_item_count_init();
	inv_item_count_con_init();
end