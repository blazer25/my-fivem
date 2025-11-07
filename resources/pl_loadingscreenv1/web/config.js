

const LoadingScreenConfig = {
    // ==========================================================================
    // Server Information
    // ==========================================================================
    server: {
        name: "Pulse Scripts",
        tagline: "Premium Roleplay Experience",
        logo: "assets/logo/logo.png", // Path to your server logo
        maxPlayers: 64,
        description: "Experience the ultimate roleplay adventure with our dedicated community and professional staff team."
    },

    // ==========================================================================
    // Social Media Links
    // ==========================================================================
    socialMedia: {
        discord: {
            url: "https://discord.gg/c6gXmtEf3H",
            enabled: true
        },
        twitter: {
            url: "https://x.com/PulseScripts",
            enabled: true
        },
        youtube: {
            url: "https://www.youtube.com/@pulsescripts",
            enabled: true
        },
        instagram: {
            url: "https://www.instagram.com/pulsescripts",
            enabled: true
        }
    },

    // ==========================================================================
    // Staff Members Configuration
    // ==========================================================================
    staff: [
        {
            name: "John Doe",
            role: "Owner",
            avatar: "assets/avatars/avatar1.jfif",
        },
        {
            name: "Jane Smith",
            role: "Head Admin",
            avatar: "assets/avatars/avatar2.jfif",
        },
        {
            name: "Mike Johnson",
            role: "Developer",
            avatar: "assets/avatars/avatar3.jfif",
        },
        {
            name: "Bran",
            role: "Helper",
            avatar: "assets/avatars/avatar4.jfif",
        }
        
    ],

    // ==========================================================================
    // News/Updates Configuration
    // ==========================================================================
    news: [
        {
            date: "2025-01-15",
            title: "Major Server Update Released!",
            excerpt: "New features, bug fixes, and performance improvements are now live. Check out the changelog for details."
        },
        {
            date: "2025-01-10",
            title: "New Vehicle Pack Added",
            excerpt: "50+ new vehicles have been added to the server. Visit the dealership to check them out!"
        },
        {
            date: "2025-01-05",
            title: "Staff Applications Open",
            excerpt: "We're looking for dedicated members to join our staff team. Applications are now open on our Discord."
        },
        {
            date: "2025-01-01",
            title: "Happy New Year Event",
            excerpt: "Special New Year events and bonuses are active throughout January. Don't miss out!"
        }
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
                title: "Warriyo - Mortals",
                artist: "Laura Brehm",
                url: "assets/music/music1.mp3"
            },

            { 
                title: "Janji - Heroes Tonight", 
                artist: "Johnning", 
                url: "assets/music/music2.mp3" 
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
            fallbackImage: "assets/background.jpg"
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

