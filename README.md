# Setup
1. Initialize the module from ReplicatedStorage Packages via Wally.
- Must be initialized from both Client and Server

2. Ensure models are properly tagged using CollectionService with configuration tag name. Default is "LODAsset".
3. Ensure all tagged models have a Folder named "LODs" inside.
4. Each version of LOD must be named 0,1,2,3,4,... up to 7 (8 total versions).
5. Use the configuration to set up a Persistent LOD (this always shows when the asset is streamed out). Default is quality version 0.