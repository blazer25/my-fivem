var Traducoes = {
    "1": "Property Description",
    "2": "Extras",
    "3": "Location",
    "4": "EUR",
    "5": "Pool",
    "6": "Garden",
    "7": "Cameras",
    "8": "None",
    "9": "and",
    "10": "This property cannot be visited",
    "11": "You can take a tour of this house before buying it for only ",
    "12": "<br>Just select the button in the lower right corner to start the tour.",
    "13": "Unavailable",
    "14": "You don't have enough money!",
    "15": "Purchase successful",
    "16": "Set",
    "17": "Key",

    "18": "Current Level",
    "19": "Next Level",
    "20": "Current Slots",
    "21": "Current Space",
    "22": "Next Level Slots",
    "23": "Next Level Space",
    "24": "Upgrade Value",

    "25": "€",
    "26": "KG",

    "27": "Vehicle",
    "28": "Turbo",
    "29": "Engine",
    "30": "Brakes",
    "31": "Transmission",
    "32": "Suspension",
    "33": "Engine Health",
    "34": "Body Health",
    "35": "Fuel",
    "36": "Condition",

    "37": "Yes",
    "38": "No",

    "39": "Saved",
    "40": "Seized",
    "41": "Out",

    "42": "Write something!",
    "43": "Invalid Citizen ID.",
    "44": "This Citizen ID already has a copy of the key or already have a appartment here.",
    "45": "Action completed successfully.",
    "46": "You cannot remove the house owner or yourself.",
    "47": "Closet updated.",

    "48": "slots",
    "49": "You have",

    "50": "Changed Textures",
    "51": "Put something in the URL!",

    "52": "Change the name as it already exists!",
    "53": "Style: ",
    "54": "No garage",
    "55": "Fill all fields!",
    "56": "items",
    "57": "Just you can be inside of house / apartment",

    "58": "Prop name",
    "59": "Prop hash",
    "60": "Get coords",
    "61": "Prop coords",
    "62": "Really, zero doors??",

    "63": "House name",
    "64": "Price",
    "65": "Sold",
    "66": "Is apartment",
    "67": "Rent for:",
    "68": "Something wrong happened",
}

function FormatCurrency(amount) {
    // for GBT format: new Intl.NumberFormat('en-GB', { style: 'currency', currency: 'GBP' }).format(parseInt(amount))
    
    return new Intl.NumberFormat('de-DE', { 
        style: 'currency', 
        currency: 'EUR', 
        minimumFractionDigits: 0, 
        maximumFractionDigits: 0 
    }).format(parseInt(amount));
}