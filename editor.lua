ArkadiaEditor = ArkadiaEditor or {}

local pluginDir = getMudletHomeDir() .. "/plugins/arkadia-cfg-editor"
local current_version_file = pluginDir .. "/version.dat"
local editorBinaryBase = pluginDir .. "/editor."
local apiUrl = "https://api.github.com/repos/Delwing/arkadia-config-editor/releases/latest"

function ArkadiaEditor:checkVersion()
    if mudletOlderThan(4, 10) then
        return
    end
    if io.exists(self:getBinary()) then
        getHTTP(apiUrl)
        registerAnonymousEventHandler('sysGetHttpDone', function(event, url, response) self:versionCompare(url, response) end, true)
    end
end

function ArkadiaEditor:versionCompare(url, response)
    if url ~= apiUrl then
        return true
    end

    local responseObj = yajl.to_value(response)

    if responseObj.tag_name ~= self:getBinaryVersion() then
        scripts:print_log("<SpringGreen>===> Zalecana aktualizacja edytora konfiguracji.", true)
        local command = "ArkadiaEditor:getLatestInformation()"
        cechoLink("<CadetBlue>(skrypty)<SpringGreen>: Kliknij tutaj aby pobrac.", command,"Pobierz", true)
    end

end

function ArkadiaEditor:getLatestInformation()
    getHTTP(apiUrl)
    registerAnonymousEventHandler('sysGetHttpDone', function(event, url, response) self:determineAssetToDownload(url, response) end, true)
end

function ArkadiaEditor:determineAssetToDownload(url, response)
    if url ~= apiUrl then
        return true
    end

    local responseObj = yajl.to_value(response)
    for _, asset in pairs(responseObj.assets) do
        if  asset.name:gmatch(string.format(".%s$", self:getExtension()))() then
            self:storeBinaryVersion(responseObj.tag_name)
            self:download(asset.browser_download_url)
            return
        end
    end
end

function ArkadiaEditor:downloadBinary()
    if mudletOlderThan(4, 10) then
        scripts:print_log("Edytor sie nie pobierze. Zaktualizuj Mudlet do wersji co najmniej 4.10.")
        return
    end
    scripts:print_log("Pobieram edytor")
    self:getLatestInformation()
end

function ArkadiaEditor:download(url)
    PendingIndicator:show()
    downloadFile(editorBinaryBase .. self:getExtension(), url)
    registerAnonymousEventHandler("sysDownloadDone", function(_, filename) self:handleSysDownload(filename) end)
    registerAnonymousEventHandler("sysDownloadError", function(_, error_found) self:handleSysDownloadError(error_found) end)
end

function ArkadiaEditor:handleSysDownload(filename)
    if filename ~= self:getBinary() then
        return true
    end
    PendingIndicator:hide()
    scripts:print_log("Edytor pobrany.")

    if getOS == "mac" then
        spawn(function(line) if line:gmatch("Volumes")() then self:runCurrent() end end, "hdiutil", "attach", editorBinaryBase .. self:getExtension())
    else
        self:runCurrent()
    end
end

function ArkadiaEditor:handleSysDownloadError(error_found)
    cecho("<red>Blad pobierania: " .. error_found)
    PendingIndicator:hide()
end

function ArkadiaEditor:run(config)
    if not io.exists(self:getBinary()) then
        self:downloadBinary()
        self.currentConfig = config
    end

    scripts:print_log("Uruchamiam edytor konfiguracji. Konfiguracja dla " .. config .. " zostanie przeladowana po zapisaniu.")

    self:startCheckingFile(config)

    local extension = self:getExtension()
    local editorBinary = self:getBinary()
    if extension == "AppImage" then
        spawn(display, "chmod", "+x", editorBinary)
    end
    self.processHandle = spawn(display, editorBinary, "-arg", getMudletHomeDir(), config)
end

function ArkadiaEditor:runCurrent()
    if self.currentConfig then
        self:run(self.currentConfig)
        self.currentConfig = nil
    end
end

function ArkadiaEditor:getBinary()
    if getOS() == "mac" then
        return string.format("/Volumes/arkadia-cfg-editor %s/arkadia-cfg-editor.app/Contents/MacOS/arkadia-cfg-editor", self:getBinaryVersion())
    end
    return editorBinaryBase .. self:getExtension()
end

function ArkadiaEditor:getExtension()
    local os = getOS()
    if os == "windows" then
        return "exe"
    end
    if os == "mac" then
        return "dmg"
    end
    return "AppImage"
end

function ArkadiaEditor:storeBinaryVersion(version)
    local f = io.open(current_version_file, "w")
    f:write(version)
    f:close()
end

function ArkadiaEditor:getBinaryVersion()
    local f = io.open(current_version_file, "r")
    if not f then
        return "unk"
    end
    local version = f:read("*a")
    f:close()
    return version
end

function ArkadiaEditor:startCheckingFile(config)
    self.lastModifiedTime = lfs.attributes(getMudletHomeDir() .. "/" .. config .. ".json").modification
    self.modifiedTimer = tempTimer(5, function() self:shouldReloadConfig(config) end, true)
end

function ArkadiaEditor:shouldReloadConfig(config)
    local currentModified = lfs.attributes(getMudletHomeDir() .. "/" .. config .. ".json").modification
    if self.lastModifiedTime ~= currentModified then
        scripts_load_v2_config(config)
        self.lastModifiedTime = currentModified
    end
    if not self.processHandle:isRunning() and self.modifiedTimer then
        killTimer(self.modifiedTimer)
    end
end

tempTimer(5, function() ArkadiaEditor:checkVersion() end)