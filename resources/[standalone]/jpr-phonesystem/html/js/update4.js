var OpenedRaceElement = null;

$(document).on('click', '.racing-race', function(e){
    e.preventDefault();

    var OpenSize = "15vh";
    var DefaultSize = "9vh";
    var RaceData = $(this).data('RaceData');
    var IsRacer = IsInRace(DadosTelemovel["CitizenID"], RaceData.RaceData.Racers)

    if (!RaceData.RaceData.Started || IsRacer) {
        if (OpenedRaceElement === null) {
            $(this).css({"height":OpenSize});
            setTimeout(() => {
                $(this).find('.race-buttons').fadeIn(100);
            }, 100);
            OpenedRaceElement = this;
        } else if (OpenedRaceElement == this) {
            $(this).find('.race-buttons').fadeOut(20);
            $(this).css({"height":DefaultSize});
            OpenedRaceElement = null;
        } else {
            $(OpenedRaceElement).find('.race-buttons').hide();
            $(OpenedRaceElement).css({"height":DefaultSize});
            $(this).css({"height":OpenSize});
            setTimeout(() => {
                $(this).find('.race-buttons').fadeIn(100);
            }, 100);
            OpenedRaceElement = this;
        }
    } else {
        sendCustomNotification(Traducoes["184"][phoneLanguageOverall], "https://r2.fivemanage.com/PztPJI1MS4DPN1q0LBqaP/racing.png", Traducoes["183"][phoneLanguageOverall])
    }
});

function GetAmountOfRacers(Racers) {
    var retval = 0
    $.each(Racers, function(i, racer){
        retval = retval + 1
    });
    return retval
}

function IsInRace(CitizenId, Racers) {
    var retval = false;
    $.each(Racers, function(cid, racer){
        if (cid == CitizenId) {
            retval = true;
        }
    });
    return retval
}

function IsCreator(CitizenId, RaceData) {
    var retval = false;
    if (RaceData.SetupCitizenId == CitizenId) {
        retval = true;
    }
    return retval;
}

function SetupRaces(Races) {
    $(".racing-races").html("");
    if (Races.length > 0) {
        Races = (Races).reverse();
        $.each(Races, function(i, race){
            var Locked = '<i class="fas fa-unlock"></i> '+Traducoes["198"][phoneLanguageOverall]+'';
            if (race.RaceData.Started) {
                Locked = '<i class="fas fa-lock"></i> '+Traducoes["199"][phoneLanguageOverall]+'';
            }
            var LapLabel = "";
            if (race.Laps == 0) {
                LapLabel = Traducoes["200"][phoneLanguageOverall]
            } else {
                if (race.Laps == 1) {
                    LapLabel = race.Laps + " "+Traducoes["200"][phoneLanguageOverall]+"";
                } else {
                    LapLabel = race.Laps + " "+Traducoes["201"][phoneLanguageOverall]+"";
                }
            }
            var InRace = IsInRace(DadosTelemovel["CitizenID"], race.RaceData.Racers);
            var Creator = IsCreator(DadosTelemovel["CitizenID"], race);
            var Buttons = '<div class="race-buttons"> <div class="race-button" id="join-race" data-placement="left" title="Join"><i class="fas fa-sign-in-alt"></i></div>';
            if (InRace) {
                if (!Creator) {
                    Buttons = '<div class="race-buttons"> <div class="race-button" id="quit-race" data-placement="right" title="Quit"><i class="fas fa-sign-out-alt"></i></div>';
                } else {
                    if (!race.RaceData.Started) {
                        Buttons = '<div class="race-buttons"> <div class="race-button" id="start-race" data-placement="left" title="Start"><i class="fas fa-flag-checkered"></i></div><div class="race-button" id="quit-race" data-placement="right" title="Quit"><i class="fas fa-sign-out-alt"></i></div>';
                    } else {
                        Buttons = '<div class="race-buttons"> <div class="race-button" id="quit-race" data-placement="right" title="Quit"><i class="fas fa-sign-out-alt"></i></div>';
                    }
                }
            }
            var Racers = GetAmountOfRacers(race.RaceData.Racers);
            var element = '<div class="racing-race" id="raceid-'+i+'"> <span class="race-name"><i class="fas fa-flag-checkered"></i> '+race.RaceData.RaceName+'</span> <span class="race-track">'+Locked+'</span> <div class="race-infomation"> <div class="race-infomation-tab" id="race-information-laps">'+LapLabel+'</div> <div class="race-infomation-tab" id="race-information-distance">'+race.RaceData.Distance+' m</div> <div class="race-infomation-tab" id="race-information-player"><i class="fas fa-user"></i> '+Racers+'</div> </div> '+Buttons+' </div> </div>';
            $(".racing-races").append(element);
            $("#raceid-"+i).data('RaceData', race);
            if (!race.RaceData.Started) {
                $("#raceid-"+i).css({"border-bottom-color":"#34b121"});
            } else {
                $("#raceid-"+i).css({"border-bottom-color":"#b12121"});
            }
        });
    }
}

