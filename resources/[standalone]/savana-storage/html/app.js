var locales = {};
let storageList = {};
let ownCitizenId = null; 
let isFavoriteFilterActive = false; // Favori filtresi başlangıç durumu
let capacityPrice = 0;
let storagePrice = 0;
let weightPrice = 0;
let currentCapacityPrice = 0;
let currentWeightPrice = 0;
let totalPrice = 0;

window.addEventListener("message", function (event) {
    if (event.data.action === "open") {
        $("html,body").show();
        $('.gallery').show();
        storageList = event.data.Storages || [];
        ownCitizenId = event.data.cid || null; 
        capacityPrice = event.data.capacityprice
        storagePrice = event.data.storageprice
        weightPrice = event.data.weightprice
        locales = event.data.locales
        loadData();
        refreshPrice();
        refreshInputs()
        $(".popupButtonBuy p").html(`${locales['purchaseButton']} ${storagePrice}`)
        $(".popupButtonBuyx").html(`${locales['confirmButton']}`)
    } else if (event.data.action === 'close') {
        closeAll();
    } else if (event.data.action === 'initUtilsose') {
        locales = event.data.locales;
        for (const key in locales) {
            $(`*[data-locale="${key}"]`).text(locales[key]);
        }
    } else if (event.data.action === 'ok') {
        $('.popup-CreateAna2').hide()
        $('.resetPassword').css('display','flex').show()
    }
});


function refreshInputs() {
    $("#writeIcon").val('');
    $("#writeStorageName").val('');
    $("#writeStorageCapacity").val('');
    $("#writeStorageWeight").val('');
    $("#writeStoragePassword").val('');
    $("#changePasswordFirst").val('');
    $("#changePasswordSecond").val('');
    $("#writeOpenStoragePassword").val('');
    $("#searchCar").val('');
    $("#popupImagex").attr("src", "images/logo.png");
    $(".popupButtonBuy p").html(`${locales['purchaseButton']} ${storagePrice}`)

}

function loadData(searchQuery = '') {
    const leftRightCarList = document.getElementById('leftRight-carList');
    leftRightCarList.innerHTML = '';

    // Depo listesini filtrele
    const filteredStorageList = storageList
        .map((item, originalIndex) => ({ ...item, originalIndex })) // Orijinal dizini ekliyoruz
        .filter(item => item.name.toLowerCase().includes(searchQuery.toLowerCase()));

    filteredStorageList.forEach(item => {
        // Favori filtreleme aktifse ve kullanıcının keyholder listesinde değilse atla
        if (isFavoriteFilterActive && (!item.keyholders || !item.keyholders.includes(ownCitizenId))) {
            return;
        }

        const itemDiv = document.createElement('div');
        itemDiv.classList.add('car');
        itemDiv.dataset.index = item.originalIndex; // Orijinal dizini sakla

        const isFavorite = item.keyholders && item.keyholders.includes(ownCitizenId);
        const favoriteImage = isFavorite ? 'images/ActiveFavorite.png' : 'images/Favorite.png';

        itemDiv.innerHTML = 
           `
            <div class="item">
                <div id="itemImg">
                    <img src="${item.image ? item.image : 'images/Lotus.png'}">
                </div>
                <div id="itemFunctions">
                    <div id="itemName">${item.name}</div>
                    <div id="itemCapacity">
                    <div class="capatiyTop">
                        <i class="fa-solid fa-warehouse"></i>
                        <p class="capacity">${locales["stockcapacity"]}</p> 
                    </div>
                        <p class="capacityValue">${item.capacity} Cap</p>
                </div>
                    <div id="itemType">
                        <div class="capatiyTop">
                            <i class="fa-solid fa-weight-hanging"></i>
                            <p class="capacity">${locales["weightcapacity"]}</p> 
                        </div>
                            <p class="weightValue">${item.weight/1000} Kg</p>
                        </div>
                </div>
                
                <div id="itemPrice">
                    <div id="favorite">
                        <img src="${favoriteImage}" id="changeFavorite">
                    </div>
                    <div id="open">
                        <p>${locales["openstash"]}</p>
                    </div>
                </div>
            </div>
           `; 
        
        leftRightCarList.appendChild(itemDiv);
    });
}

$(document).on("click", ".closePage", function() { 
    $("html,body").hide()
    $('.resetPassword').hide()
    $('.popup-CreateAna').hide()
    $('.popup-CreateAna2').hide()
    refreshInputs()
    $.post("https://savana-storage/nuiOff",function () {})
})

