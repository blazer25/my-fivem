const mapUpdateInterval = 5000;

function formatMoney(param) {
    // dollar example: return "$"+param;
    // BRL example: return "R$"+param;

    return param+"€";
}

function SearchRowsMDT() {
    var searchText = $("#mdtInput").val()
    if ((DadosTelemovel["Wifi"] == true) || (dadosdasdefs?.dadosmoveis == true && dadosdasdefs?.modovoo == false && DadosTelemovel["Signal"] == true)) {
        $("#semcondicoesmdt").fadeOut(1)
        if (currentInteraction == "citizen") {
            if (inputUsers) {
                var regist = searchInTable(inputUsers, searchText)

                if (regist) {
                    $(".infosMDTPanel span").css({"display":"none"})

                    for (let index = 0; index < regist.length; index++) {
                        const element = regist[index];
        
                        var charinfo = JSON.parse(element.charinfo)
        
                        var image = "male"
                        var gender = charinfo.gender
                        if (gender == 0) {
                            gender = "M"
                        } else {
                            image = "female"
                            gender = "F"
                        }
        
                        var job = JSON.parse(element.job)
                        
                        var mdtInfo = '<div class="infoBoxCitizen">'+
                            '<h1><b>'+Traducoes["174"][phoneLanguageOverall]+'</b>: '+element.citizenid+'</h1>'+
                            '<h1><b>'+Traducoes["175"][phoneLanguageOverall]+'</b>: '+charinfo.firstname+'</h1>'+
                            '<h1><b>'+Traducoes["176"][phoneLanguageOverall]+'</b>: '+charinfo.lastname+'</h1>'+
                            '<h1><b>'+Traducoes["177"][phoneLanguageOverall]+'</b>: '+charinfo.phone+'</h1>'+
                            '<h1><b>'+Traducoes["178"][phoneLanguageOverall]+'</b>: '+gender+'</h1>'+
                            '<h1><b>'+Traducoes["179"][phoneLanguageOverall]+'</b>: '+charinfo.birthdate+'</h1>'+
                            '<h1><b>'+Traducoes["180"][phoneLanguageOverall]+'</b>: '+job.label+'</h1>'+
                            '<h1><b>'+Traducoes["181"][phoneLanguageOverall]+'</b>: '+job.grade.name+'</h1>'+
                            '<h1><b>'+Traducoes["182"][phoneLanguageOverall]+'</b>: '+charinfo.account+'</h1>'+
                            '<img src="./img/mdt/'+image+'.png" alt="mdt">'+
                        '</div>'
        
                        $(".infoBoxMDT").append(mdtInfo);
                    }
                } else {
                    $(".infosMDTPanel span").css({"display":"block"})
                }
            } else {
                $(".infosMDTPanel span").css({"display":"block"})
            }
        } else if (currentInteraction == "vehicles") {
            if (inputHouses) {
                var regist = searchInTable(inputVehicles, searchText)

                if (regist) {
                    $(".infosMDTPanel span").css({"display":"none"})

                    for (let index = 0; index < regist.length; index++) {
                        const element = regist[index];

                        
                        var mdtInfo = '<div class="infoBoxVehicle">'+
                            '<h1><b>'+Traducoes["168"][phoneLanguageOverall]+'</b>: '+element.citizenid+'</h1>'+
                            '<h1><b>'+Traducoes["173"][phoneLanguageOverall]+'</b>: '+element.plate+'</h1>'+
                            '<h1><b>'+Traducoes["170"][phoneLanguageOverall]+'</b>: '+element.fuel+'%</h1>'+
                            '<h1><b>'+Traducoes["171"][phoneLanguageOverall]+'</b>: '+Math.ceil(element.body / 10)+"%"+'</h1>'+
                            '<h1><b>'+Traducoes["172"][phoneLanguageOverall]+'</b>: '+Math.ceil(element.engine / 10)+"%"+'</h1>'+
                            '<h1><b>'+Traducoes["165"][phoneLanguageOverall]+'</b>: '+element.garage+'</h1>'+
                            '<img src="./img/mdt/vehicle.png" alt="mdt">'+
                        '</div>'
        
                        $(".infoBoxMDT").append(mdtInfo);
                    }
                } else {
                    $(".infosMDTPanel span").css({"display":"block"})
                }
            } else {
                $(".infosMDTPanel span").css({"display":"block"})
            }
        } else if (currentInteraction == "houses") {
            if (inputHouses) {
                var regist = searchInTable(inputHouses, searchText)

                if (regist) {
                    $(".infosMDTPanel span").css({"display":"none"})

                    for (let index = 0; index < regist.length; index++) {
                        const element = regist[index];
                        
                        var mdtInfo = '<div class="infoBoxHouses">'+
                            '<h1><b>'+Traducoes["168"][phoneLanguageOverall]+'</b>: '+element.citizenid+'</h1>'+
                            '<h1><b>'+Traducoes["167"][phoneLanguageOverall]+'</b>: '+element.label+'</h1>'+
                            '<h1><b>'+Traducoes["166"][phoneLanguageOverall]+'</b>: '+element.keyholders+'</h1>'+
                            '<h1><b>'+Traducoes["165"][phoneLanguageOverall]+'</b>: '+element.tier+'</h1>'+
                            '<h1 class="gpsMDT" data-gps="'+index+'"><b>'+Traducoes["169"][phoneLanguageOverall]+'</b>: <i class="fa-solid fa-location-dot" style="color: rgb(171, 37, 37); cursor: pointer;"></i></h1>'+
                            '<img src="./img/mdt/house.png" alt="mdt">'+
                        '</div>'
        
                        $(".infoBoxMDT").append(mdtInfo);
                        $("[data-gps='" + index + "']").data('MeuMDTGps', element)  
                    }
                } else {
                    $(".infosMDTPanel span").css({"display":"block"})
                }
            } else {
                $(".infosMDTPanel span").css({"display":"block"})
            }
        }
    } else {
        $(".infosMDTPanel span").css({"display":"none"})
        $("#semcondicoesmdt").fadeIn(400)
    }
}


