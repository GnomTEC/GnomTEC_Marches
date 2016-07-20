-- **********************************************************************
-- GnomTEC Marches
-- Version: 7.0.3.1
-- Author: Peter Jack
-- URL: http://www.gnomtec.de/
-- **********************************************************************
-- Copyright © 2015-2016 by Peter Jack
--
-- Licensed under the EUPL, Version 1.1 only (the "Licence");
-- You may not use this work except in compliance with the Licence.
-- You may obtain a copy of the Licence at:
--
-- http://ec.europa.eu/idabc/eupl5
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the Licence is distributed on an "AS IS" basis,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the Licence for the specific language governing permissions and
-- limitations under the Licence.
-- **********************************************************************
-- load localization first.
local L = LibStub("AceLocale-3.0"):GetLocale("GnomTEC_Marches")

-- ----------------------------------------------------------------------
-- Addon Info Constants (local)
-- ----------------------------------------------------------------------
-- addonInfo for addon registration to GnomTEC API
local addonInfo = {
	["Name"] = "GnomTEC Marches",
	["Description"] = "GnomTEC Marches.",	
	["Version"] = "7.0.3.1",
	["Date"] = "2016-07-20",
	["Author"] = "Peter Jack",
	["Email"] = "info@gnomtec.de",
	["Website"] = "http://www.gnomtec.de/",
	["Copyright"] = "© 2015-2106 by Peter Jack",
	["License"] = "European Union Public Licence (EUPL v.1.1)",	
	["FrameworkRevision"] = 4
}

-- ----------------------------------------------------------------------
-- Addon Global Constants (local)
-- ----------------------------------------------------------------------
-- Class levels
local CLASS_BASE		= 0
local CLASS_CLASS		= 1
local CLASS_WIDGET	= 2
local CLASS_ADDON		= 3

-- Log levels
local LOG_FATAL 	= 0
local LOG_ERROR	= 1
local LOG_WARN		= 2
local LOG_INFO 	= 3
local LOG_DEBUG 	= 4

-- Refrain modes
local MODE_EMOTE				= 0	-- The refrain is emoted by one random participant for all
local MODE_SINGLE				= 1	-- The refrain is sung only by one random participant
local MODE_SINGLE_EXCEPT	= 2	-- The refrain is sung only by one random participant except participant one
local MODE_SPAM				= 3	-- The refrain is sung by all participants
local MODE_SPAM_EXCEPT		= 4	-- The refrain is sung by all participants except participant one

-- ----------------------------------------------------------------------
-- Addon Static Variables (local)
-- ----------------------------------------------------------------------
local addonDataObject =	{
	type = "data source",
	text = "0 marches",
	value = "0",
	suffix = "warning(s)",
	label = "GnomTEC Marches",
	icon = [[Interface\Icons\INV_Misc_GroupNeedMore]],
	OnClick = function(self, button)
		GnomTEC_Marches.SwitchMainWindow()
	end,
	OnTooltipShow = function(tooltip)
		GnomTEC_Marches.ShowAddonTooltip(tooltip)
	end,
}

-- ----------------------------------------------------------------------
-- Addon Startup Initialization
-- ----------------------------------------------------------------------


-- ----------------------------------------------------------------------
-- Helper Functions (local)
-- ----------------------------------------------------------------------

-- ----------------------------------------------------------------------
-- Addon Class
-- ----------------------------------------------------------------------

