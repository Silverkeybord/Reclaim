# Project Readme

This game is currently in late alpha development, approaching the vertical slice stage.

---

## Player Controls & Navigation

* **Movement:** `WASD`
* **Look:** Mouse
* **Zoom:** Scroll wheel (or window resizing)
* **Interact:** Interaction key (`E`)
* **Area Travel:** Navigate between the **Sector** and the **Ship** using Deployment and Extraction pods.
* **Player Modes:** Change player modes from shooting to building and installation(development) using 1, 2, 3.

### Interactable Objects
* **Crafting Table**
* **Storage Container**
* **Deploy Pod**
* **Extraction Pod**

---

## User Interfaces

### Storage UI
* View items currently stored at the sector as well as on the ship.
* Uses less than half of the screen, allowing you to freely move and look around while the UI is open.

### Crafting UI
* Select items to craft across multiple categorized tabs.
* Supports batch crafting options: craft single, multiple, or max items.
* Player movement is disabled while inside the Crafting UI.
* Includes an in-UI **Help Icon** for quick usage instructions.

### Extraction UI
* Transfer items back and forth between **Sector Storage** and **Extraction Storage**.
* **Shortcut Transfer Controls:**
  * **Left Click:** Transfer 1
  * **Right Click:** Transfer 5
  * **Shift + Left Click:** Transfer 25
  * **Shift + Right Click:** Transfer Max
* Hover over the **Total Tab** in the bottom-left to inspect weight limits and apply item filters.
* Cancel extraction at any time or press **Extract** to trigger full landing and extraction sequence animations.
* Includes an in-UI **Help Icon** for quick usage instructions.

---

## Building & Combat

### Base Building & Defense
* Switch build modes between laying down base plates and placing active turrets.
* Craft, deploy, and remove turrets on the fly to establish defensive positions.

### Gameplay Loop & Enemy Scaling
* Engage enemies, shoot, and gather resource drops.
* Enemies scale dynamically in difficulty as you continually progress through sectors.