require "enet"
local sock = require "sock"
all_players_in_scene={}
all_build_in_scene={}
all_vegetation_in_scene={}
function create_random_vegetation(lx)
ly=520
ltype=math.random(1,13)
if(ltype>10) then
ly=0
end
return {
type=ltype,
x=lx,
y=ly,
uid=random_string(10)
}
end
tick=0
function create_build(lx,ly,player_uid,ltype)
return {
x=lx,
y=ly,
uid_player=player_uid,
uid=random_string(11),
lvl=1,
type=ltype 
}
end
function create_player(lname,client_id,lx,ly)
return {
name=lname,
x=lx,
y=ly,
uid=random_string(9),
connect_id_client=client_id,
current_animation="",
is_mirror=false
}
end
function add_build_in_scene(build)
table.insert(all_build_in_scene,build)
end
function add_player_in_scene(obj)
table.insert(all_players_in_scene,obj)
end
function random_string(length)
	local res = ""
	for i = 1, length do
		res = res .. string.char(math.random(97, 122)) .. math.random(0,9)
	end
	return res
end
function find_player_by_id(id)
for i=1,#all_players_in_scene,1 do
if(all_players_in_scene[i].connect_id_client==id) then
return i
end
end
end
function can_place_build_in_position(lx)
for i=1,#all_build_in_scene,1 do
if math.abs(all_build_in_scene[i].x-lx)<100 then
return false
end
end
return true
end
function generate_world()
x=0
for i=1,2000, 1 do
table.insert(all_vegetation_in_scene,create_random_vegetation(x))
x=x+math.random(50,100)
end

end
function love.load()
	generate_world()
    -- Creating a server on any IP, port 22122
    server = sock.newServer("*", 22123)

		
	server:on("send_msg",function(msg,client)
	
	server:sendToAll("get_message",all_players_in_scene[find_player_by_id(client:getConnectId())].name .. ":" .. msg)
	end)
	server:on("get_player_server", function (player,client)
	if(player.is_mirror==nil) then
	player.is_mirror=all_players_in_scene[find_player_by_id(client:getConnectId())].is_mirror
	end
	player.x=all_players_in_scene[find_player_by_id(client:getConnectId())].x
	player.y=all_players_in_scene[find_player_by_id(client:getConnectId())].y
	all_players_in_scene[find_player_by_id(client:getConnectId())]=convert_cliet_player_to_server_player(all_players_in_scene[find_player_by_id(client:getConnectId())],player)
	if(player.is_mirror==false) then
	all_players_in_scene[find_player_by_id(client:getConnectId())].x=all_players_in_scene[find_player_by_id(client:getConnectId())].x+1
	else
	all_players_in_scene[find_player_by_id(client:getConnectId())].x=all_players_in_scene[find_player_by_id(client:getConnectId())].x-1
	end
	if(all_players_in_scene[find_player_by_id(client:getConnectId())].x<500) then
	all_players_in_scene[find_player_by_id(client:getConnectId())].x=500
	end
	if (all_players_in_scene[find_player_by_id(client:getConnectId())].x>9000) then
	all_players_in_scene[find_player_by_id(client:getConnectId())].x=9000
	end
	send_player(all_players_in_scene[find_player_by_id(client:getConnectId())])
	--print(all_players_in_scene[find_player_by_id(client:getConnectId())].connect_id_client .." NEW POS " .. all_players_in_scene[find_player_by_id(client:getConnectId())].x .. " " ..all_players_in_scene[find_player_by_id(client:getConnectId())].y)
	end)
	
    server:on("connect", function (data,client)
   -- Send a message back to the connected client
		print("Client connect")
		new_player=create_player(math.random(0,10000),client:getConnectId(),math.random(500,2000),500)
		add_player_in_scene(new_player)
		client:send("get_player",convert_server_player_to_client_player(new_player))
		client:send("builds",all_build_in_scene)
		client:send("vegetations",all_vegetation_in_scene)
		send_player(new_player)
	--	add_object_in_scene()
		
end)
server:on("create_build", function(ltype,lclient)

lplayer=all_players_in_scene[find_player_by_id(lclient:getConnectId())]
if(can_place_build_in_position(lplayer.x)) then
add_build_in_scene(create_build(lplayer.x,lplayer.y-65,lplayer.uid,ltype))
server:sendToAll("builds",all_build_in_scene)
end

end)

end
function convert_cliet_player_to_server_player(player,player2)
player.x=player2.x
player.y=player2.y
player.name=player2.name
player.current_animation=player2.current_animation
player.is_mirror=player2.is_mirror
return player
end
function convert_server_player_to_client_player(player)
return {
x=player.x,
y=player.y,
name=player.name,
current_animation=player.current_animation,
is_mirror=player.is_mirror
}

end
function send_player(player)
server:sendToAll("update_player",convert_server_player_to_client_player(player))

end
function local_update_server()
server:update()

end
function love.update(dt)
local result, err =pcall(local_update_server)
if err~=nil then
	print("ERR:" .. err)
end

end