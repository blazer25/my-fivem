window.addEventListener('message', function(event) {
    if (event.data.action === 'openBox') {
        document.getElementById('inputContainer').classList.remove('hidden');
        addFieldsFromTable(event.data.info, event.data.title);
    }
});

function enforceMinMax(el) {
    if (el.value !== "") {
      const min = parseInt(el.min) || -Infinity;
      const max = parseInt(el.max) || Infinity;
      const value = parseInt(el.value);
  
      if (value < min) {
        el.value = min;
      } else if (value > max) {
        el.value = max;
      }
    }
  }
  

function addFieldsFromTable(fields, title) {
    const form = document.getElementById('dynamicForm');
    const titleElement = document.getElementById("title-input");

    form.innerHTML = ''; 
    titleElement.textContent = title;

    fields.forEach((field, index) => {
        const inputGroup = document.createElement('div');
        inputGroup.className = 'mb-4';  

        const fieldIndex = index + 1; 

        const label = document.createElement('label');
        label.htmlFor = `input-${fieldIndex}`;
        label.className = 'block text-gray-400'; 
        label.textContent = field.label;

        let input;

        switch (field.type) {
            case 'checkbox':
                inputGroup.className = 'flex items-center mb-4'; 
                input = document.createElement('input');
                input.type = 'checkbox';
                input.id = `input-${fieldIndex}`;
                input.name = `input-${fieldIndex}`;
                input.className = 'form-checkbox h-5 w-5 text-blue-600 bg-gray-700 border-gray-600 rounded mr-2'; 
                input.checked = field.value.includes(input.name); 
                inputGroup.appendChild(input);
                inputGroup.appendChild(label);
                break;
            case 'date':
                    input = document.createElement('input');
                    input.type = 'date';
                    input.id = `input-${fieldIndex}`;
                    input.name = `input-${fieldIndex}`;
                    input.value = field.value || ''; 
                    input.className = 'w-full p-2 rounded bg-gray-700 text-white outline-none';
                    input.placeholder = field.placeholder || `Enter ${field.label}`; 
                    
                    if (field.min) {
                        input.setAttribute('min', field.min);
                        console.log(`Setting max date: ${input.min}`);
                        console.log(`Setting min date: ${field.min}`);
                    }
                    if (field.max) {
                        input.setAttribute('max', field.max);
                        console.log(`Setting max date: ${input.max}`);
                        console.log(`Setting max date: ${field.max}`); 
                    }
                    
                    if (field.required) input.required = true;  
                    inputGroup.appendChild(label);
                    inputGroup.appendChild(input);
                    break;

            case 'input':  
                input = document.createElement('input');
                input.type = field.inputType || 'text'; 
                input.id = `input-${fieldIndex}`;
                input.name = `input-${fieldIndex}`;
                input.value = field.value || ''; 
                input.className = 'w-full p-2 rounded bg-gray-700 text-white outline-none';
                input.placeholder = field.placeholder || `Enter ${field.label}`; 
                if (field.required) input.required = true;  
                if (field.min) input.minLength = field.min;
                if (field.max) input.maxLength = field.max;
                if (field.max) input.setAttribute('maxlength', field.max);
                inputGroup.appendChild(label);
                inputGroup.appendChild(input);
                break;

            case 'number':
                input = document.createElement('input');
                input.type = 'number';
                input.id = `input-${fieldIndex}`;
                input.name = `input-${fieldIndex}`;
                input.value = field.value || ''; 
            
                if (field.min !== undefined) input.min = field.min;
                if (field.max !== undefined) input.max = field.max;
            
                console.log(`Min: ${input.min}, Max: ${input.max}`); 
            
                input.className = 'w-full p-2 rounded bg-gray-700 text-white outline-none';
                input.placeholder = `Enter ${field.label}`;
                if (field.required) input.required = true;
            
                input.addEventListener('input', function() {
                    enforceMinMax(this);
                });
            
                inputGroup.appendChild(label);
                inputGroup.appendChild(input);
                break;

            case 'multi-select':
                inputGroup.className = 'relative mb-4'; 

                const container = document.createElement('div');
                container.className = 'flex flex-wrap gap-2 items-center p-2 rounded bg-gray-700 text-white cursor-pointer outline-none';

                const selectedContainer = document.createElement('div');
                selectedContainer.className = 'flex flex-wrap gap-2 overflow-y-auto max-h-10 outline-none';

                const placeholder = document.createElement('div');
                placeholder.className = 'text-gray-400';
                placeholder.textContent = 'Select options';
                container.appendChild(placeholder);

                const dropdown = document.createElement('div');
                dropdown.className = 'absolute mt-2 w-full bg-gray-800 border border-gray-600 rounded shadow-lg z-10 hidden outline-none max-h-48 overflow-y-auto';

                const optionsList = document.createElement('div');
                optionsList.className = 'p-2';

                const aaa = document.createElement('input');
                aaa.type = 'hidden';
                aaa.id = `input-${fieldIndex}`;
                aaa.name = `input-${fieldIndex}`;

                field.options.forEach(optionText => {
                    const optionDiv = document.createElement('div');
                    optionDiv.className = 'py-1 px-2 hover:bg-gray-600 cursor-pointer';
                    optionDiv.textContent = optionText;
                    optionDiv.addEventListener('click', () => {
                        if (!selectedContainer.querySelector(`div[data-value="${optionText}"]`)) {
                            const tag = document.createElement('div');
                            tag.className = 'bg-gray-600 text-white rounded px-2 py-1 flex items-center';
                            tag.textContent = optionText;
                            tag.dataset.value = optionText;

                            const closeButton = document.createElement('button');
                            closeButton.className = 'ml-2 text-white rounded-full w-4 h-4 flex items-center justify-center delete-btn';
                            closeButton.innerHTML = '<i class="fas fa-times"></i>'; 
                            closeButton.addEventListener('click', (event) => {
                                event.stopPropagation();
                                tag.remove();
                                updateMultiSelectValue(aaa, selectedContainer);
                                if (selectedContainer.childElementCount === 0) {
                                    placeholder.textContent = 'Select options';
                                }
                            });

                            tag.appendChild(closeButton);
                            selectedContainer.appendChild(tag);

                            placeholder.textContent = '';
                            optionDiv.classList.add('bg-gray-600');
                            updateMultiSelectValue(aaa, selectedContainer);
                        }
                    });
                    optionsList.appendChild(optionDiv);
                });

                dropdown.appendChild(optionsList);

                container.appendChild(selectedContainer);
                container.appendChild(dropdown);

                container.addEventListener('click', (event) => {
                    if (!event.target.classList.contains('delete-btn')) {
                        dropdown.classList.toggle('hidden');
                    }
                });

                inputGroup.appendChild(label);
                inputGroup.appendChild(container);
                inputGroup.appendChild(aaa); 
                break;


            case 'select':
                inputGroup.className = 'relative mb-4'; 
            
                const selectContainer = document.createElement('div');
                selectContainer.className = 'relative';
            
                const selectField = document.createElement('div');
                selectField.className = 'flex items-center p-2 rounded bg-gray-700 text-white cursor-pointer outline-none';
            
                const selectPlaceholder = document.createElement('div');
                selectPlaceholder.className = 'text-gray-400';
                selectPlaceholder.textContent = 'Select an option';
                selectField.appendChild(selectPlaceholder);
            
                const selectDropdown = document.createElement('div');
                selectDropdown.className = 'absolute mt-2 w-full bg-gray-800 border border-gray-600 rounded shadow-lg z-10 hidden outline-none text-white';
            
                const selectOptionsList = document.createElement('div');
                selectOptionsList.className = 'p-2';
            
                const hiddenInput = document.createElement('input');
                hiddenInput.type = 'hidden';
                hiddenInput.id = `input-${fieldIndex}`;
                hiddenInput.name = `input-${fieldIndex}`;
            
                field.options.forEach(optionText => {
                    const optionDiv = document.createElement('div');
                    optionDiv.className = 'py-1 px-2 hover:bg-gray-600 cursor-pointer';
                    optionDiv.textContent = optionText;
                    optionDiv.addEventListener('click', () => {
                        selectPlaceholder.textContent = optionText;
                        hiddenInput.value = optionText;  
                        selectDropdown.classList.add('hidden');
                    });
                    selectOptionsList.appendChild(optionDiv);
                });
            
                selectDropdown.appendChild(selectOptionsList);
            
                selectField.addEventListener('click', () => {
                    selectDropdown.classList.toggle('hidden');
                });
            
                selectContainer.appendChild(selectField);
                selectContainer.appendChild(selectDropdown);
                selectContainer.appendChild(hiddenInput);  
            
                inputGroup.appendChild(label);
                inputGroup.appendChild(selectContainer);
                break;
        }

        form.appendChild(inputGroup);
    });
}

