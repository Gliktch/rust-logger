PLUGIN.Title = "Console Log"
PLUGIN.Description = "Prints when players chat or join to every connected clients console"

function clog( arg )

    local PlayerClientAll = RustFirstPass.PlayerClient.All

    local pclist = PlayerClientAll
    local count = pclist.Count

    for i=0, count - 1 do
            rust.RunClientCommand( PlayerClientAll[i].netuser, "echo " .. arg  )
    end
   
end

function PLUGIN:OnUserConnect( netuser )
    clog( util.QuoteSafe( netuser.displayName ) .. " has joined the game")
    print( util.QuoteSafe( netuser.displayName ) .. " has joined the game")
end

function PLUGIN:OnUserDisconnect( netuser )
    clog( util.QuoteSafe( netuser.displayName ) .. " has left the game")
    print( util.QuoteSafe( netuser.displayName ) .. " has left the game")
end

function PLUGIN:OnUserChat( netuser, name, msg )
    if (msg:sub( 1, 1 ) == "/") then
        return
    else
        clog( util.QuoteSafe( netuser.displayName ) .. ": " .. msg)
        print( util.QuoteSafe( netuser.displayName ) .. ": " .. msg)
    end
end
