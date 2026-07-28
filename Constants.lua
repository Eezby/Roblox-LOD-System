local Constants = {}
Constants.PERSISTANT_QUALITY_VERSION = 0
Constants.LOD_ASSET_COLLECTION_SERVICE_TAG = "LODAsset"

Constants.MAX_STREAM_WAIT_TIME = 30
Constants.GRID_SPACING = 100000
Constants.ASSET_SPACING = 5000
Constants.GRID_WIDTH = 8
Constants.GRID_ORIGINS = {
    [0] = Vector3.new(Constants.GRID_SPACING, 0, 0),
    [1] = Vector3.new(0, Constants.GRID_SPACING, 0),
    [2] = Vector3.new(0, 0, Constants.GRID_SPACING),
    [3] = Vector3.new(0, Constants.GRID_SPACING, Constants.GRID_SPACING),
    [4] = Vector3.new(Constants.GRID_SPACING, 0, Constants.GRID_SPACING),
    [5] = Vector3.new(Constants.GRID_SPACING, Constants.GRID_SPACING, 0),
    [6] = Vector3.new(Constants.GRID_SPACING, Constants.GRID_SPACING, Constants.GRID_SPACING)
}

local GENERATED_ORIGIN_BASE = 4
local GENERATED_ORIGIN_OFFSET = 2

Constants.MAX_QUALITY_VERSION = GENERATED_ORIGIN_BASE ^ 3 - 1

-- Generated origins are offset past the authored ones above so the two can never overlap.
function Constants.GetGridOrigin(qualityVersion: number): Vector3
    local origin = Constants.GRID_ORIGINS[qualityVersion]
    if origin then
        return origin
    end

    if qualityVersion < 0 or qualityVersion > Constants.MAX_QUALITY_VERSION or qualityVersion % 1 ~= 0 then
        error(`Quality version must be a whole number between 0 and {Constants.MAX_QUALITY_VERSION}, got {qualityVersion}`)
    end

    local x = qualityVersion % GENERATED_ORIGIN_BASE
    local y = math.floor(qualityVersion / GENERATED_ORIGIN_BASE) % GENERATED_ORIGIN_BASE
    local z = math.floor(qualityVersion / (GENERATED_ORIGIN_BASE * GENERATED_ORIGIN_BASE))

    return (Vector3.new(x, y, z) + Vector3.one * GENERATED_ORIGIN_OFFSET) * Constants.GRID_SPACING
end

return Constants
