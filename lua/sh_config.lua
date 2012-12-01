PS.Config = {}

PS.Config.ShopKey = "F3"

PS.Config.CalculateSellPrice = function(original)
	return math.Round(original * 0.75)
end