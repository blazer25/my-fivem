// Function for getting random number between 1 and 3 for song choose

function getRandomSongNumber() {
    return random = Math.floor(Math.random() * 3) + 1;
  }
// Function for getting random number between 1 and 3 for song choose

// Function for setting a random song
  function setNewSong() {
  if (random == 1) {
    document.getElementById("loading").src = "song/song1.mp3";
    songname.innerHTML = "Asketa & Natan Chaim - More [NCS Release]";
  }
  else if (random == 2) {
    document.getElementById("loading").src = "song/song2.mp3";
    songname.innerHTML = "Akacia - Electric [NCS Release]";
  }
  else if (random == 3) {
    document.getElementById("loading").src = "song/song3.mp3";
    songname.innerHTML = "Wiguez & Vizzen - Running Wild [NCS Release]";
  }

  }
// Function for setting a random song

// Function for random song select on page loaded
document.addEventListener("DOMContentLoaded", function () {
    // Volání funkcí pro výběr a nastavení náhodné písně
    var random = getRandomSongNumber();
    setNewSong(random);
  });
// Function for random song select page loaded

// Function for lower or higher up sound in background, its working function in script but its not noted in text//
var play = false;
var vid = document.getElementById("loading");
vid.volume = 0.2;
window.addEventListener('keyup', function(e) {
    if (e.which == 38) { // ArrowDOWN
        vid.volume = Math.min(vid.volume + 0.025, 1);
    } else if (e.which == 40) { // ArrowUP
        vid.volume = Math.max(vid.volume - 0.025, 0);
    };
});
// Function for lower or higher up sound in background, its working function in script but its not noted in text//

var mutetext = document.getElementById("text");
var songname = document.getElementById("songname");

window.addEventListener("keyup", function(event) {
    if (event.which == 37) { // ArrowLEFT
        if (document.getElementById("loading").src.endsWith("song2.mp3")) {
            document.getElementById("loading").src = "song/song1.mp3";
            songname.innerHTML = "Asketa & Natan Chaim - More [NCS Release]";

        } else if (document.getElementById("loading").src.endsWith("song1.mp3")) {
            document.getElementById("loading").src = "song/song3.mp3";
            songname.innerHTML = "Wiguez & Vizzen Ft. Maestro Chives - Running Wild (EH!DE Remix) [NCS Release]";

        } else if (document.getElementById("loading").src.endsWith("song3.mp3")) {
            document.getElementById("loading").src = "song/song2.mp3";
            songname.innerHTML = "Akacia - Electric [NCS Release]";
        }
        document.getElementById("loading").play();
        mutetext.innerHTML = "MUTE";
    }

    if (event.which == 39) { // ArrowRIGHT
        if (document.getElementById("loading").src.endsWith("song2.mp3")) {
            document.getElementById("loading").src = "song/song3.mp3";
            songname.innerHTML = "Wiguez & Vizzen Ft. Maestro Chives - Running Wild (EH!DE Remix) [NCS Release]";

        } else if (document.getElementById("loading").src.endsWith("song3.mp3")) {
            document.getElementById("loading").src = "song/song1.mp3";
            songname.innerHTML = "Asketa & Natan Chaim - More [NCS Release]";

        } else if (document.getElementById("loading").src.endsWith("song1.mp3")) {
            document.getElementById("loading").src = "song/song2.mp3";
            songname.innerHTML = "Akacia - Electric [NCS Release]";

        }
        document.getElementById("loading").play();
        mutetext.innerHTML = "MUTE";
    }
    
});


// Function for pause and play music in background//
var audio = document.querySelector('audio');

if (audio) {

    window.addEventListener('keydown', function(event) {

        var key = event.which || event.keyCode;
        var x = document.getElementById("text").innerText;
        var y = document.getElementById("text");

        if (key === 32 && x == "MUTE") { // spacebar

            event.preventDefault();

            audio.paused ? audio.play() : audio.pause();
            y.innerHTML = "UNMUTE";

        } else if (key === 32 && x == "UNMUTE") {

            event.preventDefault();

            audio.paused ? audio.play() : audio.pause();
            y.innerHTML = "MUTE";
        }
    });
}
// Function for pause and play music in background//

//SHADED-TEXT - Function for switching words in loading animation

var shadedText = document.querySelector('.shaded-text');
var texts = ["JOINING SERVER", "PREPARING ASSETS", "ESTABLISHING CONNECTION"];
var currentText = 0;

setInterval(function() {
currentText = (currentText + 1) % texts.length;
shadedText.classList.remove('fade-out');
void shadedText.offsetWidth;
shadedText.classList.add('fade-out');
setTimeout(function() {
shadedText.textContent = texts[currentText];
}, 1000);
}, 4000);
//SHADED-TEXT - Function for switching words in loading animation

