# No More Gambling: Updated

Retains deterministic quality recipes, ore washing and precision fabricators from No More Gambling 1.2.6 by API-Beast (@beast_pixels).

Recycling recipes retain the original input-cost calculation on Factorio 2.1, including recipes with multiple crafting categories.

The Factorio 2.1 continuation finishes an already paid craft before changing its recipe when quality modules change. Finite item and fluid buffers retain quality, spoilage, tags and temperature; machine orientation, circuit connections and player-set flags are carried through the transition. Generated quality recipes and pending recipe names follow current native renames, including scaled recipe suffixes.

Asteroid collector reach is limited to the current Legendary quality bonus by default. This bounds collector navigation work when quality levels are large; quality levels, crafting behavior and all other bonuses stay unchanged. Disable **Limit asteroid collector reach to Legendary quality** in startup settings to retain unlimited collector reach scaling. The cap uses the Legendary bonus after the configured quality level curve is applied.

Verified on Factorio 2.1.24: recycling input costs for single and multiple crafting categories, recipe eligibility, and machine inventories, fluids, crafting progress and electrical connections across save/reload. A real multiplayer client passed synchronized play, host save/reload and rejoin.

Requires Factorio 2.1.24 or newer, Quality and Space Age. Existing worlds use native ownership migration, including pending transitions. Power, circuit conditions or blocked output can delay completion and restoration. Enable this edition in place of the original.

[Mod Portal](https://mods.factorio.com/mod/no-more-gambling-updated) · [Source and issues](https://github.com/FactorioMods/no-more-gambling-updated) · [Original mod](https://mods.factorio.com/mod/no-more-gambling) by API-Beast (@beast_pixels). [Original source](https://github.com/API-Beast/no-more-gambling).
