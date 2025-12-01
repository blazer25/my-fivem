function createBox(title, question, disclaimer) {
    const modal = document.getElementById('question-modal');
    const modalTitle = modal.querySelector('h3');
    const modalBody = modal.querySelector('div.p-4.space-y-4');

    modalTitle.textContent = title;
    modalBody.innerHTML = `
        <p class="text-base leading-relaxed text-gray-300 dark:text-gray-400">${question}</p>
        <p class="text-sm leading-relaxed text-gray-400 dark:text-gray-500">*${disclaimer}*</p>
    `;

    modal.classList.remove('hidden');
    modal.classList.add('flex');
}

function closeBox(result) {
    const modal = document.getElementById('question-modal');
    modal.classList.add('hidden');
    modal.classList.remove('flex');

    $.post(`https://qt-library/closeQuestion`, JSON.stringify({ result: result }), function(response) {});
}

document.addEventListener('DOMContentLoaded', () => {
    const acceptButton = document.querySelector('[data-modal-hide="question-modal"]:first-child');
    const declineButton = document.querySelector('[data-modal-hide="question-modal"]:last-child');

    if (acceptButton) {
        acceptButton.addEventListener('click', () => {
            closeBox("confirm");
        });
    }

    if (declineButton) {
        declineButton.addEventListener('click', () => {
            closeBox("cancel");
        });
    }
});

window.addEventListener('message', function(event) {
    if (event.data.action === 'QuestionBox') {
        createBox(event.data.title, event.data.question, event.data.disclaimer);
    } else if (event.data.action === 'CloseBox') {
        closeBox("cancel");   
    }
});