$(document).on("click", ".leftWrapper-leftArea-button", function() { 
    // $(".gallery").hide()
    $('.popup-CreateAna').css("display", "flex").show(); 
})

$(document).on("click", ".popupButtonCancel", function() { 
    if ($(".popup-CreateAna").css('display') === 'flex')  {
        $('.popup-CreateAna').hide()
        $('.gallery').show()
        refreshInputs()
      } else if ($(".popup-CreateAna2").css('display') === 'flex') {
        $('.popup-CreateAna2').hide()
        $('.gallery').show()
        refreshInputs()
      }
})

document.getElementById("writeIcon").addEventListener("input", function () {
    const newImageUrl = this.value;
    document.querySelector("#popupimg img").src = newImageUrl;
});

document.getElementById("searchCar").addEventListener("input", function () {
    const searchQuery = this.value; // Kullanıcının girdiği arama sorgusu
    loadData(searchQuery); // Listeyi filtreleyip yeniden yükle
});
  
const purchaseButton = document.querySelector('.popupButtonBuy');
purchaseButton.addEventListener('click', function(event) {
    event.preventDefault(); // Prevent the form from being submitted
    
    if (validateForm()) {
        $('.popup-CreateAna').hide()
        $("html,body").hide()
        const storageIcon = $("#writeIcon").val();
        const storageName = $("#writeStorageName").val();
        const storageCapacity = $("#writeStorageCapacity").val();
        const storageWeight = $("#writeStorageWeight").val();
        const storagePassword = $("#writeStoragePassword").val();
        if(storageWeight > 0 && storageCapacity > 0) {
            $.post("https://savana-storage/purchaseButton", JSON.stringify({ icon: storageIcon, name: storageName, capacity: storageCapacity, weight: storageWeight, password: storagePassword, price : totalPrice}), function (response) {});
            $.post("https://savana-storage/nuiOff",function () {})
            refreshInputs()
        } else {
            $.post("https://savana-storage/errorlimit", JSON.stringify({}), function(response) {})
            $.post("https://savana-storage/nuiOff", JSON.stringify({}), function(response) {})
            refreshInputs()
        }
    } else {
        // Show error messages if the form is invalid
    }
});

document.body.addEventListener('keydown', function(e) {
    if (e.key == "Escape") {
      if ($(".popup-CreateAna").css('display') === 'flex')  {
        $('.popup-CreateAna').hide()
        $('.gallery').show()
        $('.resetPassword').hide()
        refreshInputs()
      } else if ($(".popup-CreateAna2").css('display') === 'flex') {
        $('.popup-CreateAna2').hide()
        $('.gallery').show()
        $('.resetPassword').hide()
        refreshInputs()
      } else {
        $("html,body").hide()
        $('.resetPassword').hide()
        $.post("https://savana-storage/nuiOff",function () {})
        refreshInputs()
      }
    }
});

function validateForm() {
    // Get form elements
    const icon = document.getElementById('writeIcon');
    const storageName = document.getElementById('writeStorageName');
    const storageCapacity = document.getElementById('writeStorageCapacity');
    const storageWeight = document.getElementById('writeStorageWeight');
    const password = document.getElementById('writeStoragePassword');

    // Get error message elements
    const iconError = document.getElementById('iconError');
    const nameError = document.getElementById('nameError');
    const capacityError = document.getElementById('capacityError');
    const weightError = document.getElementById('weightError');
    const passwordError = document.getElementById('passwordError');

    // Reset error messages
    iconError.textContent = '';
    nameError.textContent = '';
    capacityError.textContent = '';
    weightError.textContent = '';
    passwordError.textContent = '';

    let valid = true;

    // Validate each field
    if (icon.value.trim() === '') {
        iconError.textContent = 'Storage Icon is required.';
        valid = false;
    }
    if (storageName.value.trim() === '') {
        nameError.textContent = 'Storage Name is required.';
        valid = false;
    }
    if (storageCapacity.value.trim() === '') {
        capacityError.textContent = 'Storage Capacity is required.';
        valid = false;
    }
    if (storageWeight.value.trim() === '') {
        weightError.textContent = 'Storage Weight is required.';
        valid = false;
    }
    if (password.value.trim() === '') {
        passwordError.textContent = 'Storage Password is required.';
        valid = false;
    } else if (password.value.length < 8) {
        passwordError.textContent = 'Password must be at least 8 characters.';
        valid = false;
    }

    return valid;
}

