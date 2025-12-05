
local Target = {
    Travellingmerchant = {
        vector4(-1108.51, -2744.57, -7.41, 322),
        vector4(2901.97, 4320.00, 50.41, 188),
        vector4(-1136.96, 4934.23, 222.27, 57),
    },
}

local loc = Target.Travellingmerchant[math.random(1, #Target.Travellingmerchant)]

local stores = {
	travel = {
		tab_paper 	     	= 50,
		bakingsoda 	     	= 25,
		isosafrole 	     	= 25,
		mdp2p 		     	= 25,
		lysergic_acid    	= 25,
		diethylamide     	= 25,
		lockpick  	     	= 2,
		emptyvial 	     	= 2,
		needle 		   	 	= 2,
		cokeburner 	     	= 25,
		crackburner 	 	= 2,
		lsdburner	   	 	= 2,
		heroinburner     	= 2,
		mdlean 		     	= 50,
		weedgrinder 	 	= 25,
		mdbutter 	     	= 25,
		flour 		     	= 25,
		chocolate  	     	= 25,
		butane 		     	= 25,
		butanetorch 	   	= 2,
		dabrig 		   		= 2,
		mdwoods 		   	= 2,
		leancup 		   	= 25,
		xtcburner 	   		= 25,
		empty_weed_bag   	= 5,
		sprunk 		     	= 10,
		singlepress 	 	= 10000,
		heroinlabkit 	 	= 10000,
		lsdlabkit 	 	 	= 10000,
		cleaningkit 	 	= 50,
	},
}

ps.registerCallback('md-drugs:server:GetMerchant', function(source)
	return {loc = loc, items = stores.travel}
end)



RegisterServerEvent("md-drugs:server:purchaseGoods", function(item)
	local src = source
	if not ps.checkDistance(src, loc, 10) then
		ps.notify(src, ps.lang('Catches.notIn'), "error")
		return
	end
	if not stores.travel[item] then
		ps.notify(src, ps.lang('Catches.invalidItem'), "error")
		return
	end
	if ps.removeMoney(src, 'cash', stores.travel[item]) then
		ps.addItem(src, item, 1)
	else
		ps.notify(src, ps.lang('Catches.notEnoughMoney'), "error")
	end
end)