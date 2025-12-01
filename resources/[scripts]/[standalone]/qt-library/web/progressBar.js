let progressInterval;
const progressContainer = document.getElementById('progressContainer');
const progressBar = document.getElementById('progressBar');
const progressDescription = document.getElementById('progressDescription');

function progress(description, duration) {
    progressDescription.textContent = description;
    progressContainer.classList.remove('hidden');
    let width = 0;
    const increment = 1;
    const intervalTime = Math.floor(duration / 100);
    progressBar.innerText = `${width}%`;
    clearInterval(progressInterval);
    progressInterval = setInterval(() => {
        width += increment;
        progressBar.style.width = `${width}%`;
        progressBar.innerText = `${width}%`;
        if (width >= 100) {
            clearInterval(progressInterval);
            progressContainer.classList.add('hidden');
            $.post(`https://${GetParentResourceName()}/onProgressCancel`, JSON.stringify({}));
        }
    }, intervalTime);
}

window.addEventListener('message', function(event) {
    if (event.data.type === 'progress') {
        progress(event.data.description, event.data.duration);
    } else if (event.data.type === 'cancelProgress') {
        clearInterval(progressInterval);
        progressContainer.classList.add('hidden');
    }
});
