local MPS = game:GetService("MarketplaceService")
local TweenService = game:GetService("TweenService")
local HTTP = game:GetService("HttpService")
local UIS = game:GetService("UserInputService")

local Player = game.Players.LocalPlayer

local TweenInfo1 = TweenInfo.new(0.7, Enum.EasingStyle.Cubic, Enum.EasingDirection.In)

local Template = script:WaitForChild("Template")
local ItemTemplate = script:WaitForChild("ItemTemplate")
local ReviewTemplate = script:WaitForChild("ReviewTemplate")
local BrowserTemplate = script:WaitForChild("BrowserTemplate")
local RuleBtnTemplate = script:WaitForChild("RuleTemplate[Btn]")
local ReportReasonTemplate = script:WaitForChild("ReasonTemplate")
local RuleDescriptionTemplate = script:WaitForChild("RuleDescriptionTemplate")

local MainFrame = script.Parent:WaitForChild("MainFrame")
local Browser = MainFrame:WaitForChild("Browser")
local GameReviewer = MainFrame:WaitForChild("GameReviewer")
local ReviewsFrame = GameReviewer:WaitForChild("Reviews")
local ReviewWriter = MainFrame:WaitForChild("ReviewWriter")
local RemovePostFrame = MainFrame:WaitForChild("RemovePostFrame")
local LoadingFrame = MainFrame:WaitForChild("LoadingFrame")
local ReportFrame = MainFrame:WaitForChild("ReportPostFrame")
local MessageFrame = MainFrame:WaitForChild("MessageFrame")
local BanFrame = MainFrame:WaitForChild("BanFrame")
local SearchBar = Browser:WaitForChild("SearchBar")
local InfoFrame = MainFrame:WaitForChild("InfoFrame")
local RulesFrame = MainFrame:WaitForChild("RulesFrame")
local WarnFrame = MainFrame:WaitForChild("WarnFrame")
local DonatingFrame = MainFrame:WaitForChild("DonationFrame")
local ConfirmationFrame = MainFrame:WaitForChild("ConfirmationFrame")
local ShopFrame = MainFrame:WaitForChild("ShopFrame")

local CharactersLimitDisplay = ReviewWriter:WaitForChild("CharactersLimit")

local AllGames = Browser:WaitForChild("AllGames")

local Events = game.ReplicatedStorage:WaitForChild("Events")
local Modules = game.ReplicatedStorage:WaitForChild("Modules")
local HandledGames = require(Modules:WaitForChild("HandledGames"))

local Short = require(Modules:WaitForChild("Short"))
local TimeConventer = require(Modules:WaitForChild("TimeConventer"))
local DraggableModule = require(script:WaitForChild("DraggableObject"))
local CustomizationInfo = require(Modules:WaitForChild("CustomizationSettings"))

local Reportdb = false
local CanInteract = true
local Likedb = false
local filtred = false
local LoadReviews = false
local FilterWorking = false
local SearchBlocked = false
local CanPerformAction = true
local PerformdbTime = 10
local GameId

local StartingTexts = {}
local PlayerPostsReported = {}
local ReportReasons = {"Spamming", "Swearing", "Offsite Links", "Inappropriate Content", "Inappropriate Username", "Other"}
local LikesColors = {["Like"] = Color3.fromRGB(185, 0, 255), ["Dislike"] = Color3.fromRGB(200, 0, 0)}

local CharactersLimit = 350

local GameIconId
local CurrentFilter = 1 -- FILTER LIST: 1 - ALL :: 2 - 1 Star Only :: 3 - 2 Star Only :: 4 - 3 Star only :: 5 - 4 Star only :: 6 - 5 Star only :: 7 - Only Vefiried

local thumbType = Enum.ThumbnailType.HeadShot
local thumbSize = Enum.ThumbnailSize.Size420x420

local PlayerIsDev = Events.RequestDevelopersList:InvokeServer(2)

local Dragging1 = DraggableModule.new(BanFrame)
Dragging1:Enable()

game.StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, false)

local function CloseAll()
	BanFrame.Visible = false
	RemovePostFrame.Visible = false
	ReviewWriter.Visible = false
	ReportFrame.Visible = false
	InfoFrame.Visible = false
end

for i, v in pairs(GameReviewer:GetChildren()) do
	if v:IsA("TextLabel") then
		StartingTexts[v.Name] = v.Text
	end
end

local PlayerWarns, ShownWarn = Events.ReturnWarns:InvokeServer()

if PlayerWarns > 0 and ShownWarn == false then
	WarnFrame.Visible = true

	if PlayerWarns > 0 and PlayerWarns <= 1 then
		WarnFrame.Title.Text = "⚠️WARNING! Your account has been warned by one of our moderation member. Right now you have: ".. PlayerWarns .." Warn. If you keep getting warned, you may get BANNED! ⚠️"
	elseif PlayerWarns > 1 then
		WarnFrame.Title.Text = "⚠️WARNING! Your account has been warned by one of our moderation member. Right now you have: ".. PlayerWarns .." Warns. If you keep getting warned, you may get BANNED! ⚠️"
	end

	MainFrame.Warns.Text = "Warns: ".. PlayerWarns
elseif PlayerWarns > 0 and ShownWarn == true then
	MainFrame.Warns.Text = "Warns: ".. PlayerWarns
end

local function LoadAdvancedGameData(GameId)
	local Data = Events.RequestGameData:InvokeServer(tonumber(GameId))

	if Data then
		if #Data.data <= 0 then
			LoadAdvancedGameData(GameId)
			return false
		end
	end

	return Data
end

