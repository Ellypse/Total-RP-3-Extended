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

local Globals, Events, Utils, EMPTY = TRP3_API.globals, TRP3_API.events, TRP3_API.utils, TRP3_API.globals.empty;
local tostring, tonumber, tinsert, strtrim, pairs, assert, wipe = tostring, tonumber, tinsert, strtrim, pairs, assert, wipe;
local tsize = Utils.table.size;
local getFullID, getClass = TRP3_API.extended.getFullID, TRP3_API.extended.getClass;
local stEtN = Utils.str.emptyToNil;
local loc = TRP3_API.locale.getText;
local setTooltipForSameFrame = TRP3_API.ui.tooltip.setTooltipForSameFrame;
local setTooltipAll = TRP3_API.ui.tooltip.setTooltipAll;
local color = Utils.str.color;
local toolFrame, main, notes, objectives;

local TABS = {
	MAIN = 1,
	WORKFLOWS = 2,
	STEPS = 3,
	INNER = 4,
	EXPERT = 5
}

local tabGroup, currentTab, linksStructure;

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- Quest specifics
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local function onIconSelected(icon)
	main.preview.Icon:SetTexture("Interface\\ICONS\\" .. (icon or "TEMP"));
	main.preview.selectedIcon = icon;
end

local function decorateObjectiveLine(line, objectiveID)
	local data = toolFrame.specificDraft;
	local objectiveData = data.OB[objectiveID];

	line.Name:SetText(objectiveID);
	line.Description:SetText(objectiveData.TX or "");
	line.ID:SetText("");
	if objectiveData.AA then
		line.ID:SetText("|cff00ff00" .. loc("QE_OBJ_AUTO"));
	end
	line.click.objectiveID = objectiveID;
end

local function refreshObjectiveList()
	local data = toolFrame.specificDraft;
	TRP3_API.ui.list.initList(objectives.list, data.OB, objectives.list.slider);
	objectives.list.empty:Hide();
	if tsize(data.OB) == 0 then
		objectives.list.empty:Show();
	end
end

local function newObjective()
	objectives.editor.oldID = nil;
	objectives.editor.id:SetText("");
	objectives.editor.text:SetText("");
	objectives.editor.auto:SetChecked(false);
	TRP3_API.ui.frame.configureHoverFrame(objectives.editor, objectives.list.add, "TOP", 0, 5, false);
end

local function editObjective(objectivesID, frame)
	if not objectivesID then
		newObjective();
	else
		local objectivesData = toolFrame.specificDraft.OB[objectivesID];
		if objectivesData then
			objectives.editor.oldID = objectivesID;
			objectives.editor.id:SetText(objectivesID);
			objectives.editor.text:SetText(objectivesData.TX or "");
			objectives.editor.auto:SetChecked(objectivesData.AA);
			TRP3_API.ui.frame.configureHoverFrame(objectives.editor, frame, "RIGHT", 0, 5, false);
		else
			newObjective();
		end
	end
end

local function onObjectiveSaved()
	local oldID = objectives.editor.oldID;
	local ID = strtrim(objectives.editor.id:GetText());
	local data = {
		TX = stEtN(strtrim(objectives.editor.text:GetText())),
		AA = objectives.editor.auto:GetChecked();
	}
	if ID then
		local structure = toolFrame.specificDraft.OB;
		if oldID and structure[oldID] then
			wipe(structure[oldID]);
			structure[oldID] = nil;
		end
		structure[ID] = data;
	end

	refreshObjectiveList();
	objectives.editor:Hide();
end

local function removeObjective(id)
	TRP3_API.popup.showConfirmPopup(loc("QE_OBJ_REMOVE"), function()
		if toolFrame.specificDraft.OB[id] then
			wipe(toolFrame.specificDraft.OB[id]);
			toolFrame.specificDraft.OB[id] = nil;
		end
		refreshObjectiveList();
		objectives.editor:Hide();
	end);
end

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- Script & inner & links tabs
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local function loadDataScript()
	-- Load workflows
	if not toolFrame.specificDraft.SC then
		toolFrame.specificDraft.SC = {};
	end
	TRP3_ScriptEditorNormal.loadList(TRP3_DB.types.QUEST);
end

local function storeDataScript()
	-- TODO: compute all workflow order
	for workflowID, workflow in pairs(toolFrame.specificDraft.SC) do
		TRP3_ScriptEditorNormal.linkElements(workflow);
	end
