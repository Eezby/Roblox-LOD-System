local Configuration = {}
Configuration.__index = Configuration

export type LODSystemConfiguration = {
    getPlayerAssetQualityCallback: (Player) -> number,
    maxStreamWaitTime: number,
    persistantQualityVersion: number,
    lodAssetCollectionServiceTag: string
}

function Configuration.new()
    local self = setmetatable({
        getPlayerAssetQualityCallback = function() return 1 end,
        maxStreamWaitTime = 30,
        persistantQualityVersion = 0,
        lodAssetCollectionServiceTag = "LODAsset"
    }, Configuration)
    return self
end

-- Returns the quality version the given player should load. Every tagged asset is expected to
-- provide the returned version, and the persistent version is used while an asset is streamed out.
function Configuration:GetPlayerAssetQualityCallback(callback: (Player) -> number)
    self.getPlayerAssetQualityCallback = callback
    return self
end

function Configuration:MaxStreamWaitTime(time: number)
    self.maxStreamWaitTime = time
    return self
end

function Configuration:PersistantQualityVersion(qualityVersion: number)
    self.persistantQualityVersion = qualityVersion
    return self
end

function Configuration:LODAssetCollectionServiceTag(tag: string)
    self.lodAssetCollectionServiceTag = tag
    return self
end

return Configuration
