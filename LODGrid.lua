local Constants = require(script.Parent.Constants)

local LODGrid = {}
LODGrid.__index = LODGrid

local function generateGridOriginVector(qualityVersion: number)
    return Constants.GRID_ORIGINS[qualityVersion]
end

local function collapseLODVersionToGridPosition(lodVersion: any, gridPosition: Vector3)
    local targetCFrame = CFrame.new(gridPosition)

    for _, descendant in lodVersion.asset:GetDescendants() do
        if not descendant:IsA("BasePart") then
            continue
        end

        descendant.CFrame = targetCFrame
    end
end

function LODGrid.new(qualityVersion: number)
    local self = setmetatable({
        qualityVersion = qualityVersion,
        originVector = generateGridOriginVector(qualityVersion),
        index = 0,
        assets = {}
    }, LODGrid)

    return self
end

function LODGrid:StoreAssetLODVersion(lodVersion: any)
    if lodVersion.qualityVersion ~= self.qualityVersion then
        error(`Asset version does not match grid quality version: {lodVersion.asset:GetFullName()}`)
    end

    local x = self.index % Constants.GRID_WIDTH
    local y = math.floor(self.index / Constants.GRID_WIDTH) % Constants.GRID_WIDTH
    local z = math.floor(self.index / (Constants.GRID_WIDTH * Constants.GRID_WIDTH))
    local gridPosition = self.originVector + Vector3.new(x, y, z) * Constants.ASSET_SPACING

    collapseLODVersionToGridPosition(lodVersion, gridPosition)

    self.index += 1
end

return LODGrid