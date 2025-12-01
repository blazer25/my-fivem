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

//VIDEO LOADING - Use YouTube IFrame API for better compatibility
var ytPlayer = null;

function onYouTubeIframeAPIReady() {
    var videoContainer = document.getElementById('background-video');
    if (!videoContainer) {
        console.error('Video container not found');
        return;
    }
    
    try {
        ytPlayer = new YT.Player('background-video', {
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
                'onReady': onPlayerReady,
                'onStateChange': onPlayerStateChange,
                'onError': onPlayerError
            }
        });
    } catch (e) {
        console.error('Error creating YouTube player:', e);
        // Fallback to iframe if API fails
        fallbackToIframe();
    }
}

function onPlayerReady(event) {
    console.log('YouTube player ready');
    try {
        event.target.playVideo();
    } catch (e) {
        console.error('Error playing video:', e);
    }
}

function onPlayerStateChange(event) {
    if (event.data == YT.PlayerState.PLAYING) {
        console.log('Video is playing');
    } else if (event.data == YT.PlayerState.ENDED) {
        // Loop the video
        event.target.playVideo();
    }
}

function onPlayerError(event) {
    console.error('YouTube player error:', event.data);
    // Fallback to iframe if API fails
    fallbackToIframe();
}

function fallbackToIframe() {
    var videoContainer = document.getElementById('background-video');
    if (videoContainer) {
        videoContainer.innerHTML = '<iframe width="560" height="315" src="https://www.youtube-nocookie.com/embed/RUB5KmZrVDs?autoplay=1&mute=1&loop=1&playlist=RUB5KmZrVDs&controls=0&modestbranding=1&rel=0&iv_load_policy=3&playsinline=1&start=0" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" referrerpolicy="no-referrer-when-downgrade" style="width: 100vw; height: 100vh; position: absolute; top: 50%; left: 50%; transform: translate(-50%, -50%); pointer-events: none; z-index: -100;"></iframe>';
    }
}

// Initialize video when page loads
(function initVideo() {
    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', function() {
            // Wait a bit for YouTube API to load
            setTimeout(checkYouTubeAPI, 500);
        });
    } else {
        setTimeout(checkYouTubeAPI, 500);
    }
    
    function checkYouTubeAPI() {
        if (typeof YT !== 'undefined' && YT.Player) {
            onYouTubeIframeAPIReady();
        } else {
            // If API didn't load, try again or use fallback
            setTimeout(function() {
                if (typeof YT !== 'undefined' && YT.Player) {
                    onYouTubeIframeAPIReady();
                } else {
                    console.warn('YouTube IFrame API not loaded, using fallback');
                    fallbackToIframe();
                }
            }, 2000);
        }
    }
})();
//VIDEO LOADING - Use YouTube IFrame API for better compatibility
  