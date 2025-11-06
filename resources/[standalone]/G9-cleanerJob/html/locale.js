function setLang(data) {
    $('.header .headerText').html(data.header)
    $('.level .textArea').html(data.headerComment)
    $('.job .text').html(data.streetComment)
    $('#garden .text').html(data.gardenComment)
    $('.start').html(data.startJob)
    $('.job .img p').html(data.streetName)
    $('#garden .img p').html(data.gardenName)
}