require "enet"
local socket=require'socket'
local sock = require "sock"
all_players_in_scene={}
all_build_in_scene={}
all_vegetation_in_scene={}
tick=0
all_cats_in_scene={}
all_type_builds={"home","fortress","wall","tower","shop","negotiation_house"}
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
uid=random_string(10),
hp=100
}
end
tick=0
function init_update_cost(ltype)
if(ltype=="home") then
return { 
{0,0,0,0,1},
{5,0,0,0,0},
{10,5,0,0,0},
{10,10,5,0,0},
{10,10,10,5,0}
}
end
if(ltype=="wall") then
return { 
{0,0,0,0,1},
{5,0,0,0,0},
{10,5,0,0,0},
{10,10,5,0,0},
{10,10,10,5,0}
}
end
if(ltype=="fortress") then
return { 
{0,0,0,0,1},
{5,0,0,0,0},
{10,5,0,0,0},
{10,10,5,0,0},
{10,10,10,5,0}
}
end
if(ltype=="tower") then
return { 
{0,0,0,0,1},
{5,0,0,0,0},
{10,5,0,0,0},
{10,10,5,0,0},
{10,10,10,5,0}
}
end
if(ltype=="negotiation_house") then
return { 
{0,0,0,0,1}
}
end

end
function create_cat(lx,ly,player_uid,type)
main_table={
x=lx,
y=ly,
uid_player=player_uid,
uid=random_string(13),
lvl=1,
type=ltype,
animator=nil,
anim="stand",
is_mirror=false
}

if ltype=="woodcutter" or ltype == "miner" then
table_res={
amount_resources=0,
resource_build=nil
}
setmetatable(table_res,{__index=main_table})
else
table_res={

}
setmetatable(table_res,{__index=main_table})


end

return table_res
end
function convert_server_cat_to_client_cat(cat)
return {
x=cat.x,
y=cat.y,
uid_player=cat.uid_player,
uid=cat.uid,
lvl=cat.lvl,
type=cat.type,
animator=nil,
anim=cat.anim,
is_mirror=cat.is_mirror


}

end
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
is_mirror=false,
resources={0,0,0,0,10,10},
my_builds={},
my_cats={}
}
end
function add_cat_in_scene(cat)
table.insert(all_cats_in_scene,cat)
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
x=x+math.random(70,200)
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
		new_player=create_player(math.random(0,10000),client:getConnectId(),math.random(1000,2000),500)
		add_player_in_scene(new_player)
		all_cost={}
	for i=1,#all_type_builds,1 do
	all_cost[all_type_builds[i]]=init_update_cost(all_type_builds[i])
	print("NA:" .. all_type_builds[i])
	end
	new_player_send=convert_server_player_to_client_player(new_player)
	new_player_send.uid=new_player.uid
		client:send("get_player",new_player_send)
		client:send("builds",all_build_in_scene)
		client:send("vegetations",all_vegetation_in_scene)
		for i=1,#all_cats_in_scene,1 do
		client:send("update_cat",convert_server_cat_to_client_cat(all_cats_in_scene[i]))
		end
	client:send("send_cost_build",all_cost)
		send_player(new_player)
	--	add_object_in_scene()
		