//PLACEHOLDER - Function for getting handoverdata from lua script
window.addEventListener('DOMContentLoaded', () => {
  // a thing to note is the use of innerText, not innerHTML: names are user input and could contain bad HTML!
  document.querySelector('#namePlaceholder > span').innerText = window.nuiHandoverData.name;
});
//PLACEHOLDER - Function for getting handoverdata from lua scrip

//RANDOMPHRASES - Phrases generated after your steamname
(function welcometext() {
    var welcomes = ['Begin your exciting new adventure.', 'Discover the wonders of your new city.', 'Open the door to a brand-new chapter.', 'Step into a world of new possibilities.', 'Embrace your fresh beginning.', ];
    var randomWelcome = Math.floor(Math.random() * welcomes.length);
    document.getElementById('welcomeDisplay').innerHTML = welcomes[randomWelcome];
  })();
//RANDOMPHRASES - Phrases generated after your steamname

//VIDEO LOADING - Enhanced implementation with multiple fallbacks
var ytPlayer = null;
var videoLoadAttempted = false;
var currentVideoMethod = null;

// Logging function for debugging
function logVideoStatus(message, type) {
    var prefix = type === 'error' ? '[VIDEO ERROR]' : type === 'warn' ? '[VIDEO WARN]' : '[VIDEO INFO]';
    console.log(prefix + ' ' + message);
    if (type === 'error') {
        console.error(message);
    }
}

// Method 1: Try direct video file (most reliable for FiveM)
function tryDirectVideoFile() {
    logVideoStatus('Attempting to load direct video file...', 'info');
    var videoFile = document.getElementById('background-video-file');
    
    if (!videoFile) {
        logVideoStatus('Video file element not found', 'error');
        return false;
    }
    
    // Check if video can load
    videoFile.addEventListener('loadeddata', function() {
        logVideoStatus('Direct video file loaded successfully', 'info');
        videoFile.style.display = 'block';
        currentVideoMethod = 'direct';
        try {
            videoFile.play().then(function() {
                logVideoStatus('Direct video file playing', 'info');
            }).catch(function(error) {
                logVideoStatus('Failed to play direct video: ' + error.message, 'error');
                tryYouTubeVideo();
            });
        } catch (e) {
            logVideoStatus('Error playing direct video: ' + e.message, 'error');
            tryYouTubeVideo();
        }
    });
    
    videoFile.addEventListener('error', function(e) {
        logVideoStatus('Direct video file failed to load: ' + (e.message || 'Unknown error'), 'error');
        logVideoStatus('Video file may not exist or format not supported', 'warn');
        tryYouTubeVideo();
    });
    
    // Try to load the video
    videoFile.load();
    
    // Set timeout to detect if video doesn't load
    setTimeout(function() {
        if (videoFile.readyState === 0 && currentVideoMethod !== 'direct') {
            logVideoStatus('Direct video file timeout - file may not exist', 'warn');
            tryYouTubeVideo();
        }
    }, 3000);
    
    return true;
}

// Method 2: Try YouTube IFrame API
function tryYouTubeVideo() {
    if (currentVideoMethod === 'direct') {
        logVideoStatus('Direct video is working, skipping YouTube', 'info');
        return;
    }
    
    logVideoStatus('Attempting YouTube IFrame API...', 'info');
    currentVideoMethod = 'youtube-api';
    
    // Check if YouTube API is loaded
    if (typeof YT === 'undefined' || typeof YT.Player === 'undefined') {
        logVideoStatus('YouTube IFrame API not loaded, waiting...', 'warn');
        // Wait for API to load
        var apiCheckCount = 0;
        var apiCheckInterval = setInterval(function() {
            apiCheckCount++;
            if (typeof YT !== 'undefined' && typeof YT.Player !== 'undefined') {
                clearInterval(apiCheckInterval);
                logVideoStatus('YouTube API loaded, initializing player...', 'info');
                initializeYouTubePlayer();
            } else if (apiCheckCount >= 10) {
                clearInterval(apiCheckInterval);
                logVideoStatus('YouTube API failed to load after 10 attempts', 'error');
                tryYouTubeIframe();
            }
        }, 500);
    } else {
        initializeYouTubePlayer();
    }
}

function initializeYouTubePlayer() {
    var youtubeContainer = document.getElementById('background-video-youtube');
    if (!youtubeContainer) {
        logVideoStatus('YouTube container not found', 'error');
        tryYouTubeIframe();
        return;
    }
    
    try {
        ytPlayer = new YT.Player('background-video-youtube', {
            height: '100%',
            width: '100%',
            videoId: 'RUB5KmZrVDs',
            playerVars: {
                'autoplay': 1,
                'mute': 1,
                'loop': 1,
                'playlist': 'RUB5KmZrVDs',
                'controls': 0,
                'modestbranding': 1,
                'rel': 0,
                'iv_load_policy': 3,
                'playsinline': 1,
                'enablejsapi': 1
            },
            events: {
                'onReady': onYouTubePlayerReady,
                'onStateChange': onYouTubePlayerStateChange,
                'onError': onYouTubePlayerError
            }
        });
        logVideoStatus('YouTube player instance created', 'info');
    } catch (e) {
        logVideoStatus('Error creating YouTube player: ' + e.message, 'error');
        tryYouTubeIframe();
    }
}

