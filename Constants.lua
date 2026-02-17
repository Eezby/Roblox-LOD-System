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

return Constants