local function PopUpFrame(Frame)
	local NewTween = TweenService:Create(Frame, TweenInfo.new(0.08, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {Position = Frame.Position})

	Frame.Position = UDim2.fromScale(Frame.Position.X.Scale, Frame.Position.Y.Scale + 0.025)
	Frame.Visible = true
	NewTween:Play()
end

local function Search(NewReview, CreatorUsername)
	if not SearchBlocked then
		local SearchBoxText = string.lower(tostring(GameReviewer.Reviews.SearchBar.SearchBox.Text))
		NewReview.Visible = string.find(CreatorUsername, SearchBoxText) and true or false

		CurrentFilter = 1
		GameReviewer.Reviews.Filters.Title.Text = "Filter: All"
	end
end

local WishList = {ShopFrame.Close, DonatingFrame.Close}

for i, v in pairs(DonatingFrame.Buttons:GetChildren()) do
	if v:IsA("GuiButton") then
		table.insert(WishList, v)
	end
end

local function ButtonActivation(key) -- run this when the UI is open
	for i, v in pairs(MainFrame:GetDescendants()) do
		if v:IsA("GuiButton") then
			if not table.find(WishList, v) then
				v.Active = key
			end
		end
	end
end

local function Filter(v)
	if CurrentFilter == 1 then
		v.Visible = true
	elseif CurrentFilter == 2 then
		if v.Rating:GetAttribute("Rating") == 1 then
			v.Visible = true
		else
			v.Visible = false
		end
	elseif CurrentFilter == 3 then
		if v.Rating:GetAttribute("Rating") == 2 then
			v.Visible = true
		else
			v.Visible = false
		end
	elseif CurrentFilter == 4 then
		if v.Rating:GetAttribute("Rating") == 3 then
			v.Visible = true
		else
			v.Visible = false
		end
	elseif CurrentFilter == 5 then
		if v.Rating:GetAttribute("Rating") == 4 then
			v.Visible = true
		else
			v.Visible = false
		end
	elseif CurrentFilter == 6 then
		if v.Rating:GetAttribute("Rating") == 5 then
			v.Visible = true
		else
			v.Visible = false
		end
	end
end

local function VoteFunction(NewReview, key, CurrentPostId)	
	if Likedb == false then
		Likedb = true
		local Resolut = Events.Vote:InvokeServer(GameId, CurrentPostId, key)

		if Resolut[1] >= 1 then
			if Resolut[3] == 1 then
				NewReview.Votes:FindFirstChild(key).ImageColor3 = LikesColors[key]
			elseif Resolut[3] == 2 then
				NewReview.Votes:FindFirstChild(key).ImageColor3 = Color3.fromRGB(255, 255, 255)
			elseif Resolut[3] == 3 then
				if key == "Like" then
					NewReview.Votes.Dislike.ImageColor3 = Color3.fromRGB(255, 255, 255)
					NewReview.Votes.Like.ImageColor3 = LikesColors["Like"]

					NewReview.Votes.QuantityD.Text = Resolut[4]
				else
					NewReview.Votes.Like.ImageColor3 = Color3.fromRGB(255, 255, 255)
					NewReview.Votes.Dislike.ImageColor3 = LikesColors["Dislike"]

					NewReview.Votes.QuantityL.Text = Resolut[4]
				end
			end

			NewReview.Votes:FindFirstChild("Quantity"..string.sub(key, 1, 1)).Text = tostring(Resolut[2])
		elseif Resolut[1] == 0 then
			MessageFrame.Description.Text = "You already ".. key.. "d this review!"
			MessageFrame.Title.Text = "Error!"
			PopUpFrame(MessageFrame)
		end

		wait(15)
		Likedb = false
	else
		MessageFrame.Description.Text = "Please wait before liking/disliking another review!"
		MessageFrame.Title.Text = "Slow down!"
		PopUpFrame(MessageFrame)
	end
end

local function LoadReview(InGameReviews, i, PlayerData)
	local NewReview = ReviewTemplate:Clone()
	local content, isReady = game.Players:GetUserThumbnailAsync(InGameReviews["UserIds"][i], thumbType, thumbSize)
	local Review = InGameReviews["Reviews"][i]
	local CurrentPostId = InGameReviews["PostId"][i]
	local CreatorUsername = string.lower(InGameReviews["Usernames"][i])

	local PlayerIsBanned = Events.RequestDevelopersList:InvokeServer(3, InGameReviews["UserIds"][i])
	local PlayerIsVerified = table.find(Events.GetVerifiedPeople:InvokeServer(), InGameReviews["UserIds"][i])

	NewReview.CreatorUsername.Text = CreatorUsername
	NewReview.DateOfCreation.Text = InGameReviews["Dates"][i]
	NewReview.Review.Text = Review
	NewReview.PlayerProfileImage.Image = content
	NewReview.Name = "Review".. i
	NewReview.BackgroundColor3 = CustomizationInfo.Info.BackgroundColors[InGameReviews["BC"][i]].Color
	NewReview.Review.TextColor3 = CustomizationInfo.Info.TextColor[InGameReviews["TC"][i]].Color

	NewReview.Votes.QuantityL.Text = Short.en(InGameReviews["Likes"][i])
	NewReview.Votes.QuantityD.Text = Short.en(InGameReviews["Dislikes"][i])

	if InGameReviews["Tag"][i] ~= "NoTag" then
		NewReview.Tag.Text = CustomizationInfo.Info.Tags[InGameReviews["Tag"][i]].Text
		NewReview.Tag.TextColor3 = CustomizationInfo.Info.Tags[InGameReviews["Tag"][i]].Color
	end

	NewReview.Rating:SetAttribute("Rating", InGameReviews["Ratings"][i])
	NewReview.Rating.UIGradient.Offset = Vector2.new(InGameReviews["Ratings"][i] / 5, 0)

	NewReview.Parent = GameReviewer.Reviews.Reviews
	NewReview.LayoutOrder = i

	if InGameReviews["Usernames"][i] == Player.Name then
		NewReview.Buttons.DeletePost.Visible = true
		NewReview.LayoutOrder = -1
	else
		NewReview.Buttons.ReportPost.Visible = true
	end

	if PlayerIsDev == true then
		NewReview.Buttons.BanButton.Visible = true
		NewReview.Buttons.DeletePost.Visible = true

		if PlayerIsVerified == nil then
			NewReview.Buttons.VerifyPerson.Visible = true
		end
	end

	if PlayerIsBanned ~= nil then
		NewReview.PlayerProfileImage.PlayerIsBanned.Visible = true
	end

	NewReview.Buttons.DeletePost.Activated:Connect(function()
		RemovePostFrame.Review.Text = Review
		RemovePostFrame.GameId.Value = GameId
		RemovePostFrame.UserId.Value = InGameReviews["UserIds"][i]

		CloseAll()
		PopUpFrame(RemovePostFrame)
	end)

	NewReview.Buttons.ReportPost.Activated:Connect(function()
		ReportFrame.Review.Text = Review
		ReportFrame.GameId.Value = GameId
		ReportFrame.UserId.Value = InGameReviews["UserIds"][i]
		ReportFrame.PostId.Value = CurrentPostId

		CloseAll()
		PopUpFrame(ReportFrame)
	end)

	NewReview.Buttons.BanButton.Activated:Connect(function()
		BanFrame.UserId.Value = InGameReviews["UserIds"][i]
		BanFrame.Title.Text = "Ban: ".. CreatorUsername

		CloseAll()
		PopUpFrame(BanFrame)
	end)

	NewReview.Buttons.VerifyPerson.Activated:Connect(function()
		if CanInteract == true then
			CanInteract = false
			local Resoult = Events.VerifyPerson:InvokeServer(InGameReviews["UserIds"][i])

			CloseAll()
			if Resoult == 1 then
				MessageFrame.Description.Text = "User successfully verified!"
				MessageFrame.Title.Text = "Success!"
				PopUpFrame(MessageFrame)

				PlayerIsVerified = true
				NewReview.Buttons.VerifyPerson.Visible = false
			elseif Resoult == 0 then
				MessageFrame.Description.Text = "This user is already verified!"
				MessageFrame.Title.Text = "Error!"
				PopUpFrame(MessageFrame)
			end
			wait(0.15)
			CanInteract = true
		end
	end)

	NewReview.Votes.Like.MouseButton1Click:Connect(function()
		VoteFunction(NewReview, "Like", CurrentPostId)
	end)

	NewReview.Votes.Dislike.MouseButton1Click:Connect(function()
		VoteFunction(NewReview, "Dislike", CurrentPostId)
	end)

	if PlayerData.LikedPosts[tostring(GameId)] then
		if table.find(PlayerData.LikedPosts[tostring(GameId)], CurrentPostId) then
			NewReview.Votes.Like.ImageColor3 = LikesColors["Like"]
		end
	end

	if PlayerData.DislikedPosts[tostring(GameId)] then
		if table.find(PlayerData.DislikedPosts[tostring(GameId)], CurrentPostId) then
			NewReview.Votes.Dislike.ImageColor3 = LikesColors["Dislike"]
		end
	end

	GameReviewer.Reviews.SearchBar.SearchBox:GetPropertyChangedSignal("Text"):Connect(function() Search(NewReview, CreatorUsername) end)

	Search(NewReview, CreatorUsername)
	Filter(NewReview)
end

local function LoadInfo(GameId, GameIconId)
	local Gamedata = LoadAdvancedGameData(GameId)
	local InGameReviews = Events.RequestData:InvokeServer(GameId)

	local PlayerData = Events:WaitForChild("GetPointsData[C]"):InvokeServer()

	for i, v in pairs(GameReviewer.Reviews.Reviews:GetChildren()) do
		if not v:IsA("UIListLayout") then
			v:Destroy()
		end
	end

	GameReviewer.Rating.UIGradient.Offset = Vector2.new(0, 0)
	GameReviewer.NumberofReviews.Text = "0 Reviews"
	GameReviewer.AvarageRating.Text = "Avarage Rating: 0"

	if Gamedata ~= false then
		for i, v in pairs(GameReviewer:GetChildren()) do
			if v:IsA("TextLabel") then
				if Gamedata.data[1][v.Name] ~= nil then
					if not v:FindFirstChild("ShortEn") then
						v.Text = StartingTexts[v.Name].. " ".. tostring(Gamedata.data[1][v.Name])
					else
						v.Text = StartingTexts[v.Name].. " ".. Short.en(tonumber(Gamedata.data[1][v.Name]))
					end

					if typeof(Gamedata.data[1][v.Name]) == "boolean" then
						if Gamedata.data[1][v.Name] == true then
							v.TextColor3 = Color3.fromRGB(0, 210, 0)
						else
							v.TextColor3 = Color3.fromRGB(235, 0, 0)
						end
					end
				end
			end
		end

		if Gamedata.data[1].creator.hasVerifiedBadge == true then
			GameReviewer.Creator.Text = "By: ".. Gamedata.data[1].creator.name.. " [☑️]"
		else
			GameReviewer.Creator.Text = "By: ".. Gamedata.data[1].creator.name
		end

		if GameIconId == 0 then
			GameReviewer.GameIcon.Image = "rbxassetid://15261549516"
		else
			GameReviewer.GameIcon.Image = "rbxassetid://".. GameIconId
		end
		GameReviewer.LastUpdated.Text = "Last Updated: ".. string.sub(Gamedata.data[1].updated, 1, 19)

		GameReviewer.description.TextScaled = false

		if not GameReviewer.description.TextFits then
			GameReviewer.description.TextScaled = true
		end

		if InGameReviews ~= nil then
			local avarageRating = 0
			local pool = 0

			for i, v in pairs(InGameReviews.Ratings) do
				pool += v
			end

			avarageRating = Short.RoundTo2Digits(pool / #InGameReviews.Ratings)

			GameReviewer.Rating.UIGradient.Offset = Vector2.new(avarageRating / 5, 0)
			GameReviewer.NumberofReviews.Text = #InGameReviews.Ratings.. " Reviews"
			GameReviewer.AvarageRating.Text = "Avarage Rating: ".. avarageRating
		end

		if InGameReviews ~= nil then
			spawn(function()
				local PlayerReviewPos = table.find(InGameReviews["UserIds"], Player.UserId)

				if PlayerReviewPos ~= nil then
					LoadReview(InGameReviews, PlayerReviewPos, PlayerData)
				end

				local LoadedIndex = {}

				for x, y in pairs(InGameReviews.Likes) do
					local Highest = 0
					local Index = 0

					for i, v in pairs(InGameReviews.Likes) do
						if LoadReviews == true then
							if not table.find(LoadedIndex, i) then
								if (v + InGameReviews.Dislikes[i]) >= Highest then
									Highest = v + InGameReviews.Dislikes[i]
									Index = i
								end
							end
						else
							break
						end
					end

					if Index > 0 then
						if InGameReviews["UserIds"][Index] ~= Player.UserId and LoadReviews == true then
							LoadReview(InGameReviews, Index, PlayerData)
						elseif LoadReviews == false then
							break
						end
					end

					table.insert(LoadedIndex, Index)
				end
			end)
		end
	else
		print("Unable to load game data, retrying")
	end
end

local function OpenInfo(GameId, GameIconId)
	for i, v in pairs(GameReviewer:GetChildren()) do
		if v:IsA("TextLabel") then
			v.Text = StartingTexts[v.Name].. " [No Data]"
		end
	end

	TweenService:Create(Browser, TweenInfo1, {Position = UDim2.new(0, 0, -1, 0)}):Play()
	TweenService:Create(GameReviewer, TweenInfo1, {Position = UDim2.new(0, 0, 0, 0)}):Play()
	GameReviewer.CanvasPosition = Vector2.new(0, 0)

	LoadInfo(GameId, GameIconId)
end

local function LoadGame(GameIdC, PlayerData, Destination, LO, ShowExtra)
	if GameIdC ~= nil then
		local NewGame = Template:Clone()
		local GameInfo = MPS:GetProductInfo(GameIdC)

		NewGame.Name = GameIdC
		NewGame.GameName.Text = GameInfo.Name
		NewGame.GameIcon.Image = "rbxassetid://".. GameInfo.IconImageAssetId
		NewGame.Parent = Destination
		NewGame.LayoutOrder = GameIdC
		
		if LO ~= nil then
			NewGame.LayoutOrder = LO
		end

		if GameInfo.Creator.HasVerifiedBadge == true then
			NewGame.GameCreator.Text = "By: ".. GameInfo.Creator.Name.. " [☑️]"
		else
			NewGame.GameCreator.Text = "By: ".. GameInfo.Creator.Name
		end

		local GameRating = Events.RequestGameRating:InvokeServer(GameIdC, 1)

		if GameRating ~= nil then
			local avarageRating = 0
			local pool = 0

			for i, v in pairs(GameRating) do
				pool += v
			end

			avarageRating = pool / #GameRating

			NewGame.Rating.UIGradient.Offset = Vector2.new(avarageRating / 5, 0)
		end
		
		if ShowExtra == "ReviewsCount" then
			NewGame.ReviewsCount.Text = Short.Comma(#GameRating).. " Reviews"
		end

		NewGame.LoadingText:Destroy()
		NewGame.Rating.Visible = true

		NewGame.Activated:Connect(function()
			if CanInteract == true then
				CanInteract = false
				LoadReviews = true

				GameIconId = GameInfo.IconImageAssetId
				GameId = GameIdC
				OpenInfo(GameIdC, GameInfo.IconImageAssetId)

				wait(0.9)
				CanInteract = true
			end
		end)

		for i, v in pairs(PlayerData.PostsPosted) do
			if tonumber(v.GameId) == tonumber(GameIdC) then
				NewGame.BackgroundColor3 = Color3.fromRGB(64, 139, 29)
				break
			end
		end

		Destination.CanvasSize = UDim2.new(0, Destination.UIListLayout.AbsoluteContentSize.X, 0, 0)
	end
end

local function GetTop50(AllRevied, ReviewsN)
	local Top50 = {}
	local broke = false
	local Highest = 0
	local Num = 0
	local Pos = 1
	local GameId = 0

	for Index = 1, 50 do
		if broke == false then
			for i, v in pairs(AllRevied) do
				if #Top50 < 50 and AllRevied ~= {} then	
					Num += 1
					if #v >= Highest then
						Highest = #v
						GameId = i
					end

					if Num >= (ReviewsN - #Top50) then
						Top50[Pos] = {GameId}
						AllRevied[GameId] = nil

						Highest = 0
						Num = 0
						Pos += 1
						GameId = 0
					end
				else
					broke = true
					break
				end
			end
		else
			break
		end
	end
		
	return Top50
end

local function UpdateSpecificBrowser(NewBrowser, key, GameIds)
	local PlayerData = Events:WaitForChild("GetPointsData[C]"):InvokeServer()

	NewBrowser.RefreshButton.ImageColor3 = Color3.fromRGB(75, 75, 75)

	for i, v in pairs(NewBrowser.Games:GetChildren()) do
		if v:IsA("ImageButton") then
			v:Destroy()
		end
	end

	if key == nil then
		for i, GameId in pairs(GameIds) do
			spawn(function()
				LoadGame(GameId, PlayerData, NewBrowser.Games)
			end)
		end
	elseif key == 1 then
		local FavouritedGames = Events:WaitForChild("GetPlayerFavouritedGames"):InvokeServer()

		if FavouritedGames.Data ~= "Favorites service not available" then
			local Games = 0

			for i, Info in pairs(FavouritedGames.Data.Items) do
				local CGameId = Events.RequestGameData:InvokeServer(Info.Item.UniverseId, 1)
				Games = i

				spawn(function()
					LoadGame(CGameId, PlayerData, NewBrowser.Games)
				end)
			end

			if Games <= 0 then
				NewBrowser.Empty.Visible = true
			end
		else
			warn("Unable to load Player's favourite games")
		end
	elseif key == 2 then
		local AllRevied, ReviewsN = Events.RequestGameRating:InvokeServer(nil, 2)
				
		if AllRevied ~= nil then
			local Top50 = GetTop50(table.clone(AllRevied), ReviewsN)
						
			for i, v in ipairs(Top50) do
				spawn(function()
					LoadGame(v[1], PlayerData, NewBrowser.Games, i, "ReviewsCount")
				end)
			end
		end
	elseif key == 3 then -- sort from best to wrost
		local AllRevied, ReviewsN = Events.RequestGameRating:InvokeServer(nil, 2)
		
		if AllRevied ~= nil then
			local Top50 = GetTop50(table.clone(AllRevied), ReviewsN)
			
			print(Top50)
			print(AllRevied)

			for i, Id in ipairs(Top50) do
				spawn(function()
					--LoadGame(Id, PlayerData, NewBrowser.Games, i)
				end)
			end
		end
	end

	spawn(function()
		wait(60)
		NewBrowser.RefreshButton.ImageColor3 = Color3.fromRGB(255, 255, 255)
	end)
end

local function SearchFromSearchbar()
	if CanInteract == true then
		CanInteract = false
		local GameIDFSB = tonumber(SearchBar.SearchBar.Text)

		if GameIDFSB then
			if GameIDFSB > 0 then
				GameIDFSB = tostring(GameIDFSB)
				local GameData = Events.RequestData:InvokeServer(GameIDFSB)
				local GameInfo = MPS:GetProductInfo(GameIDFSB)

				GameIconId = GameInfo.IconImageAssetId
				GameId = GameIDFSB
				OpenInfo(GameIDFSB, GameInfo.IconImageAssetId)
			end
		end

		wait(0.5)
		CanInteract = true
	end
end

local function Error_AproveButton(ErrorMessage)
	ReviewWriter.AproveButton.BackgroundColor3 = Color3.fromRGB(90, 90, 90)
	ReviewWriter.AproveButton.Title.Text = ErrorMessage
	ReviewWriter.AproveButton.Title.TextColor3 = Color3.fromRGB(200, 0, 0)

	wait(1.5)

	ReviewWriter.AproveButton.BackgroundColor3 = Color3.fromRGB(0, 220, 0)
	ReviewWriter.AproveButton.Title.Text = "Post"
	ReviewWriter.AproveButton.Title.TextColor3 = Color3.fromRGB(255, 255, 255)
end

ReviewWriter.AproveButton.Activated:Connect(function()
	if CanInteract == true then
		CanInteract = false

		if not filtred then
			if ReviewWriter.RatingN.Value > 0 then
				local InGameReviews = Events.RequestData:InvokeServer(ReviewWriter.GameId.Value)
				local CanReview = true

				if InGameReviews ~= nil then
					if table.find(InGameReviews["UserIds"], Player.UserId) then
						CanReview = false
					end
				end

				if CanReview then
					local FiltredText = Events.FilterText:InvokeServer(ReviewWriter.Review.Text)

					if FiltredText == false then
						CanReview = false
						filtred = false
						Error_AproveButton("Text was not filtered correctly!")
					else
						ReviewWriter.Review.Text = FiltredText
						filtred = true
						ReviewWriter.AproveButton.Title.Text = "Are you sure you want to post this review?"
					end
				else
					Error_AproveButton("You already posted a review here!")
				end
			else
				Error_AproveButton("Provide a rating in stars first!")
				filtred = false
			end
		else
			if CanPerformAction then
				CanPerformAction = false
				LoadingFrame.Visible = true
				ReviewWriter.Visible = false

				local Resoult = game.ReplicatedStorage.Events.SendReview:InvokeServer(ReviewWriter.GameId.Value, ReviewWriter.Review.Text, ReviewWriter.RatingN.Value)

				LoadingFrame.Visible = false

				if Resoult == 0 then
					MessageFrame.Title.Text = "Error"
					MessageFrame.Description.Text = "There was a problem while adding your review! Please try again later."
				else
					MessageFrame.Title.Text = "Post Added"
					MessageFrame.Description.Text = "Your review has been successfully added! Refresh the page to see it."
				end

				PopUpFrame(MessageFrame)

				ReviewWriter.AproveButton.Title.Text = "Post"
				filtred = false

				spawn(function()
					wait(PerformdbTime)
					CanPerformAction = true
				end)
			elseif CanPerformAction == false then
				ReviewWriter.Visible = false
				MessageFrame.Title.Text = "Error"
				MessageFrame.Description.Text = "Please wait before Performing another action!"

				PopUpFrame(MessageFrame)
			end
		end

		wait(0.2)
		CanInteract = true
	end
end)

ReviewWriter.Review.Changed:Connect(function()
	local Reviewlength = string.len(ReviewWriter.Review.Text)
	CharactersLimitDisplay.Text = Reviewlength.."/"..CharactersLimit

	if Reviewlength == CharactersLimit then
		CharactersLimitDisplay.TextColor3 = Color3.fromRGB(220, 0, 0)
	else
		CharactersLimitDisplay.TextColor3 = Color3.fromRGB(220, 220, 220)
	end

	ReviewWriter.Review.Text = ReviewWriter.Review.Text:sub(1, CharactersLimit)
	ReviewWriter.AproveButton.Title.Text = "Post"
	filtred = false
end)

RemovePostFrame.RemoveButton.Activated:Connect(function()
	if CanInteract == true and CanPerformAction then
		CanInteract = false
		CanPerformAction = false
		LoadingFrame.Visible = true
		RemovePostFrame.Visible = false

		local Resoult = Events.RemovePost:InvokeServer(RemovePostFrame.GameId.Value, RemovePostFrame.UserId.Value)

		if Resoult == 0 then
			MessageFrame.Title.Text = "Error"
			MessageFrame.Description.Text = "There was a problem while trying to remove your post! Please try again later."
		else
			MessageFrame.Title.Text = "Post Removed"
			MessageFrame.Description.Text = "Your post has been successfully removed! You can now post a new review."
		end

		PopUpFrame(MessageFrame)

		LoadingFrame.Visible = false

		wait(1)
		CanInteract = true

		spawn(function()
			wait(PerformdbTime)
			CanPerformAction = true
		end)
	elseif CanPerformAction == false then
		RemovePostFrame.Visible = false
		MessageFrame.Title.Text = "Error"
		MessageFrame.Description.Text = "Please wait before Performing another action!"

		PopUpFrame(MessageFrame)
	end
end)

ReportFrame.ReportButton.Activated:Connect(function()
	if CanInteract == true and Reportdb == false and not table.find(PlayerPostsReported, ReportFrame.PostId.Value) and CanPerformAction == true then
		CanInteract = false
		Reportdb = true
		CanPerformAction = false
		LoadingFrame.Visible = true
		ReportFrame.Visible = false

		local Resoult = Events.ReportPost:InvokeServer(ReportFrame.GameId.Value, ReportFrame.UserId.Value, ReportFrame.Reason.Value)

		if Resoult == 0 then
			MessageFrame.Title.Text = "Error"
			MessageFrame.Description.Text = "There was a problem while trying to report this review! Please try again later."
		else
			MessageFrame.Title.Text = "Post Reported"
			MessageFrame.Description.Text = "This review has been successfully reported! Our administration team will now decide what to do next."

			table.insert(PlayerPostsReported, ReportFrame.PostId.Value)

			spawn(function()
				wait(45)
				Reportdb = false
			end)
		end

		PopUpFrame(MessageFrame)

		LoadingFrame.Visible = false

		wait(1)
		CanInteract = true

		spawn(function()
			wait(PerformdbTime)
			CanPerformAction = true
		end)
	elseif Reportdb == true then
		ReportFrame.Visible = false
		MessageFrame.Title.Text = "Error"
		MessageFrame.Description.Text = "Please wait before reporting another review!"

		PopUpFrame(MessageFrame)
	elseif table.find(PlayerPostsReported, ReportFrame.PostId.Value) then
		ReportFrame.Visible = false
		MessageFrame.Title.Text = "Error"
		MessageFrame.Description.Text = "You already reported this post!"

		PopUpFrame(MessageFrame)
	elseif CanPerformAction == false then
		ReportFrame.Visible = false
		MessageFrame.Title.Text = "Error"
		MessageFrame.Description.Text = "Please wait before Performing another action!"

		PopUpFrame(MessageFrame)
	end
end)

MessageFrame.Close.MouseButton1Click:Connect(function()
	MessageFrame.Visible = false
end)

ReportFrame.ReturnButton.Activated:Connect(function()
	ReportFrame.Visible = false
end)

RemovePostFrame.ReturnButton.Activated:Connect(function()
	RemovePostFrame.Visible = false
end)

ReviewWriter.ReturnButton.Activated:Connect(function()
	ReviewWriter.Visible = false
	filtred = false
end)

InfoFrame.Close.Activated:Connect(function()
	InfoFrame.Visible = false
end)

BanFrame.ReturnButton.Activated:Connect(function()
	BanFrame.Visible = false
end)

WarnFrame.Close.MouseButton1Click:Connect(function()
	WarnFrame.Visible = false
end)

DonatingFrame.Close.Activated:Connect(function()
	DonatingFrame.Visible = false
end)

InfoFrame.Info.HowToGetPoints["Rules[O]"].Activated:Connect(function()
	InfoFrame.Visible = false
	PopUpFrame(RulesFrame)
end)

RulesFrame.Close.Activated:Connect(function()
	RulesFrame.Visible = false
end)

Browser:WaitForChild("InfoButton").Activated:Connect(function()
	PopUpFrame(InfoFrame)
end)

ReviewWriter.RulesButton.Activated:Connect(function()
	CloseAll()
	PopUpFrame(RulesFrame)
end)

ConfirmationFrame:WaitForChild("Disagree").MouseButton1Click:Connect(function()
	ConfirmationFrame.Visible = false
	PopUpFrame(MainFrame:FindFirstChild(ConfirmationFrame:GetAttribute("LastFrame")))
end)

DonatingFrame:GetPropertyChangedSignal("Visible"):Connect(function(key)
	if DonatingFrame.Visible == true then
		wait()
		ButtonActivation(false)
		MainFrame.BlackScreen.Visible = true
	else
		MainFrame.BlackScreen.Visible = false
		ButtonActivation(true)
	end
end)

ShopFrame:GetPropertyChangedSignal("Visible"):Connect(function(key)
	if ShopFrame.Visible == true then
		wait()
		ButtonActivation(false)
		MainFrame.BlackScreen.Visible = true
	else
		MainFrame.BlackScreen.Visible = false
		ButtonActivation(true)
	end
end)

GameReviewer.Reviews.Filters.Arrow.Activated:Connect(function()
	if CanInteract == true then
		CanInteract = false
		if GameReviewer.Reviews.Filters.MoreFilters.Visible == false then
			GameReviewer.Reviews.Filters.Arrow.Rotation = -90
			GameReviewer.Reviews.Filters.MoreFilters.Visible = true
		else
			GameReviewer.Reviews.Filters.Arrow.Rotation = 0
			GameReviewer.Reviews.Filters.MoreFilters.Visible = false
		end

		wait(0.5)
		CanInteract = true
	end
end)

ReportFrame.ReportReasonFrame.Arrow.Activated:Connect(function()
	if ReportFrame.ReportReasonFrame.MoreReasons.Visible == false then
		ReportFrame.ReportReasonFrame.Arrow.Rotation = -90
		ReportFrame.ReportReasonFrame.MoreReasons.Visible = true
	else
		ReportFrame.ReportReasonFrame.Arrow.Rotation = 0
		ReportFrame.ReportReasonFrame.MoreReasons.Visible = false
	end
end)


BanFrame.RemovePosts.Activated:Connect(function()
	if BanFrame.RemovePosts.a.Value == false then
		BanFrame.RemovePosts.a.Value = true
		BanFrame.RemovePosts.BackgroundColor3 = Color3.fromRGB(0, 235, 0)
	else
		BanFrame.RemovePosts.a.Value = false
		BanFrame.RemovePosts.BackgroundColor3 = Color3.fromRGB(210, 0, 0)
	end
end)

BanFrame.BanButton.Activated:Connect(function()
	LoadingFrame.Visible = true
	BanFrame.Visible = false
	local Duration = nil

	if tonumber(BanFrame.Duration.Text) == nil then
		Duration = math.huge
	else
		Duration = tonumber(BanFrame.Duration.Text)
	end

	local Resoult = Events.Ban:InvokeServer(BanFrame.UserId.Value, tostring(BanFrame.BanReason.Text), Duration, BanFrame.RemovePosts.a.Value)
	LoadingFrame.Visible = false

	if Resoult == 1 then
		MessageFrame.Title.Text = "Successfully banned"
		MessageFrame.Description.Text = 'Player "'.. BanFrame.UserId.Value..'" was successfully banned!'.. " He will be unbanned in: ".. Duration.. " Days."
	else
		MessageFrame.Title.Text = "Error"
		MessageFrame.Description.Text = "There was a problem while trying to ban this user! Please try again later."
	end

	PopUpFrame(MessageFrame)
end)

SearchBar.SearchButton.Activated:Connect(SearchFromSearchbar)

SearchBar.SearchBar.FocusLost:Connect(function(EnterPressed)
	if EnterPressed then
		SearchFromSearchbar()
	end
end)

GameReviewer.ReturnButton.Activated:Connect(function()
	if CanInteract == true then
		CanInteract = false

		GameReviewer.Reviews.SearchBar.SearchBox.Text = ""

		TweenService:Create(Browser, TweenInfo1, {Position = UDim2.new(0, 0, 0, 0)}):Play()
		TweenService:Create(GameReviewer, TweenInfo1, {Position = UDim2.new(0, 0, 1, 0)}):Play()
		ReviewWriter.Visible = false
		ReportFrame.Visible = false
		RemovePostFrame.Visible = false
		BanFrame.Visible = false
		LoadReviews = false
		SearchBlocked = true
		wait()
		SearchBlocked = false
		FilterWorking = false
		CurrentFilter = 1
		GameReviewer.Reviews.Filters.Title.Text = "Filter: All"

		wait(0.9)
		CanInteract = true
	end
end)

GameReviewer.ReviewButton.Activated:Connect(function()
	if CanInteract == true then
		CanInteract = false

		ReviewWriter.GameId.Value = GameId
		ReviewWriter.Review.Text = ""
		CloseAll()
		PopUpFrame(ReviewWriter)

		wait(0.9)
		CanInteract = true
	end
end)

for i, v in pairs(GameReviewer.Reviews.Filters.MoreFilters:GetChildren()) do
	if v:IsA("TextButton") then
		v.Activated:Connect(function()
			if CanInteract == true then
				local LastFilter = CurrentFilter
				CanInteract = false
				FilterWorking = false
				GameReviewer.Reviews.Filters.Arrow.Rotation = 0
				GameReviewer.Reviews.Filters.MoreFilters.Visible = false
				GameReviewer.Reviews.Filters.Title.Text = "Filter: ".. v.Name
				CurrentFilter = v:GetAttribute("FilterId")

				SearchBlocked = true
				GameReviewer.Reviews.SearchBar.SearchBox.Text = ""
				wait()
				SearchBlocked = false

				wait(0.05)
				FilterWorking = true

				spawn(function()
					if LastFilter ~= CurrentFilter then
						for i, v in pairs(GameReviewer.Reviews.Reviews:GetChildren()) do
							if v:IsA("Frame") and FilterWorking == true then
								Filter(v)
							elseif FilterWorking == false then
								break
							end
						end
					end
				end)

				wait(0.5)
				CanInteract = true
			end
		end)
	end
end

for i, v in ipairs(ReportReasons) do
	local NewReportTemplate = ReportReasonTemplate:Clone()

	NewReportTemplate.Parent = ReportFrame:WaitForChild("ReportReasonFrame"):WaitForChild("MoreReasons")
	NewReportTemplate.Text = v
	NewReportTemplate.Name = v
	NewReportTemplate.Size = UDim2.fromScale(1, 1 / #ReportReasons)

	NewReportTemplate.Activated:Connect(function()
		ReportFrame.Reason.Value = table.find(ReportReasons, v)
		ReportFrame.ReportReasonFrame.ReportReasonTitle.Text = v
		ReportFrame.ReportReasonFrame.MoreReasons.Visible = false

		ReportFrame.ReportReasonFrame.Arrow.Rotation = 0		
	end)
end

for i, v in pairs(ReviewWriter.Rating:GetChildren()) do
	if v:IsA("TextButton") then
		v.Activated:Connect(function()
			ReviewWriter.RatingN.Value = tonumber(v.Name)
			ReviewWriter.Rating.UIGradient.Offset = Vector2.new(ReviewWriter.RatingN.Value / 5, 0)
		end)
	end
end

local function ChangeShopFrameText(Text, Color)
	ShopFrame.ErrprCode.Text = Text
	ShopFrame.ErrprCode.TextColor3 = Color

	wait(1.5)

	ShopFrame.ErrprCode.Text = ""
end

for i, v in pairs(CustomizationInfo.Shop.CurrentShopOffer) do
	local PlayerData
	local Owned = false

	repeat 
		PlayerData = Events["GetPointsData[C]"]:InvokeServer()
	until PlayerData ~= nil

	local NewItem = ItemTemplate:Clone()
	NewItem.LayoutOrder = v.Index
	NewItem.Name = i
	NewItem.ItemName.Text = tostring(i)
	NewItem.ItemType.Text = v.Type
	NewItem.Price.Text = v.Price .. " Points"
	NewItem.ItemPreview.BackgroundColor3 = CustomizationInfo.Info[v.RType][v.Index].Color
	NewItem.Parent = ShopFrame.Content

	table.insert(WishList, NewItem.Buy)

	if table.find(PlayerData.Inventory, i) then
		Owned = true
		NewItem.Buy.Text = "Bought"
		NewItem.Buy.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
	end

	NewItem.Buy.Activated:Connect(function()
		if CanInteract == true and Owned == false and v.EndTime - os.time() >= 0 then
			CanInteract = false
			local Resoult = Events.Shop.Buy:InvokeServer(i)

			if Resoult == 2 then
				NewItem.Buy.Text = "Bought"
				NewItem.Buy.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
				game.SoundService:WaitForChild("PurchaseSound"):Play()

				ChangeShopFrameText('Successfully bought "'.. i .. '"!', Color3.fromRGB(0, 235, 0))				
			elseif Resoult == 1 then
				ChangeShopFrameText("You do not have enough Points to buy this product!", Color3.fromRGB(240, 0, 0))
			elseif Resoult == 0 then
				ChangeShopFrameText("Something went wrong while trying to buy this product!", Color3.fromRGB(240, 0, 0))
			end

			wait(0.4)
			CanInteract = true
		end
	end)
end

spawn(function()
	repeat
		local TimeTillEnd = 0

		for i, Item in pairs(ShopFrame.Content:GetChildren()) do
			if Item:IsA("Frame") and Item.Name ~= "LineBack" and Item.Name ~= "LineFront" then
				TimeTillEnd = CustomizationInfo.Shop.CurrentShopOffer[Item.Name].EndTime - os.time()

				if TimeTillEnd > 0 then
					Item.TimeLeft.Text = TimeConventer.ConvertSeconds(TimeTillEnd)
					Item.TimeLeft.TextColor3 = Color3.fromRGB(255, 255, 255)
				else
					Item.TimeLeft.Text = "00:00:00:00"
					Item.TimeLeft.TextColor3 = Color3.fromRGB(215, 0, 0)
				end
			end
		end

		task.wait(1)
	until TimeTillEnd < 0
end)

local Counter = 1

for i, v in pairs(CustomizationInfo.Rules) do
	local NewRule = RuleBtnTemplate:Clone()
	local CCounter = Counter
	local DescriptionId = Counter * 2
	NewRule.Name = i
	NewRule.LayoutOrder = Counter * 3
	NewRule.RuleName.Text = i

	NewRule.Arrow.MouseButton1Click:Connect(function()
		if NewRule.Arrow.Rotation == 0 then
			local NewDescription = RuleDescriptionTemplate:Clone()
			NewDescription.Description.Text = v
			NewDescription.LayoutOrder = (CCounter * 3) + 1
			NewDescription.Parent = RulesFrame.Content
			NewDescription.Name = DescriptionId

			NewRule.Arrow.Rotation = -90
		else
			NewRule.Arrow.Rotation = 0

			if RulesFrame.Content:FindFirstChild(tostring(DescriptionId)) then
				RulesFrame.Content:FindFirstChild(tostring(DescriptionId)):Destroy()
			end
		end
	end)

	NewRule.Parent = RulesFrame.Content

	Counter += 1
end

for i, v in pairs(HandledGames.Handled) do
	local NewBrowser = BrowserTemplate:Clone()
	local CanRefresh = false

	NewBrowser.Title.Text = tostring(v)
	NewBrowser.Parent = AllGames
	NewBrowser.Name = v

	if HandledGames.Ids[v] then
		UpdateSpecificBrowser(NewBrowser, nil, HandledGames.Ids[v])

		NewBrowser.RefreshButton.MouseButton1Click:Connect(function()
			if CanRefresh == true then
				CanRefresh = false

				UpdateSpecificBrowser(NewBrowser, nil, HandledGames.Ids[v])

				wait(60)
				CanRefresh = true
			end
		end)
	elseif v == "Favourited" then
		UpdateSpecificBrowser(NewBrowser, 1, nil)

		NewBrowser.RefreshButton.MouseButton1Click:Connect(function()
			if CanRefresh == true then
				CanRefresh = false

				UpdateSpecificBrowser(NewBrowser, 1, nil)

				wait(60)
				CanRefresh = true
			end
		end)
	elseif v == "Most Reviewed" then
		UpdateSpecificBrowser(NewBrowser, 2, nil)

		NewBrowser.RefreshButton.MouseButton1Click:Connect(function()
			if CanRefresh == true then
				CanRefresh = false

				UpdateSpecificBrowser(NewBrowser, 2, nil)

				wait(60)
				CanRefresh = true
			end
		end)
	elseif v == "Best Reviewed" then
		UpdateSpecificBrowser(NewBrowser, 3, nil)

		NewBrowser.RefreshButton.MouseButton1Click:Connect(function()
			if CanRefresh == true then
				CanRefresh = false

				UpdateSpecificBrowser(NewBrowser, 3, nil)

				wait(60)
				CanRefresh = true
			end
		end)
	end

	spawn(function()
		wait(60)
		CanRefresh = true
	end)
end