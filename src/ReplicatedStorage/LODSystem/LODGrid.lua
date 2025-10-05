local Constants = require(script.Parent.Constants)

local LODGrid = {}
LODGrid.__index = LODGrid

local function generateGridOriginVector(qualityVersion: number)
    return Constants.GRID_ORIGINS[qualityVersion]
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

    local gridPosition = self.originVector
        + Vector3.new(self.index % 2, self.index % 2, self.index % 2)
        * Constants.ASSET_SPACING

    lodVersion.asset:PivotTo(CFrame.new(gridPosition))

    self.index += 1
end

return LODGrid