function onYouTubePlayerReady(event) {
    logVideoStatus('YouTube player ready', 'info');
    try {
        event.target.playVideo();
        logVideoStatus('YouTube video play command sent', 'info');
    } catch (e) {
        logVideoStatus('Error playing YouTube video: ' + e.message, 'error');
        tryYouTubeIframe();
    }
}

function onYouTubePlayerStateChange(event) {
    if (event.data == YT.PlayerState.PLAYING) {
        logVideoStatus('YouTube video is playing', 'info');
    } else if (event.data == YT.PlayerState.ENDED) {
        logVideoStatus('YouTube video ended, looping...', 'info');
        event.target.playVideo();
    } else if (event.data == YT.PlayerState.ERROR) {
        logVideoStatus('YouTube player state error', 'error');
        tryYouTubeIframe();
    }
}

function onYouTubePlayerError(event) {
    var errorMessages = {
        2: 'Invalid video ID',
        5: 'HTML5 player error',
        100: 'Video not found',
        101: 'Video not allowed in embedded players',
        150: 'Video not allowed in embedded players'
    };
    var errorMsg = errorMessages[event.data] || 'Unknown error (' + event.data + ')';
    logVideoStatus('YouTube player error: ' + errorMsg, 'error');
    tryYouTubeIframe();
}

// Method 3: Try YouTube iframe embed (fallback)
function tryYouTubeIframe() {
    if (currentVideoMethod === 'direct' || currentVideoMethod === 'youtube-api') {
        return; // Don't override if something is working
    }
    
    logVideoStatus('Attempting YouTube iframe embed...', 'info');
    currentVideoMethod = 'youtube-iframe';
    
    var youtubeContainer = document.getElementById('background-video-youtube');
    if (!youtubeContainer) {
        logVideoStatus('YouTube container not found for iframe', 'error');
        useStaticBackground();
        return;
    }
    
    youtubeContainer.innerHTML = '<iframe width="560" height="315" src="https://www.youtube-nocookie.com/embed/RUB5KmZrVDs?autoplay=1&mute=1&loop=1&playlist=RUB5KmZrVDs&controls=0&modestbranding=1&rel=0&iv_load_policy=3&playsinline=1&start=0" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" referrerpolicy="no-referrer-when-downgrade" style="width: 100vw; height: 100vh; position: absolute; top: 50%; left: 50%; transform: translate(-50%, -50%); pointer-events: none; z-index: -100;" id="youtube-iframe"></iframe>';
    
    var iframe = document.getElementById('youtube-iframe');
    if (iframe) {
        iframe.addEventListener('load', function() {
            logVideoStatus('YouTube iframe loaded', 'info');
        });
        iframe.addEventListener('error', function() {
            logVideoStatus('YouTube iframe failed to load', 'error');
            useStaticBackground();
        });
        
        // Check if iframe loads within timeout
        setTimeout(function() {
            if (iframe.contentWindow === null || iframe.contentDocument === null) {
                logVideoStatus('YouTube iframe may be blocked by security policies', 'warn');
                useStaticBackground();
            }
        }, 5000);
    }
}

// Method 4: Use static background (final fallback)
function useStaticBackground() {
    logVideoStatus('All video methods failed, using static background', 'warn');
    currentVideoMethod = 'static';
    var staticBg = document.getElementById('background-static');
    if (staticBg) {
        staticBg.style.display = 'block';
    }
}

// Global YouTube API ready callback
function onYouTubeIframeAPIReady() {
    logVideoStatus('YouTube IFrame API ready callback triggered', 'info');
    if (currentVideoMethod === null || currentVideoMethod === 'youtube-api') {
        initializeYouTubePlayer();
    }
}

// Initialize video loading
(function initVideo() {
    if (videoLoadAttempted) {
        return;
    }
    videoLoadAttempted = true;
    
    logVideoStatus('Initializing video loading system...', 'info');
    
    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', function() {
            setTimeout(startVideoLoading, 100);
        });
    } else {
        setTimeout(startVideoLoading, 100);
    }
    
    function startVideoLoading() {
        // Try direct video file first (most reliable)
        if (!tryDirectVideoFile()) {
            // If direct video element doesn't exist, try YouTube
            logVideoStatus('Direct video element not available, trying YouTube...', 'info');
            tryYouTubeVideo();
        }
    }
})();
//VIDEO LOADING - Enhanced implementation with multiple fallbacks
  