# RECLAIM
### Full Game Design Document (GDD)

**Version:** 1.0
**Developer:** Andrew Pooley
**Engine:** Godot 4
**Genre:** 3D Tower Defense Extraction Game
**Target Platform:** PC
**Target Playtime:** 8–10 Hours (might be alot more now)

---

## 1. Vision

Reclaim is a 3D tower-defense extraction game where the player is deployed to reclaim a planet overrun by hostile spherical organisms.

The player fights alongside automated defenses, gathers resources, crafts equipment, unlocks new technologies through Council Authorization, and gradually pushes deeper into enemy territory.

Unlike traditional tower defense games, the player is physically present on the battlefield and participates directly in combat.

The game focuses on:

- Resilience
- Risk versus reward
- Territorial expansion
- Resource management
- Environmental adaptation

---

## 2. Core Design Pillars

### 2.1 Resilience

Loss is expected. Players will:

- Lose resources
- Lose turrets
- Lose modules
- Lose entire deployments

Success comes from recovering from failure and gradually becoming stronger.

### 2.2 Risk Creates Progress

Players must risk resources to gain resources. Nothing is gained without investment.

**Example — Deploy:**

- Turrets
- Modules
- Crafted equipment

Failure results in total loss. Success results in greater returns.

### 2.3 Reclaiming Territory

The objective is not merely survival. The objective is reclaiming the planet sector by sector.

Each successful deployment weakens sphere presence and allows expansion into adjacent territory.

### 2.4 Environmental Adaptation

Everything in the game stems from one core concept:

**Environment → Sphere Adaptation → Resource Drops → Player Progression**

The environment directly influences:

- Enemy behavior
- Enemy appearance
- Enemy resources
- Progression paths

---

## 3. Setting

The player is a member of a cubic civilization. A distant planet has been completely overrun by mysterious spherical organisms. The player is dispatched by a governing authority known as the Council to reclaim the planet.

The Council provides:

- Equipment
- Authorization
- Logistics support
- Resource trading

The player is only one reclamation unit among many.

---

## 4. The Spheres

### 4.1 Overview

Spheres are biological organisms capable of absorbing their environment. Their unusual surface-area-to-volume ratio allows them to rapidly process nearby materials.

### 4.2 Adaptation

Spheres absorb materials from their surroundings. Examples:

- Dirt
- Water
- Fire
- Metal
- Chemicals

These materials alter the sphere's properties. Examples:

- Increased durability
- Elemental abilities
- Greater size
- Increased damage

### 4.3 Growth

Most absorbed material becomes energy. Excess material becomes mass. This causes spheres to grow larger.

Larger spheres can process:

- Denser materials
- More dangerous materials
- More complex materials

### 4.4 Commander Spheres

Sphere groups operate under a localized hive mind. The largest sphere in an area becomes a Commander Sphere.

Commander Spheres:

- Coordinate nearby enemies
- Direct attacks
- Increase efficiency

Destroying commanders weakens local coordination.

---

## 5. Gameplay Loop

```
Ship
  ↓
Select Sector
  ↓
Deploy
  ↓
Build Foundations
  ↓
Construct Turrets
  ↓
Fight Spheres
  ↓
Gather Resources
  ↓
Craft Equipment
  ↓
Survive Escalating Threat
  ↓
Extract Resources
  ↓
Return To Ship
  ↓
Council Authorization
  ↓
Unlock New Sectors
  ↓
Repeat
```

### Extraction Loss Rule (Reinforced)

Anything not extracted:

 - is permanently lost
 - is consumed by spheres
 - may be partially converted into future enemy adaptation

This ensures:

 - Player attachment to risk decisions
 - “left behind = lost forever” tension loop
 - reinforces extraction urgency


---

## 6. Player

### Combat Role

The player is not a commander observing from above. The player is a frontline soldier.

The player:

- Fights enemies directly
- Builds defenses
- Collects resources
- Crafts equipment
- Manages extraction

### Camera

Supported modes:

- First Person
- Third Person

Players may switch freely.

### Weapons

Weapons are used throughout the entire game. Current planned weapon progression:

- Pistol
- Additional advanced weapon types

Weapon upgrades are unlocked through Council Authorization.

---

## 7. Deployment System

Every deployment begins with:

- Shield Generator
- Extraction Pod
- Sector Storage
- Crafting Bench

