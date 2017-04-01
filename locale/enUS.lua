-- **********************************************************************
-- GnomTEC Marches Localization - enUS / enGB
-- Version: 7.2.0.1
-- Author: Peter Jack
-- URL: http://www.gnomtec.de/
-- **********************************************************************
-- Copyright © 2015-2017 by Peter Jack
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
local AceLocale = LibStub:GetLibrary("AceLocale-3.0")
local L = AceLocale:NewLocale("GnomTEC_Marches", "enUS", true)
if not L then return end

L["L_OPTIONS_TITLE"] = "GnomTEC Marches.\n\n"

L["L_EMOTE_TROOP"] = "|| The whole squad sing: "

-- each verse is build by {participant, mode, delay, text}
-- participant: 	number of participant who should sing or 0 for all participants
-- mode:				default mode how participants should sing, if not all are singing set this to 1
--						0: The "refrain" is emoted by one random participant for all
--						1: The "refrain" is sung only by one (random) participant
--						2: The "refrain" is sung only by one (random) participant (except participant one)
--						3: The "refrain" is sung by all participants (SPAM!)
--						4: The "refrain" is sung by all participants (SPAM!) (except participant one)
-- delay:			seconds to wait between each verse
--	text:				the text of the verse to sing
L["L_MARCHES"] = {
	["Gnomisch Grenadier"] = {
		{0, 1, 5, "Gnomisch' Grenadier, wir marschieren hier! Lunte an, Stift gezogen, kommt der Tod geflogen!"},
		{0, 1, 5, "Gnomisch' Grenadier, im Laufschritt - drei, vier! Der Himmel düster, die Erde grau, der einschlag wird ein Supergau!"},
		{0, 1, 5, "Gnomisch' Grenadier, mit dem Tode spielen wir! Feind schau nach oben, wenn du's siehst hast du verloren!"},
		{0, 1, 5, "Gnomisch' Grenadier, im Laufschritt - drei, vier! Die Explosion - sie leuchtet Hell, schleudert um sich das Schrappnell!"},
		{0, 1, 5, "Gnomisch' Grenadier, ja Gnome - das sind wir! im Rauche geht er unter, das Donnern macht uns Munter!"},
		{0, 1, 5, "Gnomisch' Grenadier, im Laufschritt - drei, vier! unser aller ist der Sieg, verloren hat, der Feind den Krieg!"}
	}
}
