//// okokBilling Support example:


$(document).on('click', '.carteira-app-footer-button', function(e){
    e.preventDefault();

    if (InvoiceScript == "okokBilling") {
        var menu = $(this).data('interacao');
        var Informacoes = $("[data-interacao='"+menu+"']").data('interacao');

        setTimeout(() => {
            if (Informacoes == "faturas") {
                JPR.iPhone.Functions.ClosePhoneSystem()
                
                $.post("https://jpr-phonesystem/openOKOKBilling", JSON.stringify({}));

                Informacoes = "informacoes"
            }
        
           /* $("#carteira-"+antigomenuwallet+"").fadeOut(400)
            $("#carteira-"+Informacoes+"").fadeIn(400)
        
            $("[data-interacao='"+antigomenuwallet+"']").removeClass("carteira-selected-footer-tab")
            $("[data-interacao='"+Informacoes+"']").addClass("carteira-selected-footer-tab")
        
            antigomenuwallet = Informacoes*/
        
        }, 500);
    }
});

$(document).ready(function(){
    window.addEventListener('message', function(event) {
        switch(event.data.action) {
            case "TakePhotoForced": 
                $('#areainteracaocamara .botaointeracao').click();
                break;
            case "SwapCam": 
                swpCam();
                break;
        }
    })
});
