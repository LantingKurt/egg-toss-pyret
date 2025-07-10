# Egg Toss Game

A simple egg toss platformer game implemented in [Pyret](https://pyret.org/), inspired by classic vertical jumper mechanics. The player controls an egg that jumps across moving platforms and attempts to reach the top without falling off-screen.

## 🎮 Game Features

- Dynamic moving platforms with velocity reversal at screen bounds
- Egg jumping mechanics with gravity and airborne detection
- Platform collision and fall detection
- Score tracking and lives system
- Auto-scrolling level transition with new platform generation
- Game over state with reset functionality

## 🧠 How It Works

- **Platforms** (top, middle, bottom) move horizontally and reverse at edges.
- **Egg** jumps when spacebar is pressed (only if it's on a platform).
- **Collision Detection** triggers landing and score updates.
- **Lives** are reduced when the egg falls out of bounds.
- **Game transitions** to the next level by scrolling new platforms in from above.

## 🎨 Controls

| Key       | Action               |
|-----------|----------------------|
| Spacebar  | Jump / Restart game  |



## ⚙️ Constants (Customizable Settings)

You can adjust these constants in `main.arr` to modify gameplay difficulty, behavior, and visuals.

### Screen Settings

| Constant                 | Default | Description                                           |
|--------------------------|---------|-------------------------------------------------------|
| `SCREEN-WIDTH`           | 300     | Width of the canvas                                   |
| `SCREEN-HEIGHT`          | 500     | Height of the canvas                                  |
| `SCREEN-TRANSITION-SPEED`| 3       | Scroll speed when transitioning between levels        |
| `FPS`                    | 60      | Updates per second (higher = smoother gameplay)       |

### Platform Settings

| Constant                 | Default | Description                                           |
|--------------------------|---------|-------------------------------------------------------|
| `PLATFORM-WIDTH`         | 70      | Width of each platform (wider = easier landings)      |
| `PLATFORM-HEIGHT`        | 13      | Height of each platform (visual only)                 |
| `PLATFORM-COLOR`         | "brown" | Fill color of platforms                               |
| `PLATFORM-VELOCITY-LIMIT`| 9       | Max platform movement speed (higher = harder)         |
| `PLATFORM-DISTANCE`      | 150     | Vertical spacing between platforms                    |

### Platform Y-Coordinates

| Constant        | Default            | Description                                 |
|-----------------|--------------------|---------------------------------------------|
| `TOP-PLATFORM-Y`| `SCREEN-HEIGHT / 4`| Y-position of the top platform              |
| `MID-PLATFORM-Y`| `TOP + 150`        | Y-position of the middle platform           |
| `BOT-PLATFORM-Y`| `MID + 150`        | Y-position of the bottom platform           |

### Egg Settings

| Constant          | Default           | Description                                      |
|-------------------|-------------------|--------------------------------------------------|
| `EGG-RADIUS`      | 20                | Radius of the egg (larger = easier collisions)   |
| `EGG-COLOR`       | "blanched-almond" | Fill color of the egg                            |
| `EGG-JUMP-HEIGHT` | -20               | Initial jump velocity (more negative = higher)   |
| `EGG-AY`          | 0.9               | Gravity acceleration (higher = faster fall)      |
| `EGG-INITIAL-X`   | 100               | Egg's initial horizontal position                |

### Platform Movement Bounds

| Constant                       | Default                    | Description                                            |
|--------------------------------|----------------------------|--------------------------------------------------------|
| `SCREEN-WIDTH-PLATFORM-LIMIT` | `SCREEN-WIDTH - PLATFORM-WIDTH` | Prevents platforms from going off the screen          |

## 🛠 Built With

- [Pyret Language](https://pyret.org/)  
- [Code.pyret.org Editor](https://code.pyret.org/)