function updateMultiSelectValue(hiddenInput, selectedContainer) {
    const selectedOptions = Array.from(selectedContainer.querySelectorAll('div[data-value]'))
                                .map(tag => `"${tag.dataset.value}"`);
    hiddenInput.value = `{${selectedOptions.join(', ')}}`;
}

function submitForm() {
    const formData = {};
    let isValid = true; 

    document.querySelectorAll('.error-message').forEach(el => el.remove());

    document.querySelectorAll('#dynamicForm input, #dynamicForm select').forEach((input) => {
        if (input.hasAttribute('required') && !input.value) {
            isValid = false;
            const errorMessage = document.createElement('span');
            errorMessage.textContent = 'This field is required';
            errorMessage.className = 'text-red-500 text-sm error-message';
            input.classList.add('border-red-500'); 
            input.parentElement.appendChild(errorMessage);
        } else {
            formData[input.name] = input.type === 'checkbox' ? input.checked : input.value;
        }
    });

    if (isValid) {
        $.post(`https://qt-library/submitForm`, JSON.stringify(formData), function(response) {
            document.getElementById('inputContainer').classList.add('hidden');
        });
    } else {
        document.querySelector('.error-message')?.scrollIntoView({ behavior: 'smooth' });
    }
}

function cancelForm() {
    document.getElementById('inputContainer').classList.add('hidden');
    $.post(`https://qt-library/closeBox`, JSON.stringify({}), function(response) {
    });
}