local function GnomTECMarches()
	-- call base class
	local self, protected = GnomTECAddon("GnomTEC_Marches", addonInfo)
	
	-- when we got nil from base class there is a major issue and we will stop here.
	-- GnomTEC framework will inform the user by itself about the issue.
	if (nil == self) then
		return self
	end
	
	-- public fields go in the instance table
	-- self.field = value

	-- protected fields go in the protected table
	-- protected.field = value
	
	-- private fields are implemented using locals
	-- they are faster than table access, and are truly private, so the code that uses your class can't get them
	-- local field
	local mainWindowWidgets = nil
	
	local actualMarch = nil
	local actualVerse = 1
	local actualMode = nil	
	local participant = {}
	
	local chat = GnomTECClassChat();


	-- private methods
	-- local function f()
	local function OnClickMainWindowStartMarch(widget, button)
		actualMarch = widget.GetLabel()
		actualVerse = 1
		participant = {}
		
		chat.Say("Ein Lied … 2 … 3 … 4!")
	end

	local function OnClickMainWindowStopMarch(widget, button)
		actualMarch = nil
		actualVerse = 1
		participant = {}
	end
	
	local function SendVerseToParticipants()
		if (actualMarch) then
			local data = {}
			local receiver = L["L_MARCHES"][actualMarch][actualVerse][1]
			local numParticipants = #participant
			data.march = actualMarch
			data.verse = actualVerse
			data.mode = L["L_MARCHES"][actualMarch][actualVerse][2]		-- actualMode should be manipulating this later
			
			if ( receiver ~= 0) then
				-- this should be sung by a defined participant
				self.Broadcast(data, "WHISPER", participant[receiver % (numParticipants + 1)])
			else
				if ((data.mode == MODE_EMOTE) or (data.mode == MODE_SINGLE) or (data.mode == MODE_SINGLE_EXCEPT)) then
					-- this should be sung only by one random person
					if (numParticipants >= 2) then
						if (data.mode == MODE_SINGLE) then
							-- this is not an real refrain, everybody can sing it
							receiver = random(1, numParticipants + 1)
						else
							-- participant one should not sing real refrains
							receiver = random(2, numParticipants + 1)
						end
					else
						-- only one participant, so he has to do all the work!
						receiver = 1
						data.mode = MODE_SINGLE
					end
					self.Broadcast(data, "WHISPER", participant[receiver])
				else
					-- ok, lets spam... all participant will sing!
					for idx, value in ipairs(participant) do
						if ((idx ~= 1) or (data.mode ~= MODE_SPAM_EXCEPT)) then
							self.Broadcast(data, "WHISPER", participant[idx])
						end
					end
				end
			end

			if (actualVerse < #(L["L_MARCHES"][actualMarch])) then
				self.ScheduleTimer(SendVerseToParticipants, L["L_MARCHES"][actualMarch][actualVerse][3])
				actualVerse = actualVerse + 1	
			end
		end
	end

	-- protected methods
	-- function protected.f()
	function protected.OnInitialize()
	 	-- Code that you want to run when the addon is first loaded goes here.
	end

	function protected.OnEnable()
  	  -- Called when the addon is enabled
				
		addonDataObject = self.NewDataObject("", addonDataObject)
		
		self.ShowMinimapIcon(addonDataObject)
	end

	function protected.OnDisable()
		-- Called when the addon is disabled
	end
	
	-- public methods
	-- function self.f()
	function self.OnBroadcast(data, sender)
		if (data.participate and actualMarch) then
			table.insert(participant, sender) 
			if (#participant == 1) then
				SendVerseToParticipants()
			end	
		elseif (data.march) then
			if (L["L_MARCHES"][data.march]) then
				if (data.mode == MODE_EMOTE) then
					self.Emote(L["L_EMOTE_TROOP"]..'"'..(L["L_MARCHES"][data.march][data.verse][4] or "")..'"')
				else
					chat.Say(L["L_MARCHES"][data.march][data.verse][4] or "")
				end
			end
		end
	end
	
	function chat.OnSay(message, sender)
		if (message == "Ein Lied … 2 … 3 … 4!") then
			local data = {}
			data.participate = true
			self.Broadcast(data, "WHISPER", sender)
		end
	end
	
	
	function self.SwitchMainWindow(show)
		if (not mainWindowWidgets) then
			mainWindowWidgets = {}
			mainWindowWidgets.mainWindow = GnomTECWidgetContainerWindow({title="GnomTEC Marches", name="Main", db=self.db})
			mainWindowWidgets.mainWindowLayout = GnomTECWidgetContainerLayoutVertical({parent=mainWindowWidgets.mainWindow})
			mainWindowWidgets.mainWindowTopSpacer = GnomTECWidgetSpacer({parent=mainWindowWidgets.mainWindowLayout, minHeight=34, minWidth=50})
			mainWindowWidgets.mainWindowStartMarch = {}
			for key, value in pairs(L["L_MARCHES"]) do
				mainWindowWidgets.mainWindowStartMarch[key] = GnomTECWidgetPanelButton({parent=mainWindowWidgets.mainWindowLayout, label=key})
				mainWindowWidgets.mainWindowStartMarch[key].OnClick = OnClickMainWindowStartMarch
			end
			mainWindowWidgets.mainWindowBottomSpacer = GnomTECWidgetSpacer({parent=mainWindowWidgets.mainWindowLayout, height="100%"})
			mainWindowWidgets.mainWindowStopMarch = GnomTECWidgetPanelButton({parent=mainWindowWidgets.mainWindowLayout, label="Stop it!"})
			mainWindowWidgets.mainWindowStopMarch.OnClick = OnClickMainWindowStopMarch
		end
		
		if (nil == show) then
			if mainWindowWidgets.mainWindow.IsShown() then
				mainWindowWidgets.mainWindow.Hide()
			else
				mainWindowWidgets.mainWindow.Show()
			end
		else
			if show then
				mainWindowWidgets.mainWindow.Show()
			else
				mainWindowWidgets.mainWindow.Hide()
			end
		end
	end
	
		
	function	self.ShowAddonTooltip(tooltip)
		tooltip:AddLine("GnomTEC Marches Informationen",1.0,1.0,1.0)
		tooltip:AddLine(" ")
		tooltip:AddLine("Sing a march.",1.0,1.0,1.0)
	end
	
	-- constructor
	do
		self.SwitchMainWindow(false)
		self.LogMessage(LOG_INFO, "Willkommen bei GnomTEC Marches")
	end
	
	-- return the instance table
	return self
end

-- ----------------------------------------------------------------------
-- Addon Instantiation
-- ----------------------------------------------------------------------

GnomTEC_Marches = GnomTECMarches()