The player must build everything else.

---

## 8. Shield System

The landing zone is protected by a shield. The shield protects:

- Turrets
- Crafting station
- Storage
- Extraction pod

Resources frequently drop outside the shield. Players must leave safety to gather them.

### Shield Failure

Enemy pressure increases over time. Eventually:

```
Shield Breaks
  ↓
Backup Overcharge Activates
  ↓
10 Second Emergency Window
  ↓
Extraction Required
```

If extraction fails: Deployment is lost.

---

## 9. Extraction System

### Purpose

Extraction determines what survives the deployment. Anything not extracted is lost. The spheres eventually consume everything left behind.

### Weight System

Everything possesses weight. Examples:

- Resources
- Modules
- Turrets

The extraction pod has a limited carrying capacity. Players must choose what to save.

### Extraction Capacity

Upgraded through Council Authorization. Early game extraction capacity is intentionally restrictive.

---

## 10. Resource System

Resources are divided into five tiers.

### Tier 1 — Basic Material

- Clay
- Dirt
- Flint
- Rock
- Sand
- Scrap

### Tier 2 — Construction Material

- Brick
- Coal
- Copper
- Elemental Essence
- Glass
- Gunpowder
- Rubber

### Tier 3 — Advanced Material

- Circuit
- Concrete
- Gear
- Ice_essence
- Ice_shard
- Iron
- Steel
- Tungsten
- Water_essence
- Water_shard
- Wind_essence
- Wind_shard

### Tier 4 — Electronic Material

- Acid
- Chip
- Earth_esssence
- Earth_shard
- Fire_essence
- fire_shard
- Gold
- Silicon
- Uranium

### Tier 5 — Exotic Material

- Antimatter
- Dark_essence
- Dark_shard
- Graphene
- Light_essence
- light_shard
- Platinum
- Tesseract

---

## 11. Crafting

Crafting occurs inside deployments. Resources are stored inside Sector Storage. Crafted items are added to Sector Storage when complete. Crafting uses a queue system.

### Purpose

Crafting creates:

- Turrets
- Modules
- Foundations
- Equipment

Crafting takes time. The player must survive while crafting completes.

---

## 12. Storage

### Ship Storage

Permanent storage. Contains extracted items.

### Sector Storage

Temporary storage. Contains:

- Gathered resources
- Crafted items
- Modules
- Turrets

Sector Storage is lost if items are not extracted.

---

## 13. Economy

### Currency

**Cubits** — the primary currency of cube civilization.

### Selling

Resources may be sold for Cubits. Selling is generally less efficient than crafting.

### Ordering Resources

Resources can be purchased through Council logistics.

### Rotating Market

Only 3–8 resources are available at a time. Future market rotations are visible.

**Lore explanation:** The Council only reroutes resources when convenient.

---

## 14. Council Authorization

Council Authorization replaces a traditional research tree. The Council already possesses advanced technology. The player must prove they are worthy of using it.

### Major Authorizations

**Ship Tier** — Primary progression mechanic. Unlocks:
- New sectors
- New resources
- New technologies

**Ship Capacity** — Increases ship storage.

**Extraction Capacity** — Increases extraction weight limit.

**Deployment Capacity** — Increases deployable resources.

**Shield Strength** — Improves shield durability.

**Crafting Efficiency** — Reduces crafting times.

**Weapon Authorization** — Unlocks weapon upgrades.

**Turret Authorization** — Unlocks new turrets.

**Module Authorization** — Unlocks new modules.

**Foundation Authorization** — Increases maximum foundation grid size.

---

## 15. Foundation System

Turrets require foundations. No foundation: no turret.

### Grid Expansion

Foundation space is limited. Council Authorization increases available building space. This acts as a major progression system.

---

## 16. Turrets

### Tier 1

- **Basic Turret** — General-purpose starter turret.
- **Dual Turret** — Higher fire rate.
- **Wind Turret** — Knockback and battlefield control.

### Tier 2

- **Mortar** — Area damage.
- **Shotgun** — Short-range burst damage.
- **Water Turret** — Applies wet status effects.
- **Minigun** — Sustained DPS.

### Tier 3

- **Explosive Turret** — High AoE damage.
- **Cannon** — Heavy projectile damage.
- **Earth Turret** — Defensive support.

### Tier 4