$(document).on('click', '#join-race', function(e){
    e.preventDefault();

    var RaceId = $(this).parent().parent().attr('id');
    var Data = $("#"+RaceId).data('RaceData');

    $.post('https://jpr-phonesystem/IsInRace', JSON.stringify({}), function(IsInRace){
        if (!IsInRace) {
            $.post('https://jpr-phonesystem/RaceDistanceCheck', JSON.stringify({
                RaceId: Data.RaceId,
                Joined: true,
            }), function(InDistance){
                if (InDistance) {
                    $.post('https://jpr-phonesystem/IsBusyCheck', JSON.stringify({
                        check: "editor"
                    }), function(IsBusy){
                        if (!IsBusy) {
                            $.post('https://jpr-phonesystem/JoinRace', JSON.stringify({
                                ...Data
                            }));
                            $.post('https://jpr-phonesystem/GetAvailableRaces', JSON.stringify({}), function(Races){
                                SetupRaces(Races);
                            });
                        } else {
                            sendCustomNotification(Traducoes["185"][phoneLanguageOverall], "https://r2.fivemanage.com/PztPJI1MS4DPN1q0LBqaP/racing.png", Traducoes["183"][phoneLanguageOverall])
                        }
                    });
                }
            })
        } else {
            sendCustomNotification(Traducoes["186"][phoneLanguageOverall], "https://r2.fivemanage.com/PztPJI1MS4DPN1q0LBqaP/racing.png", Traducoes["183"][phoneLanguageOverall])
        }
    });
});

$(document).on('click', '#quit-race', function(e){
    e.preventDefault();

    var RaceId = $(this).parent().parent().attr('id');
    var Data = $("#"+RaceId).data('RaceData');

    $.post('https://jpr-phonesystem/LeaveRace', JSON.stringify({
        RaceData: Data,
    }));

    $.post('https://jpr-phonesystem/GetAvailableRaces', JSON.stringify({}), function(Races){
        SetupRaces(Races);
    });
});

$(document).on('click', '#start-race', function(e){
    e.preventDefault();

    
    var RaceId = $(this).parent().parent().attr('id');
    var Data = $("#"+RaceId).data('RaceData');

    $.post('https://jpr-phonesystem/StartRace', JSON.stringify({
        RaceData: Data,
    }));

    $.post('https://jpr-phonesystem/GetAvailableRaces', JSON.stringify({}), function(Races){
        SetupRaces(Races);
    });
});

function secondsTimeSpanToHMS(s) {
    var h = Math.floor(s/3600); //Get whole hours
    s -= h*3600;
    var m = Math.floor(s/60); //Get remaining minutes
    s -= m*60;
    return h+":"+(m < 10 ? '0'+m : m)+":"+(s < 10 ? '0'+s : s); //zero padding on minutes and seconds
}

