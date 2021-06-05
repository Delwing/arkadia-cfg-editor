PendingIndicator = PendingIndicator or {}

function PendingIndicator:show()

    self.handler = scripts.event_register:force_register_event_handler(self.handler, "sysDownloadFileProgress", function(_, url, bytesDownloaded, totalBytes) self:updateProgress(bytesDownloaded, totalBytes) end)

    self.progressBar = Geyser.Gauge:new({
        name="downloadProgressBar",
        x="25%", y="5%",
        width="50%", height="3%",
      })
      self.progressBar:setFontSize(13)
      self.progressBar:setAlignment("center")
end

function PendingIndicator:updateProgress(bytesDownloaded, totalBytes)
    self.progressBar:setValue(bytesDownloaded, totalBytes, "Pobieram edytor " .. math.floor((bytesDownloaded / totalBytes) * 100) .. "%")
end

function PendingIndicator:hide()
    self.progressBar:hide()
end