- **Missile Turret** — Guided attacks.
- **Sniper Turret** — Extreme range.
- **Fire Turret** — Burn-focused support.

### Tier 5

- **Railgun** — Extreme piercing damage.
- **Cube Turret** — Highly modular turret.
  - Fires powerful cube projectiles.
  - Receives exceptional benefits from elemental modules.
  - Represents the culmination of player customization.

---

## 17. Modules

Modules are crafted upgrades applied to turrets.

**Weight range:** 10–50

Modules improve turret performance. Examples:

- Damage
- Range
- Fire Rate
- Frost
- Explosive
- Efficiency

### Philosophy

Modules should create builds rather than simply increasing numbers.

---

## 18. Elemental System (Reworked)

Elements are no longer directly dropped in full form.

Core Loop

Enemies drop:

### Elemental Shards
- fire_shard
- ice_shard
- water_shard
- wind_shard
- earth_shard
- etc.

Shards are raw environmental residue from sphere adaptation.

### Refinement System

To create usable elemental resources:

Shards + Elemental Essence → Elemental Resource

Examples:

- fire_shard + elemental_essence → fire
- ice_shard + elemental_essence → ice
- wind_shard + elemental_essence → wind

Design Purpose

This creates a deliberate bottleneck:

Elemental Essence becomes a strategic limiting resource
Players cannot spam elemental builds early
Encourages sector targeting based on resource availability
Makes Council market and extraction decisions meaningful

### Late Game Scaling

Higher-tier sectors increase:

- shard density
- essence scarcity or abundance imbalance
- elemental contamination variants (future expansion hook)


## 19. Sector Progression

Players must:

1. Obtain sufficient Ship Tier.
2. Clear adjacent sectors.

This prevents progression skipping.

---

## 20. Sector Selection

The sector selection screen provides:

- Sector description
- Enemy level
- Resource availability
- Environmental information
- Expected adaptations

Players can strategically select deployments.

---

## 21. Sectors

**Remote Island** — Tutorial sector. Minimal sphere activity. Completed once.

**Beach Landing** — First true deployment. Low enemy density. One or two attack directions.

**Grassland** — Multiple attack directions. Introduces combined enemy behaviors.

**Hills** — Uneven terrain. Earth-adapted enemies.

**Ravine** — Enemies attack from both sides. Vertical threats. High clay and rock abundance.

**Drylands** — Few resources. Spheres absorb each other. Results in fewer but much larger enemies.

**Lake** — Water-rich environment. Water-adapted spheres.

**Old City Outskirts** — Industrial ruins. Increasing enemy density.

**Town of Rubble** — Former industrial center. Chemical adaptations.

**Wall** — Ancient defensive structure. Large-scale assaults.

**Inner Walls** — Late-game territory. Heavy sphere presence.

**City Core** — Final major city sector. Contains information regarding sphere origins.

**Spawn Cave** — Final sector. Source of the hive mind. Most dangerous location in the game.

---

## 22. Difficulty Scaling

Difficulty continuously increases during deployments. Scaling includes:

- Enemy health
- Enemy damage
- Enemy size
- Cluster size
- Spawn frequency

The player is eventually overwhelmed. Extraction becomes mandatory.

---

## 23. Win Condition

A sector is cleared by surviving long enough to trigger a final assault.

After the assault:

- Most local spheres are destroyed.
- Enemy spawns become minimal.
- Adjacent sectors become safe enough for future landings.

---

## 24. Endgame

The player reaches the Spawn Cave. Inside lies a Hyper Sphere. The Hyper Sphere serves as the source of hive coordination.

Destroying it:

- Ends the hive mind
- Causes spheres to lose coordination
- Causes spheres to attack one another
- Begins planetary recovery

The planet has been reclaimed.

---

## 25. Future Features

Potential post-core features:

- Turret synergy foundations
- Turret evolution chains
- Additional weapon types
- Additional sectors
- More commander behaviors
- Advanced elemental combinations
- Hyper-late-game content

These features are secondary to completing the core gameplay loop.

---

## 26. Success Criteria

A successful version of Reclaim should:

- Deliver meaningful risk-versus-reward gameplay.
- Make resource extraction feel important.
- Reward resilience after failure.
- Create interesting build decisions.
- Encourage strategic planning.
- Make the player feel responsible for reclaiming an entire planet.

---

*End of Document.*
