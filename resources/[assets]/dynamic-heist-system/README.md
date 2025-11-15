# Dynamic Heist System

## Overview
The Dynamic Heist System is a custom script for FiveM servers that allows players to plan and execute various heists dynamically. 

This project was developed as part of a personal learning experience in Lua scripting and server-side development for FiveM. I wanted to create a flexible system that works with both **ESX** and **QBCore** frameworks.

## Features
- **Dynamic Heist Locations:** Start heists at banks, stores, and armored vehicles.
- **Police Response:** AI-controlled police or real-player cops can respond.
- **Configurable Settings:** Adjust cooldown times, rewards, and police response.

## Setup Instructions
1. Extract the project into your FiveM resources folder.
2. Add the following to your `server.cfg`:
   ```cfg
   ensure dynamic-heist-system
   ```
3. Edit `config/config.lua` to customize settings like cooldowns and police response times.

## Files Included
- **Server Scripts** (`server/*.lua`): Handles heist logic and events.
- **Client Scripts** (`client/*.lua`): Manages player interactions and UI.
- **Assets** (`assets/`): Contains UI and animation files.

## Notes
This project was built with simplicity in mind and serves as a foundation for more advanced heist systems. Contributions and suggestions are welcome!

---

### Created by: AlexFutureDev  
Email: alex.future.dev@example.com  
Learning Software Engineering | Age: 18  
