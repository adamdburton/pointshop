PS.Config = {}

-- Edit below

PS.Config.ShopKey = "F3" -- F1, F2, F3 or F4

PS.Config.NotifyOnJoin = true -- Should players be notified about opening the shop when they spawn?

PS.Config.PointsOverTime = true -- Should players be given points over time?
PS.Config.PointsOverTimeDelay = 1 -- If so, how many minutes apart?
PS.Config.PointsOverTimeAmount = 10 -- And if so, how many points to give after the time?

-- Edit below if you know what you're doing

PS.Config.CalculateSellPrice = function(original)
	return math.Round(original * 0.75) -- 75% or 3/4 (rounded) of the original item price
end