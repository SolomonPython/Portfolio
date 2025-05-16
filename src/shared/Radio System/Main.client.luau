--!strict

-- MODULES --
---------------------------------------------
local RadioModule = require(script.Parent.Radio)
local Playlist = require(script.Parent.Config)

RadioModule:LoadPlaylist(Playlist)
RadioModule:PlayNextTrack()