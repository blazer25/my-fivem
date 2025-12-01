function createNotification(type, title, message) {
    const container = document.getElementById('notifications-container');
    const notification = document.createElement('div');
    notification.classList.add('p-4', 'rounded-lg', 'shadow-lg', 'relative', 'bg-opacity-80', 'overflow-hidden', 'w-96'); 

    const notificationSound = document.getElementById('notificationSound');
    notificationSound.play();


    function getCurrentTime() {
        const now = new Date();
        const options = {
            timeZone: 'Europe/Berlin', 
            hour12: false,
            hour: 'numeric',
            minute: 'numeric'
        };
        return now.toLocaleTimeString('en-US', options);
    }

    switch (type) {
        case 'success':
            notification.classList.add('bg-green-600', 'text-green-100');
            notification.innerHTML = `
                <div class="flex items-start space-x-4">
                    <div class="flex-shrink-0">
                        <svg class="h-6 w-6 text-green-200" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7" />
                        </svg>
                    </div>
                    <div class="flex-1">
                        <div class="font-bold">${title}</div>
                        <div>${message}</div>
                    </div>
                    <div class="absolute top-0 right-2 mr-2 mt-2 text-xs text-gray-200">${getCurrentTime()}</div> <!-- Position top-right with margin -->
                </div>
            `;
            break;
        case 'error':
            notification.classList.add('bg-red-600', 'text-red-100');
            notification.innerHTML = `
                <div class="flex items-start space-x-4">
                    <div class="flex-shrink-0">
                        <svg class="h-6 w-6 text-red-200" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
                        </svg>
                    </div>
                    <div class="flex-1">
                        <div class="font-bold">${title}</div>
                        <div>${message}</div>
                    </div>
                    <div class="absolute top-0 right-2 mr-2 mt-2 text-xs text-gray-200">${getCurrentTime()}</div> <!-- Position top-right with margin -->
                </div>
            `;
            break;
        case 'warning':
            notification.classList.add('bg-yellow-600', 'text-yellow-100');
            notification.innerHTML = `
                <div class="flex items-start space-x-4">
                    <div class="flex-shrink-0">
                        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 576 512" class="h-6 w-6 text-blue-200" fill="#fef08a" stroke="currentColor">
                            <path d="M569.5 440C588 472 564.8 512 527.9 512H48.1c-36.9 0-60-40.1-41.6-72L246.4 24c18.5-32 64.7-32 83.2 0l239.9 416zM288 354c-25.4 0-46 20.6-46 46s20.6 46 46 46 46-20.6 46-46-20.6-46-46-46zm-43.7-165.3l7.4 136c.3 6.4 5.6 11.3 12 11.3h48.5c6.4 0 11.6-5 12-11.3l7.4-136c.4-6.9-5.1-12.7-12-12.7h-63.4c-6.9 0-12.4 5.8-12 12.7z"/>
                        </svg>
                    </div>
                    <div class="flex-1">
                        <div class="font-bold">${title}</div>
                        <div>${message}</div>
                    </div>
                    <div class="absolute top-0 right-2 mr-2 mt-2 text-xs text-gray-200">${getCurrentTime()}</div> <!-- Position top-right with margin -->
                </div>
            `;
            break;
        case 'info':
            notification.classList.add('bg-blue-600', 'text-blue-100');
            notification.innerHTML = `
                <div class="flex items-start space-x-4">
                    <div class="flex-shrink-0">
                        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 512 512" class="h-6 w-6 text-blue-200" fill="#bfdbfe" stroke="currentColor">
                            <path d="M256 512A256 256 0 1 0 256 0a256 256 0 1 0 0 512zM216 336h24V272H216c-13.3 0-24-10.7-24-24s10.7-24 24-24h48c13.3 0 24 10.7 24 24v88h8c13.3 0 24 10.7 24 24s-10.7 24-24 24H216c-13.3 0-24-10.7-24-24s10.7-24 24-24zm40-208a32 32 0 1 1 0 64 32 32 0 1 1 0-64z"/>
                        </svg>
                    </div>
                    <div class="flex-1">
                        <div class="font-bold">${title}</div>
                        <div>${message}</div>
                    </div>
                    <div class="absolute top-0 right-2 mr-2 mt-2 text-xs text-gray-200">${getCurrentTime()}</div> <!-- Position top-right with margin -->
                </div>
            `;
            break;
        case 'system':
            notification.classList.add('bg-gray-700', 'text-gray-100');
            notification.innerHTML = `
                <div class="flex items-start space-x-4">
                    <div class="flex-shrink-0">
                        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 512 512" class="h-6 w-6 text-white" fill="#e5e7eb" stroke="currentColor">
                            <path d="M495.9 166.6c3.2 8.7 .5 18.4-6.4 24.6l-43.3 39.4c1.1 8.3 1.7 16.8 1.7 25.4s-.6 17.1-1.7 25.4l43.3 39.4c6.9 6.2 9.6 15.9 6.4 24.6c-4.4 11.9-9.7 23.3-15.8 34.3l-4.7 8.1c-6.6 11-14 21.4-22.1 31.2c-5.9 7.2-15.7 9.6-24.5 6.8l-55.7-17.7c-13.4 10.3-28.2 18.9-44 25.4l-12.5 57.1c-2 9.1-9 16.3-18.2 17.8c-13.8 2.3-28 3.5-42.5 3.5s-28.7-1.2-42.5-3.5c-9.2-1.5-16.2-8.7-18.2-17.8l-12.5-57.1c-15.8-6.5-30.6-15.1-44-25.4L83.1 425.9c-8.8 2.8-18.6 .3-24.5-6.8c-8.1-9.8-15.5-20.2-22.1-31.2l-4.7-8.1c-6.1-11-11.4-22.4-15.8-34.3c-3.2-8.7-.5-18.4 6.4-24.6l43.3-39.4C64.6 273.1 64 264.6 64 256s.6-17.1 1.7-25.4L22.4 191.2c-6.9-6.2-9.6-15.9-6.4-24.6c4.4-11.9 9.7-23.3 15.8-34.3l4.7-8.1c6.6-11 14-21.4 22.1-31.2c5.9-7.2 15.7-9.6 24.5-6.8l55.7 17.7c13.4-10.3 28.2-18.9 44-25.4l12.5-57.1c2-9.1 9-16.3 18.2-17.8C227.3 1.2 241.5 0 256 0s28.7 1.2 42.5 3.5c9.2 1.5 16.2 8.7 18.2 17.8l12.5 57.1c15.8 6.5 30.6 15.1 44 25.4l55.7-17.7c8.8-2.8 18.6-.3 24.5 6.8c8.1 9.8 15.5 20.2 22.1 31.2l4.7 8.1c6.1 11 11.4 22.4 15.8 34.3zM256 336a80 80 0 1 0 0-160 80 80 0 1 0 0 160z"/>
                        </svg>
                    </div>
                    <div class="flex-1">
                        <div class="font-bold">${title}</div>
                        <div>${message}</div>
                    </div>
                    <div class="absolute top-0 right-2 mr-2 mt-2 text-xs text-gray-200">${getCurrentTime()}</div> <!-- Position top-right with margin -->
                </div>
            `;
            break;
        default:
            break;
    }

    container.appendChild(notification);

    setTimeout(() => {
        notification.remove();
    }, 5000); 
}

window.addEventListener('message', function(event) {
    if (event.data.type === 'notification') {
        createNotification(event.data.notificationType, event.data.title, event.data.message);
    } else if (event.data.type === 'showTextUI') {
        $('#textUI').removeClass('hidden');
        $('.text-letter').text(event.data.letter);
        $('.text-description').text(event.data.description);
    } else if (event.data.type === 'hideTextUI') {
        $('#textUI').addClass('hidden');
    }
});
