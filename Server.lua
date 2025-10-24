local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LODAsset = require(script.Parent.LODAsset)
local LODGrid = require(script.Parent.LODGrid)
local Constants = require(script.Parent.Constants)
local Configuration = require(script.Parent.Configuration)

local LODSystemServer = {}
LODSystemServer.LODAssets = {}
LODSystemServer.VersionGrids = {}
LODSystemServer.DelayedPersistentRemovalTasks = {}
LODSystemServer.Remote = nil
LODSystemServer.Ran = false
LODSystemServer.Debug = false
LODSystemServer.Configuration = nil
LODSystemServer.Initialized = false
LODSystemServer.Modules = {
    Configuration = Configuration,
}

local function debugPrint(...)
    if not LODSystemServer.Debug then return end
    print("🟢[LODSystemServer] ", ...)
end

local function waitUntilInitialized()
    while not LODSystemServer.Initialized do
        task.wait(0.1)
    end
end

function LODSystemServer.Initialize(configuration: Configuration.LODSystemConfiguration?)
    if not RunService:IsServer() then
        if true then return end
        error("LODSystem.Server.FrameworkStart can only be called on the server")
    end

    if workspace.ModelStreamingMode == Enum.ModelStreamingBehavior.Improved then
        error("LODSystem.Server.FrameworkStart can only be called if the ModelStreamingBehavior is on Default or Legacy")
    end

    if LODSystemServer.Ran then return end
    LODSystemServer.Ran = true

    LODSystemServer.Remote = Instance.new("RemoteEvent")
    LODSystemServer.Remote.Name = "LODSystemRemote"
    LODSystemServer.Remote.Parent = ReplicatedStorage

    LODSystemServer.Remote.OnServerEvent:Connect(function(player: Player, action: string, ...)
        local args = {...}

        if action == "RequestStreamIn" then
            local assetId = args[1]
            local qualityVersion = args[2]
            LODSystemServer.LoadLODAssetVersion(player, assetId, qualityVersion)
        elseif action == "ConfirmStreamIn" then
            local assetId = args[1]
            local qualityVersion = args[2]
            LODSystemServer.ConfirmStreamIn(player, assetId, qualityVersion)
        end
    end)

    Players.PlayerRemoving:Connect(function(player: Player)
        if LODSystemServer.DelayedPersistentRemovalTasks[player] then
            for _,task in LODSystemServer.DelayedPersistentRemovalTasks[player] do
                task.cancel(task)
            end

            LODSystemServer.DelayedPersistentRemovalTasks[player] = nil
        end
    end)

    if not configuration then
        configuration = Configuration.new()
    end

    LODSystemServer.Configuration = configuration

    Constants.LOD_ASSET_COLLECTION_SERVICE_TAG = configuration.lodAssetCollectionServiceTag
    Constants.PERSISTANT_QUALITY_VERSION = configuration.persistantQualityVersion

    LODSystemServer.Setup()
    LODSystemServer.Initialized = true
end

function LODSystemServer.Setup()
    local lodAssets = CollectionService:GetTagged(Constants.LOD_ASSET_COLLECTION_SERVICE_TAG)

    for _,asset in lodAssets do
        local lodAsset = LODAsset.new(asset)
        LODSystemServer.LODAssets[lodAsset.guid] = lodAsset

        for _,lod in lodAsset:GetLods() do
            if lod.qualityVersion == Constants.PERSISTANT_QUALITY_VERSION then
                continue
            end

            if not LODSystemServer.VersionGrids[lod.qualityVersion] then
                LODSystemServer.VersionGrids[lod.qualityVersion] = LODGrid.new(lod.qualityVersion)
            end

            LODSystemServer.VersionGrids[lod.qualityVersion]:StoreAssetLODVersion(lod)
        end
    end

    debugPrint("LODSystemServer.Setup()")
end

-- Called by client to load the asset version, adds the replication focus
function LODSystemServer.LoadLODAssetVersion(player: Player, assetId: string, qualityVersion: number)
    debugPrint(`Loading asset {assetId} [{qualityVersion}] for player {player.Name}`)

    local asset = LODSystemServer.LODAssets[assetId]
    if not asset then return end

    local lod = asset:GetLod(qualityVersion)
    if not lod then return end

    if qualityVersion == Constants.PERSISTANT_QUALITY_VERSION then
        lod.asset:AddPersistentPlayer(player)
    end

    player:AddReplicationFocus(lod.replicationFocusPart)

    if not LODSystemServer.DelayedPersistentRemovalTasks[player] then
        LODSystemServer.DelayedPersistentRemovalTasks[player] = {}
    end

    LODSystemServer.DelayedPersistentRemovalTasks[player][assetId] = task.delay(Constants.MAX_STREAM_WAIT_TIME, function()
        player:RemoveReplicationFocus(lod.replicationFocusPart)
        debugPrint(`Auto removed replication {assetId} [{qualityVersion}] - {player.Name}`)
    end)
end

-- Called by client to confirm that the asset has been streamed in, removes the replication focus
function LODSystemServer.ConfirmStreamIn(player: Player, assetId: string, qualityVersion: number)
    local asset = LODSystemServer.LODAssets[assetId]
    if not asset then return end
    
    local lod = asset:GetLod(qualityVersion)
    if not lod then return end

    player:RemoveReplicationFocus(lod.replicationFocusPart)
    debugPrint(`Removed replication {assetId} [{qualityVersion}] - {player.Name}`)

    if LODSystemServer.DelayedPersistentRemovalTasks[player] and LODSystemServer.DelayedPersistentRemovalTasks[player][assetId] then
        task.cancel(LODSystemServer.DelayedPersistentRemovalTasks[player][assetId])
        LODSystemServer.DelayedPersistentRemovalTasks[player][assetId] = nil
    end
end

return LODSystemServer