function CheckTrackInfos() {
    var value = $(".dropdown").val()

    if (value != null && value != undefined && value != "") {
        $.post('https://jpr-phonesystem/GetTrackData', JSON.stringify({
            RaceId: value
        }), function(TrackData){
            if ((TrackData.CreatorData.charinfo.lastname).length > 8) {
                TrackData.CreatorData.charinfo.lastname = TrackData.CreatorData.charinfo.lastname.substring(0, 8);
            }
            var CreatorTag = TrackData.CreatorData.charinfo.firstname.charAt(0).toUpperCase() + ". " + TrackData.CreatorData.charinfo.lastname;

            $(".racing-setup-information-distance").html(''+Traducoes["203"][phoneLanguageOverall]+': '+TrackData.Distance+' m');
            $(".racing-setup-information-creator").html(''+Traducoes["204"][phoneLanguageOverall]+': ' + CreatorTag);
            if (TrackData.Records.Holder !== undefined) {
                if (TrackData.Records.Holder[1].length > 8) {
                    TrackData.Records.Holder[1] = TrackData.Records.Holder[1].substring(0, 8) + "..";
                }
                var Holder = TrackData.Records.Holder[0].charAt(0).toUpperCase() + ". " + TrackData.Records.Holder[1];
                $(".racing-setup-information-wr").html(''+Traducoes["205"][phoneLanguageOverall]+': ' + secondsTimeSpanToHMS(TrackData.Records.Time) + ' ('+Holder+')');
            } else {
                $(".racing-setup-information-wr").html(''+Traducoes["205"][phoneLanguageOverall]+': N/A');
            }

            $("#racing-setup-informationheader").fadeIn(400)
            $(".racing-setup-information-distance").fadeIn(400)
            $(".racing-setup-information-creator").fadeIn(400)
            $(".racing-setup-information-wr").fadeIn(400)
        });

        $(this).parents('.dropdown').find('span').text($(this).text());
        $(this).parents('.dropdown').find('input').attr('value', value);
    }
}
/*End Dropdown Menu*/

$(document).on('click', '#setup-race', function(e){
    e.preventDefault();

    $("#racing-setup-informationheader").fadeOut(1)
    $(".racing-setup-information-distance").fadeOut(1)
    $(".racing-setup-information-creator").fadeOut(1)
    $(".racing-setup-information-wr").fadeOut(1)

    $(".racing-overview").animate({
        left: 30+"vh"
    }, 300);
    $(".racing-setup").animate({
        left: 0
    }, 300);

    $.post('https://jpr-phonesystem/GetRaces', JSON.stringify({}), function(Races){
        $(".dropdown").html("");
        if (Races != undefined && Races != null) {
            var elem = '<option selected>'+Traducoes["198"][phoneLanguageOverall]+'</option>'; 
            $(".dropdown").append(elem);

            $.each(Races, function(i, race){
                if (!race.Started && !race.Waiting) {
                    var elem = '<option id="'+race.RaceId+'" value = "'+race.RaceId+'">'+race.RaceName+'</option>'; 
                    $(".dropdown").append(elem);
                }
            });
        } else {
            var elem = '<option selected>'+Traducoes["197"][phoneLanguageOverall]+'</option>'; 
            $(".dropdown").append(elem);
        }
    });
});

$(document).on('click', '#create-race', function(e){
    e.preventDefault();
    $.post('https://jpr-phonesystem/IsAuthorizedToCreateRaces', JSON.stringify({}), function(data){
        if (data.IsAuthorized) {
            if (!data.IsBusy) {
                $.post('https://jpr-phonesystem/IsBusyCheck', JSON.stringify({
                    check: "race"
                }), function(InRace){
                    if (!InRace) {
                        $(".racing-create").fadeIn(200);
                    } else {
                        sendCustomNotification(Traducoes["187"][phoneLanguageOverall], "https://r2.fivemanage.com/PztPJI1MS4DPN1q0LBqaP/racing.png", Traducoes["183"][phoneLanguageOverall])
                    }
                });
            } else {
                sendCustomNotification(Traducoes["188"][phoneLanguageOverall], "https://r2.fivemanage.com/PztPJI1MS4DPN1q0LBqaP/racing.png", Traducoes["183"][phoneLanguageOverall])
            }
        } else {
            sendCustomNotification(Traducoes["189"][phoneLanguageOverall], "https://r2.fivemanage.com/PztPJI1MS4DPN1q0LBqaP/racing.png", Traducoes["183"][phoneLanguageOverall])
        }
    });
});

