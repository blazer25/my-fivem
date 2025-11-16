

const LoadingScreenConfig = {
    // ==========================================================================
    // Server Information
    // ==========================================================================
    server: {
        name: "Life$tyle Roleplay",
        tagline: "Serirous roleplayer server",
        logo: "assets/logo/logo.png", // Path to your server logo
        maxPlayers: 64,
        description: "Experience the ultimate roleplay adventure with our dedicated community and professional staff team."
    },

    // ==========================================================================
    // Social Media Links
    // ==========================================================================
    socialMedia: {
        discord: {
            url: "add here chris",
            enabled: true
        },
        twitter: {
            url: "add here chris",
            enabled: true
        },
        youtube: {
            url: "https://www.youtube.com/@pulsescripts",
            enabled: true
        },
        instagram: {
            url: "add here chris",
            enabled: true
        }
    },

    // ==========================================================================
    // Staff Members Configuration
    // ==========================================================================
    staff: [
        {
            name: "Blazer",
            role: "Owner",
            avatar: "assets/avatars/avatar1.jfif",
        },
        {
            name: "chris stone",
            role: "Developer",
            avatar: "assets/avatars/avatar2.jfif",
        },
        {
            name: "Dankz4Dayz",
            role: "Developer",
            avatar: "assets/avatars/avatar3.jfif",
        },
        {
            name: "snow white",
            role: "sucks",
            avatar: "assets/avatars/avatar4.jfif",
        }
        
    ],

    // ==========================================================================
    // News/Updates Configuration
    // ==========================================================================
    news: [
        {
            date: "07/11/25",
            title: "still fixing and building server",
            excerpt: "development stage."
        },
    ],

    // ==========================================================================
    // Loading Messages Configuration
    // ==========================================================================
    loadingMessages: [
        "Initializing server connection...",
        "Loading game assets...",
        "Synchronizing player data...",
        "Preparing world environment...",
        "Loading character information...",
        "Establishing voice chat...",
        "Loading vehicle data...",
        "Synchronizing server time...",
        "Loading custom scripts...",
        "Preparing spawn location...",
        "Finalizing connection...",
        "Welcome to the server!"
    ],

    // ==========================================================================
    // Music Configuration
    // ==========================================================================
    music: {
        enabled: true,
        autoplay: true,
        volume: 0.1, // 0.0 to 1.0
        tracks: [
            {
                title: "Janji - Heroes Tonight",
                artist: "Johnning",
                url: "assetmp3s/music/music1."
            },

            { 
                title: "Janji - Heroes Tonight", 
                artist: "Johnning", 
                url: "assetmp3s/music/music2." 
            },
        ]
    },

    // ==========================================================================
    // Visual Effects Configuration
    // ==========================================================================
    effects: {
        particles: {
            enabled: true,
            count: 50,
            speed: 1.0
        },
        backgroundVideo: {
            enabled: true,
            // Use either: an mp4 path (string), an object with formats { mp4, webm }, or a YouTube link via `youtube`
            url: "assets/video/background.mp4",
            //youtube: "https://www.youtube.com/watch?v=f1MAEDPcUC0",
            fallbackImage: "assets/bakcground.jpg"
        },
        animations: {
            enabled: true,
            duration: 1000 // milliseconds
        }
    },

    // ==========================================================================
    // Color Theme Configuration
    // ==========================================================================
    theme: {
        primary: "#00d4ff",
        secondary: "#0099cc",
        accent: "#ffffff",
        background: "rgba(0, 0, 0, 0.8)",
        text: "#ffffff",
        textSecondary: "rgba(255, 255, 255, 0.7)"
    },

    // ==========================================================================
    // Loading Progress Configuration
    // ==========================================================================
    loading: {
        simulateProgress: true, // Set to false if using real FiveM loading events
        duration: 30000, // milliseconds (15 seconds)
        steps: [
            { progress: 10, message: "Connecting to server..." },
            { progress: 25, message: "Loading game assets..." },
            { progress: 40, message: "Synchronizing data..." },
            { progress: 60, message: "Loading world..." },
            { progress: 80, message: "Preparing character..." },
            { progress: 95, message: "Finalizing..." },
            { progress: 100, message: "Welcome!" }
        ]
    },

    // ==========================================================================
    // Advanced Configuration
    // ==========================================================================
    advanced: {
        showFPS: false,
        debugMode: false,
        preloadImages: true,
        lazyLoadContent: true,
        enableKeyboardShortcuts: true,
        autoHideUI: false, // Auto-hide UI elements after loading
        fadeOutDuration: 2000 // Fade out duration when loading completes
    }
};