end)
server:on("create_cat", function(data,lclient)
ltype=data[1]
lbuild=data[2]
lplayer=all_players_in_scene[find_player_by_id(lclient:getConnectId())]

add_cat_in_scene(create_cat(lbuild.x+math.random(0,100),lbuild.y+65,lbuild.uid_player,ltype))
table.insert(all_players_in_scene[find_player_by_id(lclient:getConnectId())].my_cats,all_cats_in_scene[#all_cats_in_scene])
server:sendToAll("update_cat",convert_server_cat_to_client_cat(all_cats_in_scene[#all_cats_in_scene]))


end)
server:on("create_build", function(ltype,lclient)

lplayer=all_players_in_scene[find_player_by_id(lclient:getConnectId())]
if(can_place_build_in_position(lplayer.x) and can_buy_build(lclient,ltype)) then
add_build_in_scene(create_build(lplayer.x,lplayer.y-65,lplayer.uid,ltype))
table.insert(all_players_in_scene[find_player_by_id(lclient:getConnectId())].my_builds,all_build_in_scene[#all_build_in_scene])
server:sendToAll("builds",all_build_in_scene)
end

end)
end

function can_buy_build(lclient,ltype)
build_cost=init_update_cost(ltype)
lplayer=all_players_in_scene[find_player_by_id(lclient:getConnectId())]
if(lplayer.resources[1]-build_cost[1][1]>=0 and lplayer.resources[2]-build_cost[1][2]>=0 and lplayer.resources[3]-build_cost[1][3]>=0  and lplayer.resources[4]-build_cost[1][4]>=0 and  lplayer.resources[5]-build_cost[1][5]>=0) then
for i=1,4,1 do
all_players_in_scene[find_player_by_id(lclient:getConnectId())].resources[i]=all_players_in_scene[find_player_by_id(lclient:getConnectId())].resources[i]-build_cost[1][i]
end
all_players_in_scene[find_player_by_id(lclient:getConnectId())].resources[5]=all_players_in_scene[find_player_by_id(lclient:getConnectId())].resources[5]-build_cost[1][5]

lclient:send("update_resources",all_players_in_scene[find_player_by_id(lclient:getConnectId())].resources)
return true
end
return false
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
is_mirror=player.is_mirror,
uid=-1
}

end
function send_player(player)
server:sendToAll("update_player",convert_server_player_to_client_player(player))

end
function local_update_server()
server:update()

end
function find_nearest_vegetation(x1,ltypes)
x3=1000000000
id=nil
for i=1,#all_vegetation_in_scene,1 do
this_ltype=false
for q=1,#ltypes,1 do
if all_vegetation_in_scene[i].type==ltypes[q] then
this_ltype=true
end
end
if math.abs(all_vegetation_in_scene[i].x-x1)<x3  and this_ltype==true then
x3=math.abs(all_vegetation_in_scene[i].x-x1)
id=i
end
end
return id
end
function find_build(builds,ltype)
for i=1,#builds,1 do
if builds[i].type==ltype then
return builds[i]
end
end
return nil
end
function move_cat(cat,x)
if(cat.x<x) then
cat.is_mirror=false
cat.x=cat.x+5
else

cat.is_mirror=true
cat.x=cat.x-5
end

end
function damage_vegetation(vegetation_id,damage)
all_vegetation_in_scene[vegetation_id].hp=all_vegetation_in_scene[vegetation_id].hp-damage

if(all_vegetation_in_scene[vegetation_id].hp<0) then
table.remove(all_vegetation_in_scene,vegetation_id)
server:sendToAll("vegetations",all_vegetation_in_scene)
return true
else
return false
end
end
function active_woodcutter_and_miner_ii(cat)
id=-1
if(cat.anim~="stand2" and cat.anim ~="run2")  then
	if cat.type=="miner" then
		id=find_nearest_vegetation(cat.x,{1,2,3,4,5,6,7,8})
		cat.resource_build=all_vegetation_in_scene[id]
else
		id=find_nearest_vegetation(cat.x,{10})
		cat.resource_build=all_vegetation_in_scene[id]
end 

	if math.abs(cat.x-cat.resource_build.x)>6 then
		cat.anim="run"
		move_cat(cat,cat.resource_build.x)
	else 
		cat.anim="work"
		if(cat.type=="miner" and ((damage_vegetation(find_nearest_vegetation(cat.x,{1,2,3,4,5,6,7,8}),math.random())==true) or  damage_vegetation(find_nearest_vegetation(cat.x,{10}),math.random())==true)) then
			cat.anim="stand2"
		end
	end
else if(find_player_by_uid(cat.uid_player)~=nil) then
	pl=find_player_by_uid(cat.uid_player)
	if (pl~=nil) then
		buildd=find_build(pl.my_builds,"fortress")
		if(buildd~=nil) then
			cat.anim="run2"
			if math.abs(cat.x-buildd.x)<6 then
				cat.anim="stand"
				if(cat.resource_build.type<=3) then
					pl.resources[1]=pl.resources[1]+10
				end
				if(cat.resource_build.type>=3 and cat.resource_build.type<6) then
					pl.resources[2]=pl.resources[2]+10
				end
				if(cat.resource_build.type>=6 and cat.resource_build.type<9) then
					pl.resources[3]=pl.resources[3]+10
				end
				if(cat.resource_build.type==10) then
					pl.resources[4]=pl.resources[4]+10
				end
				cat.resource_build=nil
				server:getClientByConnectId(pl.connect_id_client):send("update_resources",pl.resources)
			else
			move_cat(cat,buildd.x)
			end
		end
	end
else

end
end
end



function find_player_by_uid(uid)
for i=1,#all_players_in_scene,1 do
if(all_players_in_scene[i].uid==uid) then
return all_players_in_scene[i]
end
end
return nil
end
function active_cat_ii()
for i=1,#all_cats_in_scene,1 do

if all_cats_in_scene[i].type=="miner" or all_cats_in_scene[i].type=="woodcutter" then
active_woodcutter_and_miner_ii(all_cats_in_scene[i])
end
server:sendToAll("update_cat",convert_server_cat_to_client_cat(all_cats_in_scene[i]))

end

end
function love.update(dt)
local result, err =pcall(local_update_server)
tick=tick+dt
if(tick>1/20) then
active_cat_ii()
tick=0
end
if err~=nil then
	print("ERR:" .. err)
	
end

end