//nuncainstalou means first time opening x phone
if (nuncainstalou == true) {
    var texts = ["Bem-vindo", "Welcome", "Bienvenido", "Willkommen", "Benvenuto", "歡迎", "Добро пожаловать", "ようこそ", "환영합니다", "أهلاً وسهلاً", "ברוך הבא"];

    var point = 0;

    function changeText(){
        $("#parteiniciohello").css({"opacity":"0"})
        setTimeout(() => {
            if (pararmudarnome == false) {
                if (texts[point].length < 6) {
                    $('#parteiniciohello').css(({"font-size":"4.3vh"}));
                    $('#parteiniciohello').html(texts[point])
                } else {
                    $('#parteiniciohello').css(({"font-size":"3.7vh"}));
                    $('#parteiniciohello').html(texts[point]);
                }
                
                if(point < ( texts.length - 1 ) ){
                    point++;
                }else{
                    point = 0;
                }
                
                    $("#parteiniciohello").css({"opacity":"1"})
                }
            
        }, 500);
    }
    setInterval(changeText, 2800); /*Call it here*/
    changeText();
}

function TwitterBannerIcon() {
    return '<i class="fa-solid fa-cat"></i>'
}

function pickRealDateTime() {
    const agora = new Date();

    const obj = {
        hour: agora.getHours().toString().padStart(2, '0'), // hour
        minute: agora.getMinutes().toString().padStart(2, '0'), // minute
        mes: (agora.getMonth()).toString(), // month
        semana: (agora.getDay() + 6) % 7, // week
        dia: agora.getDate().toString().padStart(2, '0') // day
    };

    return obj;
}

function pickRealTime() {
    const agora = new Date();

    const obj = {
        hour: agora.getHours().toString().padStart(2, '0'), // hour
        minute: agora.getMinutes().toString().padStart(2, '0'), // minute
    };

    return obj;
}

function GetDefaultAppStoreElement() {
    var gradient = "linear-gradient(1deg,rgba(2, 2, 2, 1) 0%, rgba(2, 2, 2, 1) 21%, rgba(2, 2, 2, 0.89) 43%, rgba(2, 2, 2, 0.7) 60%, rgba(2, 2, 2, 0.32) 80%, rgba(2, 2, 2, 0.11) 100%)"

    if (DadosTelemovel["Tema"] == "claro") {
        gradient = "linear-gradient(1deg,rgba(255, 255, 255, 1) 0%, rgba(255, 255, 255, 1) 21%, rgba(255, 255, 255, 0.89) 43%, rgba(255, 255, 255, 0.7) 60%, rgba(255, 255, 255, 0.32) 80%, rgba(255, 255, 255, 0.11) 100%)"
    }

    var element = '<div class="appstore-bg">'+
            '<div class="appstore-blur-main"></div>'+
            '<h1 id="inicioappstore2" style="border: none;">auto</h1>'+
            '<h2>'+HTMLTranslations["translation394"][phoneLanguageOverall]+'</h2>'+
            '<div class="phone-contact-firstletter" id="avatarappstore3" style="background: '+$("#avatarappstore2").css("background")+'">'+$("#avatarappstore2").html()+'</div>'+

            '<div class="blur-bg-appstore">'+
                '<div class="blur-color-div" style="background: '+gradient+';"></div>'+
                '<h3>'+HTMLTranslations["translation449"][phoneLanguageOverall]+'</h3>'+

                '<div class="button-appstore-main">'+
                    '<h1>'+HTMLTranslations["translation450"][phoneLanguageOverall]+'</h1>'+
                '</div>'+
            '</div>'+
        '</div>'

    return element
}

$(document).ready(function () {
  const regexProibido = new RegExp(
    [
      '<\\s*script',         // tags <script
      '<\\s*/\\s*script\\s*>',
      'javascript:',         // links tipo javascript:
      'on\\w+\\s*=',         // eventos como onclick=
      '\\$\\.post',          // uso do jQuery para requisições
      'eval\\(',             // uso da função eval()
      'setTimeout\\(',       // execuções temporizadas
      'fetch\\(',            // requisições JS
      'XMLHttpRequest',      // tentativa de bypass
      'document\\.cookie',   // tentativas de roubo de sessão
      'innerHTML',           // manipulação de DOM perigosa
      'script>',             // qualquer coisa parecida com </script>
    ].join('|'),
    'i' // case insensitive
  );

  function limparSeInvalido($campo) {
    const valor = $campo.val();
    if (regexProibido.test(valor)) {
      $campo.val('');
    }
  }

  $('input, textarea').on('input', function () {
    limparSeInvalido($(this));
  });
});

$(document).on('click', '#shareGPS', function(e){
    e.preventDefault();

    $.post('https://jpr-phonesystem/shareGPS', JSON.stringify({}), function(){});
});

$(document).ready(function () {
    $(document).mouseup(function (e) {
      const div = $('.caixaAmpliarImagem');
  
      if (div.is(':visible') && !div.is(e.target) && div.has(e.target).length === 0) {
        JPR.iPhone.Functions.FecharZonaAmpliar()
      }
    });
});