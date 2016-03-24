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
local wipe, pairs, tostring, tinsert, tonumber = wipe, pairs, tostring, tinsert, tonumber;
local tsize = Utils.table.size;
local getClass = TRP3_API.extended.getClass;
local stEtN = Utils.str.emptyToNil;
local loc = TRP3_API.locale.getText;
local setTooltipForSameFrame = TRP3_API.ui.tooltip.setTooltipForSameFrame;

local delayEditor = TRP3_ScriptEditorDelay;

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- Delay
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

function delayEditor.save(scriptStepStructure)
	scriptStepStructure.d = tonumber(delayEditor.duration:GetText()) or 1;
	scriptStepStructure.c = delayEditor.type:GetSelectedValue() or 1;
	scriptStepStructure.i = delayEditor.interrupt:GetSelectedValue() or 1;
end

function delayEditor.load(scriptStepStructure)
	delayEditor.type:SetSelectedValue(scriptStepStructure.c or 1);
	delayEditor.interrupt:SetSelectedValue(scriptStepStructure.i or 1);
	delayEditor.duration:SetText(scriptStepStructure.d or 0);
end

function delayEditor.init()
	local listFormat = "%s: |cff00ff00%s";

	-- Duration
	delayEditor.duration.title:SetText("Duration"); -- TODO: locals
	setTooltipForSameFrame(delayEditor.duration.help, "RIGHT", 0, 5, "Duration", "The duration for this delay, in seconds.");  -- TODO: locals

	-- Delay type
	local type = {
		{listFormat:format("Delay type", "Regular delay"), 1} -- TODO: locals
	}
	TRP3_API.ui.listbox.setupListBox(delayEditor.type, type, nil, nil, 200, true);

	-- Interruption
	local type = {
		{listFormat:format("Interruption", "No interruption"), 1} -- TODO: locals
	}
	TRP3_API.ui.listbox.setupListBox(delayEditor.interrupt, type, nil, nil, 200, true);
end