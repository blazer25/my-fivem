document.addEventListener('DOMContentLoaded', () => {
    window.addEventListener('message', (event) => {
        const { action, header, options, back } = event.data;
        
        const akcijeHandleri = {
            'ShowContext': () => {
                updateElementText('context-title', header);
                AddTables(options, back);
                particija('context-body', true);
            },
            'RemoveContext': () => {
                particija('context-body', false);
            },
        };

        if (akcijeHandleri[action]) {
            akcijeHandleri[action]();
        }
    });

    const particija = (modalId, show) => {
        const modal = document.getElementById(modalId);
        if (modal) {
            modal.classList.toggle('hidden', !show);
        }
    };

    const updateElementText = (elementId, text) => {
        const element = document.getElementById(elementId);
        if (element) {
            element.textContent = text;
        }
    };

    const addButtonListeners = () => {
        const closeButton = document.getElementById('close-button');
        if (closeButton) {
            closeButton.addEventListener('click', () => {
                $.post(`https://qt-library/RemoveContext`, JSON.stringify({}));
            });
        }

        const backButton = document.getElementById('back-button');
        if (backButton) {
            backButton.addEventListener('click', () => {
                const backContextId = backButton.getAttribute('data-back-id');
                if (backContextId) {
                    $.post(`https://qt-library/ShowContext`, JSON.stringify({ contextId: backContextId }));
                }
            });
        }
    };

    addButtonListeners();
});

function AddTables(options, backContextId) {
    const tablesContainer = document.getElementById('tables-container');
    if (tablesContainer) {
        tablesContainer.innerHTML = ''; 

        options.forEach((option, index) => {
            const buttonDiv = document.createElement('div');
            buttonDiv.className = 'mb-2'; 

            const button = document.createElement('button');
            button.className = 'w-full bg-gray-700 text-gray-200 p-2 rounded hover:bg-gray-600 focus:outline-none focus:ring-2 focus:ring-gray-500 text-left flex items-center space-x-2 justify-between';

            if (option.icon) {
                const icon = document.createElement('i');
                icon.className = `${option.icon} text-lg bg-gray-600 p-2 rounded`;
                button.appendChild(icon);
            }

            const textDiv = document.createElement('div');
            textDiv.className = 'flex-1';

            const span = document.createElement('span');
            span.className = 'font-semibold';
            span.textContent = option.title;

            textDiv.appendChild(span);

            if (option.description) {
                const p = document.createElement('p');
                p.className = 'text-gray-400 mt-1';
                p.textContent = option.description;
                textDiv.appendChild(p);
            }

            button.appendChild(textDiv);

            if (option.arrow) {
                const arrowIcon = document.createElement('i');
                arrowIcon.className = 'fas fa-arrow-right text-xl bg-gray-600 p-2 rounded hover:bg-gray-500'; 
                button.appendChild(arrowIcon);
            }

            buttonDiv.appendChild(button);
            tablesContainer.appendChild(buttonDiv);

            button.addEventListener('click', () => {
                if (option.event) {
                    $.post(`https://qt-library/onClick`, JSON.stringify({ id : index }));
                } else if (option.serverEvent) {
                    $.post(`https://qt-library/onClick`, JSON.stringify({ id : index  }));
                }
            });
        });

        const backButton = document.getElementById('back-button');
        if (backContextId) {
            backButton.classList.remove('hidden');
            backButton.setAttribute('data-back-id', backContextId);
        } else {
            backButton.classList.add('hidden');
        }
    }
}