end

local function loadDataInner()
	-- Load inners
	if not toolFrame.specificDraft.IN then
		toolFrame.specificDraft.IN = {};
	end
	TRP3_InnerObjectEditor.refresh();
end

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- Load ans save
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local function load()
	assert(toolFrame.rootClassID, "rootClassID is nil");
	assert(toolFrame.fullClassID, "fullClassID is nil");
	assert(toolFrame.rootDraft, "rootDraft is nil");
	assert(toolFrame.specificDraft, "specificDraft is nil");

	toolFrame.quest:Show();

	local data = toolFrame.specificDraft;
	if not data.BA then
		data.BA = {};
	end
	if not data.OB then
		data.OB = {};
	end
	if not data.ST then
		data.ST = {};
	end

	notes.frame.scroll.text:SetText(data.NT or "");
	main.name:SetText(data.BA.NA or "");
	main.description.scroll.text:SetText(data.BA.DE or "");
	onIconSelected(data.BA.IC);
	refreshObjectiveList();

	loadDataScript();
	loadDataInner();
	TRP3_LinksEditor.load(linksStructure);

	TRP3_ActionsEditorFrame.load();

	tabGroup:SelectTab(TRP3_Tools_Parameters.editortabs[toolFrame.fullClassID] or TABS.MAIN);
end

local function saveToDraft()
	assert(toolFrame.specificDraft, "specificDraft is nil");

	local data = toolFrame.specificDraft;
	data.NT = stEtN(strtrim(notes.frame.scroll.text:GetText()));
	data.BA.NA = stEtN(strtrim(main.name:GetText()));
	data.BA.DE = stEtN(strtrim(main.description.scroll.text:GetText()));
	data.BA.IC = main.preview.selectedIcon;

	storeDataScript();
end

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- UI
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local function onTabChanged(tabWidget, tab)
	assert(toolFrame.fullClassID, "fullClassID is nil");

	-- Hide all
	currentTab = tab or TABS.MAIN;
	main:Hide();
	notes:Hide();
	objectives:Hide();
	TRP3_ActionsEditorFrame:Hide();
	TRP3_ScriptEditorNormal:Hide();
	TRP3_InnerObjectEditor:Hide();
	TRP3_LinksEditor:Hide();

	-- Show tab
	if currentTab == TABS.MAIN then
		main:Show();
		notes:Show();
		objectives:Show();
	elseif currentTab == TABS.WORKFLOWS then
		TRP3_ScriptEditorNormal:SetParent(toolFrame.quest);
		TRP3_ScriptEditorNormal:SetAllPoints();
		TRP3_ScriptEditorNormal:Show();
	elseif currentTab == TABS.STEPS then

	elseif currentTab == TABS.INNER then
		TRP3_InnerObjectEditor:SetParent(toolFrame.quest);
		TRP3_InnerObjectEditor:SetAllPoints();
		TRP3_InnerObjectEditor:Show();
	elseif currentTab == TABS.EXPERT then
		TRP3_LinksEditor:SetParent(toolFrame.quest);
		TRP3_LinksEditor:SetAllPoints();
		TRP3_LinksEditor:Show();
		TRP3_LinksEditor.load(linksStructure);
		TRP3_ActionsEditorFrame:Show();
	end

	TRP3_Tools_Parameters.editortabs[toolFrame.fullClassID] = currentTab;
end

local function createTabBar()
	local frame = CreateFrame("Frame", "TRP3_ToolFrameQuestNormalTabPanel", toolFrame.quest);
	frame:SetSize(400, 30);
	frame:SetPoint("BOTTOMLEFT", frame:GetParent(), "TOPLEFT", 15, 0);

	tabGroup = TRP3_API.ui.frame.createTabPanel(frame,
		{
			{ loc("EDITOR_MAIN"), TABS.MAIN, 150 },
			{ loc("QE_STEPS"), TABS.STEPS, 150 },
			{ loc("IN_INNER"), TABS.INNER, 150 },
			{ loc("WO_WORKFLOW"), TABS.WORKFLOWS, 150 },
			{ loc("WO_LINKS"), TABS.EXPERT, 150 },
		},
		onTabChanged
	);
end

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- INIT
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

