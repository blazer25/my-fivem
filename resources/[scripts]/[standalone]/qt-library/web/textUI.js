window.addEventListener('message', function(event) {
    if (event.data.type === 'showTextUI') {
    $('#textUI').removeClass('hidden');
    $('.text-letter').text(event.data.letter);
    $('.text-description').text(event.data.description);
    } else if (event.data.type === 'hideTextUI') {
    $('#textUI').addClass('hidden');
    }
});