local Configuration = {}
Configuration.__index = Configuration

export type LODSystemConfiguration = {
    callback: (...any) -> number,
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

function Configuration:GetPlayerAssetQualityCallback(callback: (...any) -> number)
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
