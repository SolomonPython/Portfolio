script.Enabled = false

--[[
Tutorial System Usage Guide
-----------------------------------------
This module displays a text-based tutorial UI with support for multiple pages, typing animation, and transitions.

✅ Features:
- Customizable title and pages
- "Next" and "Previous" button functionality
- Smooth open/close animations using TweenService
- Typewriter-style text animation
- Auto-destruction and connection cleanup

🛠️ Setup:
1. Place your `Tutorial` ScreenGui inside the player's `PlayerGui`.
   Required UI element names (case-sensitive):
   - "Container" (Frame): Main frame to tween in/out
   - "BodyLabel" (TextLabel): Where the tutorial text appears
   - "PageLabel" (TextLabel): Displays current page (e.g., 1/5)
   - "Next", "Prev", "Close" (TextButtons): Navigation buttons
   - "Title" (TextLabel): Title of the tutorial

2. In a local script, require and start the system:

-- CALL .start before any other functions

local Tutorial = require(path.to.TutorialModule)
Tutorial.start() -- Cache UI elements

local myTutorial = Tutorial.new("Welcome!", {
    "Welcome to the game!",
    "Use WASD to move.",
    "Complete tasks to win.",
    "Avoid the manager!",
    "Good luck!"
})

]]
