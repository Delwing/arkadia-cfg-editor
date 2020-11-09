ArkadiaEditor = ArkadiaEditor or {}

local editorBinaryBase = getMudletHomeDir() .. "/plugins/arkadia-config-editor/editor."
local apiUrl = "https://api.github.com/repos/Delwing/arkadia-config-editor/releases/latest"

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
            self:download(asset.browser_download_url)
            return
        end
    end
end

function ArkadiaEditor:downloadBinary()
    scripts:print_log("Pobieram edytor")
    self:getLatestInformation()
end

function ArkadiaEditor:download(url)
    PendingIndicator:show()
    downloadFile(self:getBinary(), url)
    registerAnonymousEventHandler("sysDownloadDone", function(_, filename) self:handleSysDownload(filename) end)
    registerAnonymousEventHandler("sysDownloadError", function(_, error_found) self:handleSysDownloadError(error_found) end)
end

function ArkadiaEditor:handleSysDownload(filename)
    if filename ~= self:getBinary() then
        return true
    end
    PendingIndicator:hide()
    scripts:print_log("Edytor pobrany.")
    self:run(self.currentConfig)
end

function ArkadiaEditor:handleSysDownloadError(error_found)
    cecho("<red>Blad pobieranie: " .. error_found)
    PendingIndicator:hide()
end

function ArkadiaEditor:run(config)
    if not io.exists(self:getBinary()) then
        self:downloadBinary()
        self.currentConfig = config
    end

    local extension = self:getExtension()
    local editorBinary = self:getBinary()
    if extension == "AppImage" then
        os.execute("chmod +x " .. editorBinary)
    end
    spawn(display, editorBinary, "-arg", getMudletHomeDir(), config)
end

function ArkadiaEditor:getBinary()
    return editorBinaryBase .. self:getExtension()
end

function ArkadiaEditor:getExtension()
    local os = getOS()
    if os == "windows" then
        return "exe"
    end
    if os == "macos" then
        return "dmg"
    end
    return "AppImage"
end