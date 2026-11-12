# No More Gambling: Updated

A Factorio 2.1 continuation of [No More Gambling by API-Beast](https://github.com/API-Beast/no-more-gambling). Retains its deterministic quality recipes, washing and precision fabricators.

Changing quality modules finishes the already paid craft before switching recipes. Finite machine buffers retain their items, qualities, spoilage, tags and fluid temperatures across the transition. Native circuit connections, machine orientation and player-set flags remain intact. Material restoration waits when output is blocked; it does not draw additional inputs while finishing the old craft.

Existing No More Gambling worlds migrate through Factorio's native ownership mechanism. Original entities, items, recipes and settings retain their names, including pending crafting transitions. Do not enable both editions together.

Based on original 1.2.6, authentic upstream commit `5fb33d93be3c569552df71f90328eefdcf418c25`. Original code and artwork are attributed to API-Beast (@beast_pixels); the Mod Portal declares the MIT license. Runtime compatibility and state-preservation changes are maintained by FactorioMods.
