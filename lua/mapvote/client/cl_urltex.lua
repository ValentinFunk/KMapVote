/*
	urltex.lua taken from PAC3 by CapsAdmin
	available under https://github.com/CapsAdmin/pac3/
*/

--If user has PAC installed, use the PAC urltex(might be more up2date)
if pac and pac.urltex then
	_G.urltex = pac.urltex
	return
end

local urltex = urltex or {}

urltex.TextureSize = 1024
urltex.ActivePanels = urltex.ActivePanels or {}
urltex.MaxConcurrent = 5
urltex.Queue = urltex.Queue or {}
urltex.Cache = urltex.Cache or {}

concommand.Add("pac_urltex_clear_cache", function()
	urltex.Cache = {}
	urltex.Queue = {}
end)

for k, v in pairs( urltex.ActivePanels ) do
	if v:IsValid( ) then
		v:Remove( )
	end
end

function urltex.GetMaterialFromURL(url, callback, skip_cache, shader, size, size_hack)
	if size_hack == nil then
		size_hack = true
	end
	shader = shader or "UnlitGeneric"
	
	url = url:gsub("https://", "http://")
	
	if type(callback) == "function" and not skip_cache and urltex.Cache[url] then
		local tex = urltex.Cache[url]
		local mat = CreateMaterial("pac3_urltex_" .. util.CRC(url .. SysTime()), shader)
		mat:SetTexture("$basetexture", tex)
		callback(mat, tex)
		return
	end
	if urltex.Queue[url] then
		local old = urltex.Queue[url].callback
		urltex.Queue[url].callback = function(...)	
			callback(...)
			old(...)
		end
	else
		urltex.Queue[url] = {callback = callback, tries = 0, size = size, size_hack = size_hack}
	end
end

function urltex.Think()
	if table.Count(urltex.Queue) > 0 then
		for url, data in pairs(urltex.Queue) do
			-- when the panel is gone start a new one
			local validPanels = 0
			for k, v in pairs( urltex.ActivePanels ) do
				if v:IsValid( ) then 
					validPanels = validPanels + 1
				end
			end
			
			if validPanels < urltex.MaxConcurrent then
				urltex.StartDownload(url, data)
			end
		end
		urltex.Busy = true
	else
		urltex.Busy = false
	end
end

timer.Create("urltex_queue_kmapvote", 0.001, 0, urltex.Think)

function urltex.StartDownload(url, data)
	local size = data.size or urltex.TextureSize

	local id = "urltex_download_" .. url
	
	local pnl = vgui.Create("HTML")
	pnl:SetVisible(true)
	--pnl:SetPos(50,50)
	pnl:SetPos(ScrW()-1, ScrH()-1)
	pnl:SetSize(size, size)
	pnl:SetHTML(
		[[
			<style type="text/css">
				html 
				{			
					overflow:hidden;
					]].. (data.size_hack and "margin: -8px -8px;" or "margin: 0px 0px;") ..[[
				}
			</style>
			
			<body>
				<img src="]] .. url .. [[" alt="" width="]] .. size..[[" height="]] .. size .. [[" />
			</body>
		]]
	)
	

	local function start()
		local go = false
		local time = 0

		-- restart the timeout
		timer.Stop(id)
		timer.Start(id)
	
		hook.Add("Think", id, function()
		
			-- panel is no longer valid
			if not pnl:IsValid() then
				hook.Remove("Think", id)
				-- let the timeout handle it
				return
			end
			
			local html_mat = pnl:GetHTMLMaterial()
					
			-- give it some time.. IsLoading is sometimes lying
			if not go and html_mat and not pnl:IsLoading() then
				time = RealTime( ) + 0.1
				go = true
			end
				
			if go and time < RealTime( ) then
				local vertex_mat = CreateMaterial("pac3_urltex_" .. util.CRC(url .. SysTime()), "VertexLitGeneric")
				
				local tex = html_mat:GetTexture("$basetexture")
				tex:Download()
				vertex_mat:SetTexture("$basetexture", tex)				
				
				tex:Download()
				
				urltex.Cache[url] = tex
				
				hook.Remove("Think", id)
				timer.Remove(id)
				urltex.Queue[url] = nil
				timer.Simple(0, function() pnl:Remove() end)
								
				if data.callback then
					data.callback(vertex_mat, tex)
				end
			end
			
		end)
	end

	start()
	
	-- 5 sec max timeout
	timer.Create(id, 5, 1, function()
		timer.Remove(id)
		urltex.Queue[url] = nil
		pnl:Remove()
		
		if hook.GetTable().Think[id] then
			hook.Remove("Think", id)
		end

		if data.tries < 5 then
			print("material download %q timed out.. trying again for the %ith time", url, data.tries)
			-- try again
			data.tries = data.tries + 1
			urltex.GetMaterialFromURL(url, data)
			urltex.Queue[url] = data
		else
			print("material download %q timed out for good", url, data.tries)
		end
	end)
	
	table.insert( urltex.ActivePanels, pnl )
end

_G.urltex = urltex