function TRP3_API.extended.tools.initQuest(ToolFrame)
	toolFrame = ToolFrame;
	toolFrame.quest.onLoad = load;
	toolFrame.quest.onSave = saveToDraft;

	createTabBar();

	--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
	-- MAIN
	--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

	-- Main
	main = toolFrame.quest.main;
	main.title:SetText(loc("TYPE_QUEST"));

	-- Name
	main.name.title:SetText(loc("QE_NAME"));
	setTooltipForSameFrame(main.name.help, "RIGHT", 0, 5, loc("QE_NAME"), loc("QE_NAME_TT"));

	-- Description
	main.description.title:SetText(loc("QE_DESCRIPTION"));
	setTooltipAll(main.description.dummy, "RIGHT", 0, 5, loc("QE_DESCRIPTION"), loc("QE_DESCRIPTION_TT"));

	-- Preview
	main.preview.Name:SetText(loc("EDITOR_PREVIEW"));
	main.preview.InfoText:SetText(loc("EDITOR_ICON_SELECT"));
	main.preview:SetScript("OnClick", function(self)
		TRP3_API.popup.showPopup(TRP3_API.popup.ICONS, {parent = self, point = "RIGHT", parentPoint = "LEFT"}, {onIconSelected});
	end);

	--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
	-- NOTES
	--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

	-- Notes
	notes = toolFrame.quest.notes;
	notes.title:SetText(loc("EDITOR_NOTES"));

	--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
	-- OBJECTIVES
	--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

	-- Objectives
	objectives = toolFrame.quest.objectives;
	objectives.title:SetText(loc("QE_OBJ"));

	objectives.help:SetText(loc("WO_ACTIONS_LINKS_TT"));

	-- List
	objectives.list.widgetTab = {};
	for i=1, 4 do
		local line = objectives.list["line" .. i];
		tinsert(objectives.list.widgetTab, line);
		line.click:SetScript("OnClick", function(self, button)
			if button == "RightButton" then
				removeObjective(self.objectiveID);
			else
				editObjective(self.objectiveID, self);
			end
		end);
		line.click:SetScript("OnEnter", function(self)
			TRP3_RefreshTooltipForFrame(self);
			self:GetParent().Highlight:Show();
		end);
		line.click:SetScript("OnLeave", function(self)
			TRP3_MainTooltip:Hide();
			self:GetParent().Highlight:Hide();
		end);
		line.click:RegisterForClicks("LeftButtonUp", "RightButtonUp");
		setTooltipForSameFrame(line.click, "RIGHT", 0, 5, loc("CA_ACTIONS"),
			("|cffffff00%s: |cff00ff00%s\n"):format(loc("CM_CLICK"), loc("CM_EDIT"))
					.. ("|cffffff00%s: |cff00ff00%s"):format(loc("CM_R_CLICK"), REMOVE));
	end
	objectives.list.decorate = decorateObjectiveLine;
	TRP3_API.ui.list.handleMouseWheel(objectives.list, objectives.list.slider);
	objectives.list.slider:SetValue(0);
	objectives.list.add:SetText(loc("QE_OBJ_ADD"));
	objectives.list.add:SetScript("OnClick", function() editObjective() end);
	objectives.list.empty:SetText(loc("QE_OBJ_NO"));

	-- Editor
	objectives.editor.title:SetText(loc("QE_OBJ_SINGULAR"));
	objectives.editor.save:SetScript("OnClick", function(self)
		onObjectiveSaved();
	end);
	objectives:SetScript("OnHide", function() objectives.editor:Hide() end);
	objectives.editor.id.title:SetText(loc("QE_OBJ_ID"));
	setTooltipForSameFrame(objectives.editor.id.help, "RIGHT", 0, 5, loc("QE_OBJ_ID"), loc("QE_OBJ_ID_TT"));
	objectives.editor.text.title:SetText(loc("QE_OBJ_TEXT"));

	-- Auto add
	objectives.editor.auto.Text:SetText(loc("QE_OBJ_AUTO"));
	setTooltipForSameFrame(objectives.editor.auto, "RIGHT", 0, 5, loc("QE_OBJ_AUTO"), loc("QE_OBJ_AUTO_TT"));

	-- Links
	linksStructure = {
		{
			text = loc("QE_LINKS_ON_START"),
			tt = loc("QE_LINKS_ON_START_TT"),
			icon = "Interface\\ICONS\\achievement_quests_completed_02",
			field = "OS",
		}
	}

end