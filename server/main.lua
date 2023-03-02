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
hp=500
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
table_res={}
if ltype=="woodcutter" then
table_res={
amount_resources=0,
max_amount_resources=2,
resource_build=nil
}
elseif ltype == "miner" then
table_res={
amount_resources=0,
max_amount_resources=2,
resource_build=nil,
type_miner=1
}
elseif ltype=="shield" or ltype=="priest" then
table_res={
target_player=nil
}
elseif ltype=="sword" or ltype=="archer" then
table_res={
front_is_left=true
}

else
end
setmetatable(table_res,{__index=main_table})
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
function create_sheel(cat)
return {
x=cat.x
}
end
function create_build(lx,ly,player_uid,ltype)
start_x=lx-50
return {
x=start_x,
center_x=start_x+30,
y=ly,
uid_player=player_uid,
uid=random_string(11),
lvl=1,
hp=100,
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
priority={0,0,0,0,50,50},
my_builds={},
my_cats={},
relationship={},
has_start_build=false
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
function find_player_by_name(name)
for i=1,#all_players_in_scene,1 do
if(all_players_in_scene[i].name==name) then
return i
end
end
return -1
end
function find_player_by_id(id)
for i=1,#all_players_in_scene,1 do
if(all_players_in_scene[i].connect_id_client==id) then
return i
end
end
end
function can_place_build_in_position(pl)
for i=1,#all_build_in_scene,1 do
if (math.abs(all_build_in_scene[i].x-pl.x)<100 and all_build_in_scene[i].uid_player==pl.uid) or (math.abs(all_build_in_scene[i].x-pl.x)<500 and all_build_in_scene[i].uid_player~=pl.uid)  then
return false
end
end
return true
end
function generate_world()
x=0
for i=1,2000, 1 do
table.insert(all_vegetation_in_scene,create_random_vegetation(x))
x=x+math.random(10,200)
end

end
function get_all_cat_defend(pl)
dfnd_cat={}
for i=1,#pl.my_cats,1 do
if(pl.my_cats[i].type=="archer" or pl.my_cats[i].type=="sword") then
table.insert(dfnd_cat,pl.my_cats[i])
end
end
return dfnd_cat
end
function get_all_cat_miner(pl)
minr_cat={}
for i=1,#pl.my_cats,1 do
if(pl.my_cats[i].type=="miner") then
table.insert(minr_cat,pl.my_cats[i])
end
end
return minr_cat
end
function distribute_cats_defend(pl)
all_cats_defend=get_all_cat_defend(pl)
count=#all_cats_defend
left_cats_count_max=math.floor(math.abs((pl.priority[5]*count) / 100))
righ_cats_count_max=count-left_cats_count_max
left_cats_count=0
righ_cats_count=0
for i=1,#all_cats_defend,1 do
if left_cats_count<left_cats_count_max then
all_cats_defend[i].front_is_left=true
left_cats_count=left_cats_count+1
else
all_cats_defend[i].front_is_left=false
end

end
end
function distribute_cats_attack(pl,target)
for i=1,#pl.my_cats,1 do
if(pl.my_cats[i].type=="shield" or pl.my_cats[i].type=="priest") and pl.my_cats[i].target_player==nil then
all_players_in_scene[find_player_by_name(pl.name)].my_cats[i].target_player=target
print("UES")
end
end

end
function distribute_cats(pl)
index_cat=1
all_cats_miner=get_all_cat_miner(pl)
for q=1,#pl.priority,1 do
for i=1,pl.priority[q], 1 do

if(q==1) then
all_cats_miner[index_cat].type_miner=1
elseif(q==2) then
all_cats_miner[index_cat].type_miner=3
elseif(q==3) then
all_cats_miner[index_cat].type_miner=5
elseif(q==4) then
all_cats_miner[index_cat].type_miner=6
else
end
index_cat=index_cat+1
end
end

end
function send_msg_to_all(msg)
server:sendToAll("get_message",msg)
end
function love.load()
	generate_world()
    -- Creating a server on any IP, port 22122
    server = sock.newServer("*", 22123)
		server:on("send_friend_request", function(data)
		player_name=data[1]
		player_name2=data[2]
	pl1=all_players_in_scene[find_player_by_name(player_name)]
	pl2=all_players_in_scene[find_player_by_name(player_name2)]
	all_players_in_scene[find_player_by_name(player_name2)].relationship[pl1.name]={state=0,friend_request=true}
	server:getClientByConnectId(all_players_in_scene[find_player_by_name(player_name2)].connect_id_client):send("get_relationship",all_players_in_scene[find_player_by_name(player_name2)].relationship)
	end)
	server:on("attack_player_request", function(data)
		player_name=data[1]
		player_name2=data[2]
	send_msg_to_all(player_name .. " attack " .. player_name2 .. "!!!")
	

	pl1=all_players_in_scene[find_player_by_name(player_name)]
	pl2=all_players_in_scene[find_player_by_name(player_name2)]
	distribute_cats_attack(pl1,pl2)
all_players_in_scene[find_player_by_name(player_name2)].relationship[pl1.name]={state=0,friend_request=false}
	server:getClientByConnectId(all_players_in_scene[find_player_by_name(player_name2)].connect_id_client):send("get_relationship",all_players_in_scene[find_player_by_name(player_name2)].relationship)
		all_players_in_scene[find_player_by_name(player_name)].relationship[pl2.name]={state=0,friend_request=false}
	server:getClientByConnectId(all_players_in_scene[find_player_by_name(player_name)].connect_id_client):send("get_relationship",all_players_in_scene[find_player_by_name(player_name)].relationship)

	end)
	server:on("update_friend_request", function(data)
	player_name=data[1]
	player_name2=data[2]
	is_accept=data[3]
	if(all_players_in_scene[find_player_by_name(player_name2)].relationship[pl1.name]~=nil and all_players_in_scene[find_player_by_name(player_name2)].relationship[pl1.name].state==1) then
	return
	end
	pl1=all_players_in_scene[find_player_by_name(player_name)]
	pl2=all_players_in_scene[find_player_by_name(player_name2)]
	l_state=1
	if(is_accept==false) then
	l_state=0
	else
	send_msg_to_all(player_name .. " and " .. player_name2 .. " friends now!!!")
	end
	all_players_in_scene[find_player_by_name(player_name2)].relationship[pl1.name]={state=l_state,friend_request=false}
	server:getClientByConnectId(all_players_in_scene[find_player_by_name(player_name2)].connect_id_client):send("get_relationship",all_players_in_scene[find_player_by_name(player_name2)].relationship)
		all_players_in_scene[find_player_by_name(player_name)].relationship[pl2.name]={state=l_state,friend_request=false}
	server:getClientByConnectId(all_players_in_scene[find_player_by_name(player_name)].connect_id_client):send("get_relationship",all_players_in_scene[find_player_by_name(player_name)].relationship)
	end)
	
	server:on("send_msg",function(msg,client)
	send_msg_to_all(all_players_in_scene[find_player_by_id(client:getConnectId())].name .. ":" .. msg)
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
	if (all_players_in_scene[find_player_by_id(client:getConnectId())].x>20000) then
	all_players_in_scene[find_player_by_id(client:getConnectId())].x=20000
	end
	send_player(all_players_in_scene[find_player_by_id(client:getConnectId())])
	--print(all_players_in_scene[find_player_by_id(client:getConnectId())].connect_id_client .." NEW POS " .. all_players_in_scene[find_player_by_id(client:getConnectId())].x .. " " ..all_players_in_scene[find_player_by_id(client:getConnectId())].y)
	end)
    server:on("connect", function (data,client)
   -- Send a message back to the connected client
		print("Client connect")
		new_player=create_player(math.random(0,10000),client:getConnectId(),math.random(1000,19000),500)
		add_player_in_scene(new_player)
		all_cost={}
	for i=1,#all_type_builds,1 do
	all_cost[all_type_builds[i]]=init_update_cost(all_type_builds[i])
	print("NA:" .. all_type_builds[i])
	end
	new_player_send=convert_server_player_to_client_player(new_player)
	new_player_send.uid=new_player.uid
	new_player_send.priority=new_player.priority
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
server:on("send_priority", function(priority,lclient)
if(priority[1]+priority[2]+priority[3]+priority[4]<=count_miner_cats(all_players_in_scene[find_player_by_id(lclient:getConnectId())])) and priority[5]+priority[6]==100 and priority[5]>=0 and priority[6]>=0 then
all_players_in_scene[find_player_by_id(lclient:getConnectId())].priority=priority
distribute_cats_defend(all_players_in_scene[find_player_by_id(lclient:getConnectId())])
if(priority[1]+priority[2]+priority[3]+priority[4]==count_miner_cats(all_players_in_scene[find_player_by_id(lclient:getConnectId())])) then
distribute_cats(all_players_in_scene[find_player_by_id(lclient:getConnectId())])
end
end
lclient:send("get_priority",all_players_in_scene[find_player_by_id(lclient:getConnectId())].priority)
end)
server:on("create_cat", function(data,lclient)
ltype=data[1]
lbuild=data[2]
lplayer=all_players_in_scene[find_player_by_id(lclient:getConnectId())]

add_cat_in_scene(create_cat(lbuild.x+math.random(0,100),lbuild.y+65,lbuild.uid_player,ltype))
if(ltype=="miner") then
all_players_in_scene[find_player_by_id(lclient:getConnectId())].priority[1]=all_players_in_scene[find_player_by_id(lclient:getConnectId())].priority[1]+1
end
table.insert(all_players_in_scene[find_player_by_id(lclient:getConnectId())].my_cats,all_cats_in_scene[#all_cats_in_scene])
distribute_cats_defend(lplayer)
server:sendToAll("update_cat",convert_server_cat_to_client_cat(all_cats_in_scene[#all_cats_in_scene]))
lclient:send("get_count_cats",count_miner_cats(all_players_in_scene[find_player_by_id(lclient:getConnectId())]))
lclient:send("get_priority",all_players_in_scene[find_player_by_id(lclient:getConnectId())].priority)
end)
server:on("create_build", function(ltype,lclient)
print("TYPE:".. ltype)
lplayer=all_players_in_scene[find_player_by_id(lclient:getConnectId())]
if can_place_build_in_position(lplayer) and ((lplayer.has_start_build==false and ltype=="fortress") or (lplayer.has_start_build==true and ltype~="fortress")) and can_buy_build(lclient,ltype)  then
if(lplayer.has_start_build==false) then
all_players_in_scene[find_player_by_id(lclient:getConnectId())].has_start_build=true
end
add_build_in_scene(create_build(lplayer.x,lplayer.y-65,lplayer.uid,ltype))
table.insert(all_players_in_scene[find_player_by_id(lclient:getConnectId())].my_builds,all_build_in_scene[#all_build_in_scene])
server:sendToAll("builds",all_build_in_scene)
end

end)
end
function count_miner_cats(pl)
c=0
for i=1,#pl.my_cats,1 do
if pl.my_cats[i].type=="miner" then
c=c+1
end
end
return c
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
priority=1,
is_mirror=player.is_mirror,
uid=-1,
count_cats=0
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
if math.abs(all_vegetation_in_scene[i].x-x1)<x3  and this_ltype==true  then
x3=math.abs(all_vegetation_in_scene[i].x-x1)
id=i
end
end
return id
end
function find_unnearest_build(start_pos,builds,ltype,is_left)
start_build=find_build(builds,"fortress")
bld=nil
distance=0
if(start_build~=nil) then
for i=1,#builds,1 do

if builds[i].type==ltype then
if(is_left==true) and start_build.x-builds[i].x>distance  then
bld=builds[i]
distance=start_build.x-builds[i].x
elseif (is_left==false) and  builds[i].x-start_build.x>distance  then
bld=builds[i]
distance=builds[i].x-start_build.x
else
end
end
end
else
print("DW")
end
return bld
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
all_vegetation_in_scene[vegetation_id].x=math.random(500,20000)
all_vegetation_in_scene[vegetation_id].hp=500
server:sendToAll("vegetations",all_vegetation_in_scene)
return true
else
return false
end
end
function active_woodcutter_and_miner_ai(cat)
id=-1
if(cat.anim~="stand2" and cat.anim ~="run2")  then
	if cat.type=="miner" then
	type_vg=cat.type_miner
		id=find_nearest_vegetation(cat.x,{type_vg,type_vg+1})
		cat.resource_build=all_vegetation_in_scene[id]
else
		id=find_nearest_vegetation(cat.x,{10})
		cat.resource_build=all_vegetation_in_scene[id]
end 

	if math.abs(cat.x-cat.resource_build.x)>6 then
		cat.anim="run"
		move_cat(cat,cat.resource_build.x)
		server:sendToAll("update_cat",convert_server_cat_to_client_cat(cat))
	else 
		cat.anim="work"
		dmg=0.01
		cat.amount_resources=cat.amount_resources+dmg
		
		if(all_vegetation_in_scene[id].hp>0 and (damage_vegetation(id,dmg)==true)) or (cat.amount_resources>=cat.max_amount_resources) then
			cat.anim="stand2"
			
		end
		server:sendToAll("update_cat",convert_server_cat_to_client_cat(cat))
	end
else if(find_player_by_uid(cat.uid_player)~=nil) then
	pl=find_player_by_uid(cat.uid_player)
	if (pl~=nil) then
		buildd=find_build(pl.my_builds,"fortress")
		if(buildd~=nil) then
			cat.anim="run2"
			if math.abs(cat.x-buildd.x)<6 then
				cat.anim="stand"
				cat.amount_resources=math.floor(cat.amount_resources)
				if(cat.resource_build.type<3) then
					pl.resources[1]=pl.resources[1]+cat.amount_resources
				end
				if(cat.resource_build.type>=3 and cat.resource_build.type<5) then
					pl.resources[2]=pl.resources[2]+cat.amount_resources
				end
				if(cat.resource_build.type>=5 and cat.resource_build.type<7) then
					pl.resources[3]=pl.resources[3]+cat.amount_resources
				end
				if(cat.resource_build.type>=7 and cat.resource_build.type<=8) then
					pl.resources[4]=pl.resources[4]+cat.amount_resources
				end
				if(cat.resource_build.type==10) then
					pl.resources[5]=pl.resources[5]+cat.amount_resources
				end
				cat.resource_build=nil
				cat.amount_resources=0
				server:getClientByConnectId(pl.connect_id_client):send("update_resources",pl.resources)
			else
			move_cat(cat,buildd.x)
			server:sendToAll("update_cat",convert_server_cat_to_client_cat(cat))
			end
		end
	end
else

end
end
end
function active_archer_and_sword_ai(cat)
pl=find_player_by_uid(cat.uid_player)

if(pl~=nil) then
nearest_build=find_unnearest_build(cat.x,pl.my_builds,"wall",cat.front_is_left)

if(nearest_build~=nil) then
distance=0
new_pos=0
min_distance=20
if(cat.front_is_left) then
new_pos=nearest_build.x+120
distance=cat.x-new_pos
else
new_pos=nearest_build.x-20
distance=new_pos-cat.x
end


if distance <=min_distance and distance>0  and cat.anim~="stand" then
cat.is_mirror=cat.front_is_left

cat.anim="stand"

server:sendToAll("update_cat",convert_server_cat_to_client_cat(cat))
elseif distance>min_distance or distance<0  then
print("DIST:" ..cat.x.. " " .. distance .. " " ..new_pos .. " " .. min_distance)
cat.anim="run"
move_cat(cat,new_pos)
server:sendToAll("update_cat",convert_server_cat_to_client_cat(cat))
else
end
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
function active_shield_and_priest_ai(cat)
if(cat.target_player~=nil) then

bld=find_build(cat.target_player.my_builds,"fortress")
if math.abs(cat.x-bld.x)<20 then
	cat.target_player=nil
else
cat.anim="run"
move_cat(cat,bld.x)
server:sendToAll("update_cat",convert_server_cat_to_client_cat(cat))
end
else
pl=find_player_by_uid(cat.uid_player)
if(pl~=nil) then
bld=find_build(pl.my_builds,"fortress")
if math.abs(cat.x-bld.x)<20 and cat.anim~="stand"  then
	cat.anim="stand"
	server:sendToAll("update_cat",convert_server_cat_to_client_cat(cat))
elseif math.abs(cat.x-bld.x)>20 then
cat.anim="run"
move_cat(cat,bld.x)
server:sendToAll("update_cat",convert_server_cat_to_client_cat(cat))
else
end
end
end
end
function active_cat_ai()
for i=1,#all_cats_in_scene,1 do

if all_cats_in_scene[i].type=="miner" or all_cats_in_scene[i].type=="woodcutter" then
active_woodcutter_and_miner_ai(all_cats_in_scene[i])
elseif all_cats_in_scene[i].type=="archer" or all_cats_in_scene[i].type=="sword" then
active_archer_and_sword_ai( all_cats_in_scene[i])
elseif  all_cats_in_scene[i].type=="shield" or all_cats_in_scene[i].type=="priest" then
active_shield_and_priest_ai( all_cats_in_scene[i])
else
end
--server:sendToAll("update_cat",convert_server_cat_to_client_cat(all_cats_in_scene[i]))

end

end
function love.update(dt)
local result, err =pcall(local_update_server)
tick=tick+dt
if(tick>1/20) then
active_cat_ai()
tick=0
end
if err~=nil then
	print("ERR:" .. err)
	
end

end