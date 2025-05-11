# FEATURES

- Multi-page tutorial system with typing animation
- Built-in "Next", "Previous", and "Close" button support
- Clean open/close animation using TweenService
- Typewriter-style text display
- Automatic cleanup of connections and UI
- Supports multiple tutorials via class-based system

# SETUP

1. Place your `Tutorial` ScreenGui inside `StarterGui` or directly into `PlayerGui`
2. Ensure the following UI element names (case-sensitive) exist inside `Tutorial`:

- `Container` (Frame): Main frame that tweens in/out
- `BodyLabel` (TextLabel): Displays the main tutorial text
- `PageLabel` (TextLabel): Displays current page (e.g., "2 / 5")
- `Next`, `Prev`, `Close` (TextButtons): Navigation controls
- `Title` (TextLabel): Displays tutorial title

3. In a LocalScript, require the module and initialize it:

```lua
local Tutorial = require(path.to.TutorialModule)

-- Always call this first to cache UI references
Tutorial.start()

-- Create a tutorial
local myTutorial = Tutorial.new("Welcome!", {
    "Welcome to the game!",
    "Use WASD to move.",
    "Complete tasks to win.",
    "Avoid the manager!",
    "Good luck!"
})
