PLUGIN.Title = "Logger"
PLUGIN.Description = "Prints chat history, connection/disconnection events, and commands (if admin) to each player's F1 console."
PLUGIN.Version = "1.2.2"
PLUGIN.Author = "Gliktch"

function PLUGIN:Init()
    print(self.Title .. " v" .. self.Version .. ", by " .. self.Author .. ": Loading...")
end

function PLUGIN:PostInit()
    self.oxminmod = plugins.Find("oxmin")
    if (self.oxminmod) then
        self.FLAG_CHATMOD = oxmin.AddFlag("chatmod")
    end
    self.flagsmod = plugins.Find("flags")
end

function PLUGIN:HasFlag(netuser, flag)
    if (netuser:CanAdmin()) then
        do return true end
    elseif ((self.oxminmod ~= nil) and (self.oxminmod:HasFlag(netuser, flag))) then
        do return true end
    elseif ((self.flagsmod ~= nil) and (self.flagsmod:HasFlag(netuser, flag))) then
        do return true end
    end
    return false
end

function clog( msg, name, pass )
    local command = false
    if ( msg:sub( 1, 1 ) == "/" ) then
        command = true
        print( name .. " ran command " .. msg )
    end
    local PlayerClientAll = Rust.PlayerClient.All
    local pclist = PlayerClientAll
    local count = pclist.Count
    for i=0, count - 1 do
        netuser = PlayerClientAll[i].netuser
        if (command) then
            if (netuser:CanAdmin()) then
                rust.RunClientCommand( netuser, "echo " .. name .. " ran command " .. msg  )
            end
        else
            if (pass) then
                rust.RunClientCommand( netuser, "echo " .. msg  )
            else
                rust.RunClientCommand( netuser, "echo " .. name .. ": " .. msg  )
            end
        end
    end
end

function PLUGIN:OnUserConnect( netuser )
    local sid = rust.CommunityIDToSteamID( tonumber( rust.GetUserID( netuser ) ) )
    clog( "User '" .. util.QuoteSafe( netuser.displayName ) .. "' connected with SteamID '" .. sid .. "'", "dummy", true )
end

function PLUGIN:OnUserDisconnect( networkplayer )
    local netuser = networkplayer:GetLocalData()
    if (not netuser or netuser:GetType().Name ~= "NetUser") then return end
    local sid = rust.CommunityIDToSteamID( tonumber( rust.GetUserID( netuser ) ) )
    clog( "User '" .. util.QuoteSafe( netuser.displayName ) .. "' disconnected with SteamID '" .. sid .. "'", "dummy", true )
end

function PLUGIN:OnUserChat( netuser, name, msg )
    clog( msg, name )
end