$(document).on('click', '#racing-create-accept', function(e){
    e.preventDefault();
    var TrackName = $(".racing-create-trackname").val();

    if (TrackName !== "" && TrackName !== undefined && TrackName !== null) {
        TrackName = DOMPurify.sanitize(TrackName , {
            ALLOWED_TAGS: [], 
            ALLOWED_ATTR: []
        });
        if (TrackName == '') TrackName = Traducoes["206"][phoneLanguageOverall]
        $.post('https://jpr-phonesystem/IsAuthorizedToCreateRaces', JSON.stringify({
            TrackName: TrackName
        }), function(data){
            if (data.IsAuthorized) {
                if (data.IsNameAvailable) {
                    $.post('https://jpr-phonesystem/StartTrackEditor', JSON.stringify({
                        TrackName: TrackName
                    }));
                    $(".racing-create").fadeOut(200, function(){
                        $(".racing-create-trackname").val("");
                    });
                } else {
                    sendCustomNotification(Traducoes["190"][phoneLanguageOverall], "https://r2.fivemanage.com/PztPJI1MS4DPN1q0LBqaP/racing.png", Traducoes["183"][phoneLanguageOverall])
                }
            } else {
                sendCustomNotification(Traducoes["191"][phoneLanguageOverall], "https://r2.fivemanage.com/PztPJI1MS4DPN1q0LBqaP/racing.png", Traducoes["183"][phoneLanguageOverall])
            }
        });
    } else {
        sendCustomNotification(Traducoes["192"][phoneLanguageOverall], "https://r2.fivemanage.com/PztPJI1MS4DPN1q0LBqaP/racing.png", Traducoes["183"][phoneLanguageOverall])
    }
});

$(document).on('click', '#racing-create-cancel', function(e){
    e.preventDefault();
    $(".racing-create").fadeOut(200, function(){
        $(".racing-create-trackname").val("");
    });
});

$(document).on('click', '#setup-race-accept', function(e){
    e.preventDefault();

    var track = $('.dropdown').val();
    var laps = $(".racing-setup-laps").val();

    if (laps != "" && track != "") {
        $.post('https://jpr-phonesystem/HasCreatedRace', JSON.stringify({}), function(HasCreatedRace){
            if (!HasCreatedRace) {
                $.post('https://jpr-phonesystem/RaceDistanceCheck', JSON.stringify({
                    RaceId: track,
                    Joined: false,
                }), function(InDistance){
                    if (InDistance) {
                        if (track !== undefined || track !== null) {
                            if (laps !== "") {
                                $.post('https://jpr-phonesystem/CanRaceSetup', JSON.stringify({}), function(CanSetup){
                                    if (CanSetup) {
                                        $.post('https://jpr-phonesystem/SetupRace', JSON.stringify({
                                            RaceId: track,
                                            AmountOfLaps: laps,
                                        }))
                                        $(".racing-overview").animate({
                                            left: 0+"vh"
                                        }, 300)
                                        $(".racing-setup").animate({
                                            left: -30+"vh"
                                        }, 300, function(){
                                            $(".racing-setup-laps").val("");
                                            $('.dropdown').val("");
                                        });
                                    } else {
                                        sendCustomNotification(Traducoes["193"][phoneLanguageOverall], "https://r2.fivemanage.com/PztPJI1MS4DPN1q0LBqaP/racing.png", Traducoes["183"][phoneLanguageOverall])
                                    }
                                });
                            } else {
                                sendCustomNotification(Traducoes["194"][phoneLanguageOverall], "https://r2.fivemanage.com/PztPJI1MS4DPN1q0LBqaP/racing.png", Traducoes["183"][phoneLanguageOverall])
                            }
                        } else {
                            sendCustomNotification(Traducoes["195"][phoneLanguageOverall], "https://r2.fivemanage.com/PztPJI1MS4DPN1q0LBqaP/racing.png", Traducoes["183"][phoneLanguageOverall])
                        }
                    }
                })
            } else {
                sendCustomNotification(Traducoes["196"][phoneLanguageOverall], "https://r2.fivemanage.com/PztPJI1MS4DPN1q0LBqaP/racing.png", Traducoes["183"][phoneLanguageOverall])
            }
        });
    }
});

