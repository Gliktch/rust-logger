PLUGIN.Title = "Logger"
PLUGIN.Description = "Prints chat history, connection/disconnection events, and commands (if admin) to each player's F1 console."
PLUGIN.Version = "1.5.1"
PLUGIN.Author = "Gliktch"

function PLUGIN:Init()
    print(self.Title .. " v" .. self.Version .. ", by " .. self.Author .. ": Loading...")
    self:LoadConfig()
end

function PLUGIN:PostInit()
    self.flagsmod = plugins.Find("flags")
    self.oxminmod = plugins.Find("oxmin")
    self.logrmod = plugins.Find("logr")
    self.clogmod = plugins.Find("consolelog")
    if (self.oxminmod) then
        self.FLAG_CHATMOD = oxmin.AddFlag("chatmod")
    end
    if ((self.logrmod) and self.Config.AutoDisableLogrMod) then
        -- to do
    end
    if ((self.clogmod) and self.Config.AutoDisableConsoleLogMod) then
        -- to do
    end
    if ((Rust.chat.serverlog) and self.Config.AutoDisableRustChatLog) then
        rust.RunServerCommand("chat.serverlog false")
    end
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

function PLUGIN:LoadConfig()
    local b, res = config.Read("logger")
    self.Config = res or {}
    if (not b) then
        print("Logger: Creating default configuration file...")
        self:LoadDefaultConfig()
        if (res) then config.Save("logger") end
    end
end

function PLUGIN:LoadDefaultConfig()

    self.Config.ConfigVersion = "1.5"
    self.Config.CheckForUpdates = true
    self.Config.AutoDisableLogrMod = true
    self.Config.AutoDisableConsoleLogMod = true
    self.Config.AutoDisableRustChatLog = true
    
    self.Config.TimeStampForServerConsole = true
    self.Config.TimeStampForAdminConsole = true
    self.Config.TimeStampForPlayerConsole = true
    self.Config.TimeStampForLogFiles = true
    self.Config.TimeStampFormat = "dd/mm/yyyy HH:mm"
    
    self.Config.IpStampForServerConsole = true
    self.Config.IpStampForAdminConsole = true
    self.Config.IpStampForPlayerConsole = false
    self.Config.IpStampForLogFiles = true
    
    self.Config.PrintChatToServerConsole = true
    self.Config.PrintChatToAdminConsole = true
    self.Config.PrintChatToPlayerConsole = true
    self.Config.PrintChatToMainLogFile = false
    self.Config.PrintChatToOwnLogFile = false

    self.Config.PrintCommandsToServerConsole = true
    self.Config.PrintCommandsToAdminConsole = true
    self.Config.PrintCommandsToPlayerConsole = false
    self.Config.PrintCommandsToMainLogFile = false
    self.Config.PrintCommandsToOwnLogFile = false

    self.Config.PrintPMsToServerConsole = true
    self.Config.PrintPMsToAdminConsole = true
    self.Config.PrintPMsToPlayerConsole = false
    self.Config.PrintPMsToMainLogFile = false
    self.Config.PrintPMsToOwnLogFile = false
    
    self.Config.PrintConnectionsToServerConsole = true
    self.Config.PrintConnectionsToAdminConsole = true
    self.Config.PrintConnectionsToPlayerConsole = true
    self.Config.PrintConnectionsToMainLogFile = false
    self.Config.PrintConnectionsToOwnLogFile = false

    self.Config.PrintDisconnectionsToServerConsole = true
    self.Config.PrintDisconnectionsToAdminConsole = true
    self.Config.PrintDisconnectionsToPlayerConsole = true
    self.Config.PrintDisconnectionsToMainLogFile = false
    self.Config.PrintDisconnectionsToOwnLogFile = false

    self.Config.PrintExternalEventsToServerConsole = true
    self.Config.PrintExternalEventsToAdminConsole = true
    self.Config.PrintExternalEventsToPlayerConsole = true
    self.Config.PrintExternalEventsToMainLogFile = false
    self.Config.PrintExternalEventsToOwnLogFile = false

    self.Config.MainLogFile = "logger-main"
    self.Config.ChatLogFile = "logger-chat"
    self.Config.CommandsLogFile = "logger-commands"
    self.Config.PMsLogFile = "logger-chat"
    self.Config.ConnectionsLogFile = "logger-logins"
    self.Config.DisconnectionsLogFile = "logger-logins"
    self.Config.ExternalEventsLogFile = "logger-other"