$(document).on("click", "#open", function() { 
    const index = $(this).closest('.car').data('index'); 
    const selectedStorage = storageList[index]; 

    if (selectedStorage) {
        $('.popup-CreateAna2').css("display", "flex").show(); 
        $('.popup-CreateAna2').data('selectedStorage', selectedStorage);
    }
});

$('#openstashpassword').on('click', function(event) {
    event.preventDefault();

    const enteredPassword = $('#writeOpenStoragePassword').val();
    const selectedStorage = $('.popup-CreateAna2').data('selectedStorage');

    if (!selectedStorage) {
        return;
    }
    if (enteredPassword === selectedStorage.password) {
        $('.popup-CreateAna2').hide();
        $("html,body").hide();
        $.post("https://savana-storage/openStash", JSON.stringify({ data: selectedStorage }), function(response) {
        });
    } else {
        $.post("https://savana-storage/errorpass", JSON.stringify({}), function(response) {
        });
        $('#writeOpenStoragePassword').addClass('input-error');
        setTimeout(() => $('#writeOpenStoragePassword').removeClass('input-error'), 1000);
    }
});

$(document).on("click", ".popupButtonPass", function() { 
    const selectedStorage = $('.popup-CreateAna2').data('selectedStorage');
    $.post("https://savana-storage/checkowner", JSON.stringify({owner: selectedStorage.identifier}), function(response) {})
});

$(document).on("click", ".cancel", function() { 
    $('.resetPassword').hide()
});

$(document).on("click", ".ok", function() { 
    const oldPassword = document.getElementById('changePasswordFirst').value
    const newPassword = document.getElementById('changePasswordSecond').value
    const selectedStorage = $('.popup-CreateAna2').data('selectedStorage');
    if (oldPassword === selectedStorage.password && newPassword.length > 7 ) {
        $.post("https://savana-storage/changePassword", JSON.stringify({ new: newPassword, name: selectedStorage.name }), function(response) {
        });
        $('html,body').hide()
        $('.resetPassword').hide()
    } else {
        $.post("https://savana-storage/errorpasschanged", JSON.stringify({}), function(response) {})
        refreshInputs()
    }

});

$(document).on("click", "#favorite", function() {
    const imgElement = $(this).find("img");
    const currentSrc = imgElement.attr("src");
    const newSrc = currentSrc === "images/Favorite.png" ? "images/ActiveFavorite.png" : "images/Favorite.png";
    imgElement.attr("src", newSrc);

    const index = $(this).closest('.car').data('index');
    const selectedStorage = storageList[index];

    if (Array.isArray(selectedStorage.keyholders)) {
        if (selectedStorage.keyholders.includes(ownCitizenId)) {
            selectedStorage.keyholders = selectedStorage.keyholders.filter(id => id !== ownCitizenId);
        } else {
            selectedStorage.keyholders.push(ownCitizenId);
        }
    } else {
        selectedStorage.keyholders = [ownCitizenId];
    }

    $.post("https://savana-storage/setFavorite", JSON.stringify({ data: selectedStorage }), function(response) {
        loadData();
    });
});

$(document).on("click", "#searchFavorite", function() {
    const imgElement = $(this).find("img"); // #searchFavorite içindeki img elemanını bul
    const currentSrc = imgElement.attr("src");
    const newSrc = currentSrc === "images/Favorite.png" ? "images/ActiveFavorite.png" : "images/Favorite.png";
    imgElement.attr("src", newSrc);

    isFavoriteFilterActive = !isFavoriteFilterActive;

    loadData();
});

document.getElementById("writeStorageCapacity").addEventListener("input", function () { 
    const searchQuery = parseFloat(this.value) || 0;
    currentCapacityPrice = capacityPrice * searchQuery;
    refreshPrice();
});

document.getElementById("writeStorageWeight").addEventListener("input", function () {
    const searchQuery = parseFloat(this.value) || 0;
    currentWeightPrice = weightPrice * searchQuery;
    refreshPrice();
});

function refreshPrice() {
    totalPrice = currentCapacityPrice + currentWeightPrice + storagePrice;

    const popup2 = document.querySelector(".popupButtonBuy");
    popup2.innerHTML = `
        <p>${locales['purchaseButton']} ${totalPrice}</p>
    `;
}