$(document).on('click', '#setup-race-cancel', function(e){
    e.preventDefault();

    $(".racing-overview").animate({
        left: 0+"vh"
    }, 300);
    $(".racing-setup").animate({
        left: -30+"vh"
    }, 300, function(){
        $(".racing-setup-information-distance").html('Select a Track');
        $(".racing-setup-information-creator").html('Select a Track');
        $(".racing-setup-information-wr").html('Select a Track');
        $(".racing-setup-laps").val("");
        $('.dropdown').find('input').removeAttr('value');
        $('.dropdown').find('span').text("Select a Track");
    });
});

$(document).on('click', '.racing-leaderboard-item', function(e){
    e.preventDefault();

    var Data = $(this).data('LeaderboardData');

    $(".racing-leaderboard-details-block-trackname").html('<i class="fas fa-flag-checkered"></i> '+Data.RaceName);
    $(".racing-leaderboard-details-block-list").html("");
    $.each(Data.LastLeaderboard, function(i, leaderboard){
        var lastname = leaderboard.Holder[1]
        var bestroundtime = Traducoes["208"][phoneLanguageOverall];
        var place = i + 1;
        if (lastname.length > 10) {
            lastname = lastname.substring(0, 10) + "..."
        }
        if (leaderboard.BestLap !== Traducoes["209"][phoneLanguageOverall]) {
            bestroundtime = secondsTimeSpanToHMS(leaderboard.BestLap);
        } else {
            place = Traducoes["209"][phoneLanguageOverall]
        }
        var elem = '<div class="row"> <div class="name">' + ((leaderboard.Holder[0]).charAt(0)).toUpperCase() + '. ' + lastname + '</div><div class="time">'+bestroundtime+'</div><div class="score">'+ place +'</div> </div>';
        $(".racing-leaderboard-details-block-list").append(elem);
    });
    $(".racing-leaderboard-details").fadeIn(200);
});

$(document).on('click', '.racing-leaderboard-details-back', function(e){
    e.preventDefault();

    $(".racing-leaderboard-details").fadeOut(200);
});

$(document).on('click', '.racing-leaderboards-button', function(e){
    e.preventDefault();

    $(".racing-leaderboard").animate({
        left: -30+"vh"
    }, 300)
    $(".racing-overview").animate({
        left: 0+"vh"
    }, 300)
});

$(document).on('click', '#leaderboards-race', function(e){
    e.preventDefault();

    $.post('https://jpr-phonesystem/GetRacingLeaderboards', JSON.stringify({}), function(Races){
        if (Races !== null) {
            $(".racing-leaderboards").html("");
            $.each(Races, function(i, race){
                if (race.LastLeaderboard.length > 0) {
                    var elem = '<div class="racing-leaderboard-item" id="leaderboard-item-'+i+'"> <span class="racing-leaderboard-item-name"><i class="fas fa-flag-checkered"></i> '+race.RaceName+'</span> <span class="racing-leaderboard-item-info">'+Traducoes["207"][phoneLanguageOverall]+'</span> </div>'
                    $(".racing-leaderboards").append(elem);
                    $("#leaderboard-item-"+i).data('LeaderboardData', race);
                }
            });
        }
    });

    $(".racing-overview").animate({
        left: 30+"vh"
    }, 300)
    $(".racing-leaderboard").animate({
        left: 0+"vh"
    }, 300)
});

function sendCustomNotification(text, image, title) {
    var data = []
    data.app = "Custom"
    data.title = title
    data.img = image
    data.text = text
    JPR.iPhone.Functions.EnviarNotificacao(data)
}