--!strict
type SoundMap = {
    Radio: Sound?
}

type IRadio = {
    ActiveSounds: SoundMap,
    RadioPlaylist: {string},
    CurrentTrackIndex: number,
    LoopPlaylist: boolean,
    RadioPlaying: boolean,

    LoadPlaylist: (self: IRadio, playlist: {string}) -> (),
    PlayNextTrack: (self: IRadio) -> (),
    PlayRadioTrack: (self: IRadio, trackName: string) -> (),
    PlayCurrentTrack: (self: IRadio) -> (),
    SkipTrack: (self: IRadio) -> (),
    StopRadio: (self: IRadio) -> (),
    ToggleLooping: (self: IRadio) -> (),
    UpdateInterface: (self: IRadio) -> (),
    ShowFeedback: (self: IRadio, data: string) -> (),
}

-- SERVICES --
----------------------------------------
local Workspace = game:GetService('Workspace')

-- MODULE --
----------------------------------------
local Radio: IRadio = {} :: IRadio

-- STATES --
----------------------------------------
Radio.ActiveSounds = {}
Radio.RadioPlaylist = {}
Radio.CurrentTrackIndex = 0
Radio.LoopPlaylist = false 

-- TEMPLATE VARIABLES --
----------------------------------------
local MusicFolder = script.Parent.Music

-- FUNCTIONS --
----------------------------------------
function Radio:LoadPlaylist(playlist: {string}): () --// Initializes the playlist (can be stored elsewhere)
    self:StopRadio()

    self.RadioPlaylist = playlist 
    self.CurrentTrackIndex = 1
end

function Radio:PlayNextTrack(): () --// Plays the next track or stops based on loop state
    if #self.RadioPlaylist == 0 or self.CurrentTrackIndex == nil then 
        return 
    end
    self.CurrentTrackIndex += 1

    if self.CurrentTrackIndex > #self.RadioPlaylist then
        if self.LoopPlaylist then
            self.CurrentTrackIndex = 1
        else 
            self:StopRadio()
            return
        end
    end
    self:PlayRadioTrack(self.RadioPlaylist[self.CurrentTrackIndex])
end

function Radio:PlayRadioTrack(trackName: string)
    if self.ActiveSounds.Radio then
        self.ActiveSounds.Radio:Stop()
        self.ActiveSounds.Radio:Destroy()
        self.ActiveSounds.Radio = nil
    end

   local track = MusicFolder:WaitForChild(trackName) :: Sound
   if not track then 
        warn("Track not found: ".. trackName)
        return
    end

    track = track:Clone() 
    track.Parent = Workspace -- Replace this with a folder where sounds are stored

    local temp: RBXScriptConnection?
    temp = track.Ended:Connect(function()
        self:PlayNextTrack()

        if temp then
            temp:Disconnect()
            temp = nil
        end
    end)

    track:Play()

    self.ActiveSounds.Radio = track
    self.RadioPlaying = true
end

function Radio:StopRadio()
    if self.ActiveSounds.Radio then
		self.ActiveSounds.Radio:Stop()
		self.ActiveSounds.Radio:Destroy()
		self.ActiveSounds.Radio = nil
	end
	self.RadioPlaying = false
end

function Radio:ToggleLooping()
    self.LoopPlaylist = not self.LoopPlaylist
end

function Radio:SkipTrack()
    if #self.RadioPlaylist == 0 then
        return 
    end

    if self.CurrentTrackIndex < #self.RadioPlaylist then
        self:PlayNextTrack()
    else 
        self.CurrentTrackIndex = 1
        self:PlayCurrentTrack()
    end
end

function Radio:PlayCurrentTrack()
    if self.CurrentTrackIndex ~= nil and self.CurrentTrackIndex > 0 and self.CurrentTrackIndex <= #self.RadioPlaylist then 
        self:PlayRadioTrack(self.RadioPlaylist[self.CurrentTrackIndex])
    else 
        warn("Track index is invalid")
    end
end

--// Allows Interface updates
function Radio:UpdateInterface()
    return true
end

function Radio:ShowFeedback(data: string)
    return data
end

return Radio