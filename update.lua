ArkadiaEditor.updateCheck = ArkadiaEditor.updateCheck or {
    file = getMudletHomeDir() .. "/plugins/arkadia-cfg-editor/commits",
    url = "https://api.github.com/repos/Delwing/arkadia-cfg-editor/commits",
    storeKey = "ArkadiaEditor"
}

function ArkadiaEditor.updateCheck:checkNewVersion()
    downloadFile(self.file, self.url)
    registerAnonymousEventHandler("sysDownloadDone", function(_, file)
        self:handle(file)
    end, true)
end

function ArkadiaEditor.updateCheck:handle(fileName)
    if fileName ~= self.file then
        return
    end


    local ArkadiaEditorState = scripts.state_store:get(self.storeKey) or {}

    local file, s, contents = io.open(self.file)
    if file then
        contents = yajl.to_value(file:read("*a"))
        io.close(file)
        os.remove(self.file)
        local sha = contents[1].sha
        if ArkadiaEditorState.sha ~= nil and sha ~= ArkadiaEditorState.sha then
            echo("\n")
            cecho("<CadetBlue>(skrypty)<tomato>: Plugin arkadia-cfg-editor posiad nowa aktualizacje. Kliknij ")
            cechoLink("<green>tutaj", [[ArkadiaEditor.updateCheck:update()]], "Aktualizuj", true)
            cecho(" <tomato>aby pobrac")
            echo("\n")
        end
        ArkadiaEditorState.sha = sha
        scripts.state_store:set(self.storeKey, ArkadiaEditorState)
    end
end

function ArkadiaEditor.updateCheck:update()
    scripts.plugins_installer:install_from_url("https://codeload.github.com/Delwing/arkadia-cfg-editor/zip/master")
end

tempTimer(5, function() ArkadiaEditor.updateCheck:checkNewVersion() end)