end

function clog( msg, name, msgtype )
    
    local pm = false
    local command = false
    local chat = false
    local connect = false
    local disconnect = false
    local ts = " " .. System.DateTime.Now:ToString(self.Config.TimeStampFormat) .. " "
    
    if (msgtype == "chat") then
        if ( msg:sub( 1, 1 ) == "/" ) then
            if ( (msg:sub( 1, 4 ) == "/pm ") or (msg:sub( 1, 4 ) == "/re ") ) then
                pm = true
                if self.Config.PrintPMsToServerConsole then
                    print( ts .. name .. " sent message " .. msg )
                end
            else
                command = true
                if self.Config.PrintCommandsToServerConsole then
                    if (msg:sub( 1, 8 ) == "/history") then
                        print( ts .. name .. " checked the chat history (" .. msg .. ")" )
                    elseif (msg:sub( 1, 5 ) == "/help") then
                        print( ts .. name .. " is looking for help (" .. msg .. ")" )
                    else
                        print( ts .. name .. " ran command " .. msg )
                    end
                end
            end
        end
        chat = ((not command) and (not pm))
        if (chat and self.Config.PrintChatToServerConsole) then
            print( ts .. "[Chat] " .. msg )
        end
    elseif (msgtype == "connect") then
        connect = true
        if self.Config.PrintConnectionsToServerConsole then
            print( ts .. "[Connection] " .. msg )
        end
        if self.Config.PrintConnectionsToMainLogFile then
            filelog( self.Config.MainLogFile, "[Connection] ", msg )
        end
        if self.Config.PrintConnectionsToOwnLogFile then
            filelog( self.Config.ConnectionsLogFile, "[Connection] ", msg )
        end
    elseif (msgtype == "disconnect") then
        disconnect = true
        if self.Config.PrintDisconnectionsToServerConsole then
            print( ts .. "[Disconnection] " .. msg )
        end
    else
        custom = true
        if self.Config.PrintExternalEventsToServerConsole then
            print( ts .. "[" .. tostring(msgtype) .. "] " .. msg )
        end
    end
    local allplayers = Rust.PlayerClient.All
    local playerlist = allplayers
    local count = playerlist.Count
    for i=0, count - 1 do
        netuser = allplayers[i].netuser
        if ((command) and (self.Config.PrintCommandsToAdminConsole) and self:HasFlag(netuser, "chatmod")) then
            rust.RunClientCommand( netuser, "echo " .. ts .. tostring(name) .. " ran command " .. msg  )
        elseif ((pm) and (self.Config.PrintPMsToAdminConsole) and self:HasFlag(netuser, "chatmod")) then
            rust.RunClientCommand( netuser, "echo " .. ts .. tostring(name) .. " sent message " .. msg  )
        elseif ((not command) and (not pm)) then
            if (not name) then
                rust.RunClientCommand( netuser, "echo " .. ts .. msg  )
            else
                rust.RunClientCommand( netuser, "echo " .. ts .. name .. ": " .. msg  )
            end
        end
    end
end

function filelog( logfile, prefix, msg )
    -- to do
end

function PLUGIN:OnUserConnect( netuser )
    local sid = rust.CommunityIDToSteamID( tonumber( rust.GetUserID( netuser ) ) )
    clog( "User '" .. util.QuoteSafe( netuser.displayName ) .. "' connected with SteamID '" .. sid .. "'", false, "connect" )
end

function PLUGIN:OnUserDisconnect( networkplayer )
    local netuser = networkplayer:GetLocalData()
    if (not netuser or netuser:GetType().Name ~= "NetUser") then return end
    local sid = rust.CommunityIDToSteamID( tonumber( rust.GetUserID( netuser ) ) )
    clog( "User '" .. util.QuoteSafe( netuser.displayName ) .. "' disconnected with SteamID '" .. sid .. "'", false, "disconnect" )
end

function PLUGIN:OnUserChat( netuser, name, msg )
    clog( msg, name, "chat" )
end