// ==========================================================================
// Configuration Validation and Defaults
// ==========================================================================

/**
 * Validates and applies default values to the configuration
 */
function validateConfig() {
    // Ensure required fields have defaults
    if (!LoadingScreenConfig.server.name) {
        LoadingScreenConfig.server.name = "FiveM Server";
    }
    
    if (!LoadingScreenConfig.server.tagline) {
        LoadingScreenConfig.server.tagline = "Welcome to our server";
    }
    
    if (!LoadingScreenConfig.loadingMessages.length) {
        LoadingScreenConfig.loadingMessages = ["Loading..."];
    }
    
    // Validate color values
    const colorRegex = /^#([A-Fa-f0-9]{6}|[A-Fa-f0-9]{3})$|^rgba?\(/;
    Object.keys(LoadingScreenConfig.theme).forEach(key => {
        if (typeof LoadingScreenConfig.theme[key] === 'string' && 
            !colorRegex.test(LoadingScreenConfig.theme[key])) {
            console.warn(`Invalid color value for theme.${key}: ${LoadingScreenConfig.theme[key]}`);
        }
    });
    
    // Validate loading duration
    if (LoadingScreenConfig.loading.duration < 1000) {
        LoadingScreenConfig.loading.duration = 5000;
        console.warn("Loading duration too short, set to minimum 5 seconds");
    }
    
    // Validate music volume
    if (LoadingScreenConfig.music.volume < 0 || LoadingScreenConfig.music.volume > 1) {
        LoadingScreenConfig.music.volume = 0.3;
        console.warn("Music volume out of range, set to 0.3");
    }
}

// ==========================================================================
// Configuration Helper Functions
// ==========================================================================

/**
 * Gets a configuration value by path (e.g., 'server.name')
 */
function getConfigValue(path, defaultValue = null) {
    const keys = path.split('.');
    let value = LoadingScreenConfig;
    
    for (const key of keys) {
        if (value && typeof value === 'object' && key in value) {
            value = value[key];
        } else {
            return defaultValue;
        }
    }
    
    return value;
}

/**
 * Sets a configuration value by path
 */
function setConfigValue(path, newValue) {
    const keys = path.split('.');
    const lastKey = keys.pop();
    let target = LoadingScreenConfig;
    
    for (const key of keys) {
        if (!(key in target) || typeof target[key] !== 'object') {
            target[key] = {};
        }
        target = target[key];
    }
    
    target[lastKey] = newValue;
}

/**
 * Merges user configuration with default configuration
 */
function mergeConfig(userConfig) {
    function deepMerge(target, source) {
        for (const key in source) {
            if (source[key] && typeof source[key] === 'object' && !Array.isArray(source[key])) {
                if (!target[key] || typeof target[key] !== 'object') {
                    target[key] = {};
                }
                deepMerge(target[key], source[key]);
            } else {
                target[key] = source[key];
            }
        }
        return target;
    }
    
    return deepMerge(LoadingScreenConfig, userConfig);
}

// Initialize configuration validation
validateConfig();

// Export for use in other scripts
if (typeof module !== 'undefined' && module.exports) {
    module.exports = {
        LoadingScreenConfig,
        getConfigValue,
        setConfigValue,
        mergeConfig,
        validateConfig
    };
}

