local sock = require "sock"
local camera = require "gamera"
local utf8 = require("utf8")
draw_help_id=false
timer_help_id=10
my_player={x=0}
player_animator={}
cat_miner_animator={}
cat_sword_animator={}
cat_archer_animator={}
cat_woodcutter_animator={}
cat_woodcutter_animator={}
cat_priest_animator={}
cat_shield_animator={}
all_sprites_shells={}
all_cats={}
all_shells={}
all_players={}
all_builds={}cats_main_sprites={}
all_vegetations={}
all_sprites_build={}
all_sprites_icons={}
all_heart_sprites={}
all_fractions_sprites={}


bg_lobby_images={}
all_sprites_vegetation={}all_type_cats={"archer","sword","woodcutter","miner","shield","assassin","priest"}
chat_is_active=false
text_for_chat=""
select_priotiry=1
select_title=1
select_relationship=1
select_relationship_player=-1
all_msg_in_chat={}
tick=10000
index_cat_bg=0
nearest_build=nil
all_cost=nil
has_house=false
main_text=""
is_genocide=false
timer_start_game=60
is_start_game=true
-- client.lua
function new_animator(main_image,x_pixel,y_pixel)
return {
timer=0,
image=main_image,
x=x_pixel,
y=y_pixel,
animations={},
name_main_anim=""
}
end
function set_animation(animation,name)
animation.name_main_anim=name
animation.timer=0
end
function add_animation(animation,name,lcount,ltimer)
animation.animations[name]={
count=0,
max_count=lcount,
timer=0,
max_timer=ltimer,
index=list_length(animation.animations)
}

end
function list_length( t )
 
    local len = 0
    for _,_ in pairs( t ) do
        len = len + 1
    end
 
    return len
end
function draw_animator(animator,x,y,s_x,s_y)
animator.animations[animator.name_main_anim].timer=animator.animations[animator.name_main_anim].timer+1
local main_img=love.graphics.newQuad(animator.animations[animator.name_main_anim].count*animator.x, animator.animations[animator.name_main_anim].index*animator.x, animator.x, animator.y, animator.image)
origin = {x = animator.image:getWidth()*0.05, y = animator.image:getHeight() * 0.5}
love.graphics.draw(animator.image,main_img, x,y,0,s_x,s_y,origin.x,0)
if(animator.animations[animator.name_main_anim].timer>=animator.animations[animator.name_main_anim].max_timer) then
animator.animations[animator.name_main_anim].timer=0
animator.animations[animator.name_main_anim].count=animator.animations[animator.name_main_anim].count+1
if(animator.animations[animator.name_main_anim].count==animator.animations[animator.name_main_anim].max_count) then
animator.animations[animator.name_main_anim].count=0
end
end
end
function new_player_for_server(lx,ly,lname,name_anim,lis_mirror)
return {
x=lx,
y=ly,
name=lname,
current_animation=name_anim,
is_mirror=lis_mirror
}


end
function find_nearest_build()
for i=1,#all_builds,1 do
if(math.abs(my_player.x-(all_builds[i].x+40))<60) and all_builds[i].uid_player==my_player.uid then
return all_builds[i]
end
end
return nil
end
function new_player(lx,ly,lname,lanimator,lis_mirror,hhas_build,lhas_timofei,lindex_fract)
lin_game=true
if(is_start_game==true) then
lin_game=false
end

return {
x=lx,
y=ly,
name=lname,
animator=lanimator,
is_mirror=lis_mirror,
resources={0,0,0,0,10,10},
priority={80,0,0,0},
uid=-1,
count_cats_miner=0,
relationship={},
in_game=lin_game,
has_build=hhas_build,
count_cats=1,
has_timofei=lhas_timofei,
index_fract=lindex_fract
}

end
function init_vegetation_sprites()
main_sprite_vegetation=love.graphics.newImage("vegetation.png")


main_sprite_vegetation:setFilter("linear", "nearest")
for i=1,13,1 do
all_sprites_vegetation[i]=love.graphics.newQuad(8*(i-1),0,8,8,main_sprite_vegetation)
end

end
function init_shells()
main_sprite_shell=love.graphics.newImage("shells.png")
main_sprite_shell:setFilter("linear", "nearest")
for i=1,3,1 do
all_sprites_shells[i]=love.graphics.newQuad(4*(i-1),0,4,4,main_sprite_shell)
end
end
function init_icons()
main_sprite_icon=love.graphics.newImage("icons.png")
main_sprite_icon:setFilter("linear", "nearest")
for i=1,13,1 do
all_sprites_icons[i]=love.graphics.newQuad(4*(i-1),0,4,4,main_sprite_icon)

end
for i=14,24,1 do
all_sprites_icons[i]=love.graphics.newQuad(8*(i-14),8,8,8,main_sprite_icon)
end
end
function init_heart_sprites()

main_heart_sprite=love.graphics.newImage("heart.png")
main_heart_sprite:setFilter("linear", "nearest")
for i=1,10,1 do
all_heart_sprites[i]=love.graphics.newQuad(16*(i-1),0,16,16,main_heart_sprite)
end


end
function init_build_sprites()
main_sprite_build=love.graphics.newImage("builds.png")
main_sprite_build:setFilter("linear", "nearest")
for i=1,5,1 do
all_sprites_build["home"..i]=love.graphics.newQuad(32*(i-1),0,32,32,main_sprite_build)
end
for i=1,5,1 do
all_sprites_build["fortress"..i]=love.graphics.newQuad(32*(i-1),32,32,32,main_sprite_build)
end
for i=1,5,1 do
all_sprites_build["wall"..i]=love.graphics.newQuad(32*(i-1),32*3,32,32,main_sprite_build)
end
all_sprites_build["negotiation_house1"]=love.graphics.newQuad(0,32*2,32,32,main_sprite_build)
end
function init_cat_animator(cat,ltype)
			  add_animation(cat.animator,"stand",2,40)
			   add_animation(cat.animator,"run",2,20)
if (ltype=="archer") then
add_animation(cat.animator,"attack",2,30)
elseif(ltype=="sword") then
add_animation(cat.animator,"attack",3,30)
elseif(ltype=="priest") then
add_animation(cat.animator,"attack",1,30)
elseif(ltype=="woodcutter" or ltype=="miner") then
add_animation(cat.animator,"work",3,30)
	  add_animation(cat.animator,"stand2",2,40)
			   add_animation(cat.animator,"run2",2,20)
else
endend
function select_current_cat_animation_from_server(cat,anim)

 if(anim=="") then
	  set_animation(cat.animator,"stand")
	  else 
	 set_animation(cat.animator,anim)
end

end

function add_player_in_players(player)

lplayer=nil
id=find_id_player_in_players(player)

if(id==-1) then
	 lplayer=new_player(player.x,player.y,player.name,new_animator(cat_image,16,16),false,player.has_build,player.has_timofei,player.fraction_id)


table.insert(all_players,lplayer)

init_cat_animator(all_players[#all_players],"cat")
select_current_cat_animation_from_server(all_players[#all_players],player.current_animation)

else

all_players[id]=new_player(player.x,player.y,all_players[id].name,all_players[id].animator,player.is_mirror,player.has_build,player.has_timofei,player.fraction_id)

select_current_cat_animation_from_server(all_players[id],player.current_animation)

 if(my_player.name==all_players[id].name) then
 my_player.has_build=all_players[id].has_build
  my_player.index_fract=all_players[id].index_fract
 my_player.has_timofei=all_players[id].has_timofei
	 all_players[id]=my_player

end
end
end
function new_cat(cat,anim)

return {
x=cat.x,
y=cat.y,
type=cat.type,
animator=anim,
uid_player=cat.uid_player,
uid=cat.uid,
lvl=cat.lvl,
is_mirror=cat.is_mirror,
hp=cat.hp
}

endfunction add_cat_to_all_cats(cat)id=find_id_cat_in_cats(cat)if(id==-1) thentable.insert(all_cats,new_cat(cat,new_animator(cats_main_sprites[cat.type],16,16)))
set_animation(all_cats[#all_cats].animator,"stand")init_cat_animator(all_cats[#all_cats],all_cats[#all_cats].type)else
if(cat.hp<=0) then

table.remove(all_cats,id)
elseset_animation(all_cats[id].animator,cat.anim)all_cats[id]=new_cat(cat,all_cats[id].animator)
endendendfunction find_id_cat_in_cats(cat)if(all_cats==nil) thenreturn -1endfor i=1, #all_cats,1 do
if(all_cats[i].uid==cat.uid) thenreturn iendendreturn -1end
function find_id_player_in_players(player)
if(all_players==nil) then
return -1
end

for i=1, #all_players,1 do
if(all_players[i].name==player.name) then
return i
end

end
return -1
end
function init_client_requests()
client:on("pizdec",function()
music_audio2:play()
music_audio:stop()
end)
client:on("help_id",function()
draw_help_id=true
timer_help_id=10
end)
client:on("create_audio",function(ltype)

--audio=love.audio.newSource(ltype..".wav", "static")

--audio:play()

end)
client:on("create_audio_position",function(data)

x=data[1]
ltype=data[2]
--audio=love.audio.newSource(ltype..".wav", "static")
--print("POSITION:" ..  -(my_player.x-x))
--audio:setPosition(-(my_player.x-x), 0, 0 )
--audio:play()

end)
		client:on("update_timer", function(value)
	timer_start_game=value
	end)
client:on("get_priority",function(prior)
my_player.priority=prior
end)
client:on("get_relationship", function(lrelationship)

my_player.relationship=lrelationship
end)
client:on("get_count_cats",function(count)
my_player.count_cats=count

end)
client:on("get_count_cats_miner",function(count)
my_player.count_cats_miner=count

end)
client:on("get_message",function(msg)
table.insert(all_msg_in_chat,msg)
if(#all_msg_in_chat>10) then
table.remove(all_msg_in_chat,1)
end

end)


client:on("update_state_game",function(state)
is_start_game=state

end)
client:on("send_cost_build",function(l_cost)
all_cost=l_cost
end)

client:on("update_resources",function(res)

my_player.resources=res
end)client:on("update_cat",function(cat)
add_cat_to_all_cats(cat)end)
client:on("shells", function(lshells)
all_shells=lshells
end)
  client:on("builds",function(lbuilds)
	  all_builds=lbuilds
	  end)
	  client:on("vegetations", function(vegetations)
	  all_vegetations=vegetations

	  end)
	 client:on("update_player",function(lplayer)
	 
	 add_player_in_players(lplayer)
	 
	 end)
	 client:on("restart_game",function(d)
	 	
	 all_cats={}
	all_players={}
	all_builds={}
	all_msg_in_chat={}
is_start_game=false
	client:reset()
	 end)
	 client:on("kill_player",function(lplayer)
	 id=find_id_player_in_players(lplayer)
	 table.insert(all_msg_in_chat,lplayer.name .. " die!!!")
if(#all_msg_in_chat>10) then
table.remove(all_msg_in_chat,1)
end
	 table.remove(all_players,id)
	 end)
	 client:on("dissconect",function()
	
	 end)
	 	      client:on("get_player", function (player)
			  if(my_player.animator~=nil) then
			  my_player=new_player(player.x,player.y,player.name,my_player.animator)
				select_current_cat_animation_from_server(my_player,player.current_animation)
			  else
			  my_player=new_player(player.x,player.y,player.name,new_animator(cat_image,16,16))
			 
			  init_cat_animator(my_player,"cat")
			  
			  select_current_cat_animation_from_server(my_player,player.current_animation)
			  end
			my_player.uid=player.uid
			 my_player.priority=player.priority

end)

endfunction init_cats()for i=1,#all_type_cats,1 docats_main_sprites[all_type_cats[i]]=love.graphics.newImage(all_type_cats[i] .."_cat.png")
cats_main_sprites[all_type_cats[i]]:setFilter("linear", "nearest")endend
function init_fractions()
fraction_main=love.graphics.newImage("factions.png")
	fraction_main:setFilter("linear", "nearest")
q=0;
for x=1,16,1 do
for y=1,3,1 do
all_fractions_sprites[q]=love.graphics.newQuad(32*(x-1),32*(y-1),32,32,fraction_main)
q=q+1
end

end
q=q+1
all_fractions_sprites[q]=love.graphics.newQuad(0,32*2,32,32,fraction_main)
q=q+1
all_fractions_sprites[q]=love.graphics.newQuad(32,32*2,32,32,fraction_main)

end
function load_audio()
love.audio.setPosition(0, 1, 0)
music_audio=love.audio.newSource("music.mp3","stream")
music_audio2=love.audio.newSource("music2.mp3","stream")
music_audio2:stop()
music_audio:setLooping(true)
music_audio:stop()
end
function love.load()
math.randomseed(os.clock())	
load_audio()
	font = love.graphics.newFont("Pixtile.ttf", 15)
	love.graphics.setFont(font)
	
	
	cat_image = love.graphics.newImage("cat.png")
	timofei_sprite=love.graphics.newImage("cat_palka.png")
	timofei_sprite:setFilter("linear", "nearest")
	cat_image:setFilter("linear", "nearest")
	init_heart_sprites()
	init_build_sprites()
	load_backgrounds()
	init_icons()
	init_shells()
	init_cats()
	init_fractions()
	init_vegetation_sprites()
	platform_image=love.graphics.newImage("platform.png")
	 background_image=love.graphics.newImage("bg.jpg")
	 error_background=love.graphics.newImage("error.jpg")
     cam = camera.new(0,0,50000,720)
	 cam:setWorld(0,0,50000,720)
	 	
connect_client()

end
function love.quit()

end
function move_cat(is_left)
set_animation(my_player.animator,"run")
	 my_player.is_mirror=is_left

	
	 client:send("get_player_server",new_player_for_server(my_player.x,my_player.y,my_player.name,my_player.animator.name_main_anim,my_player.is_mirror),client)
	 if(is_left==true and my_player.x-1>500) then
	 my_player.x=my_player.x-1
	 elseif(is_left==false and my_player.x+1<20000) then
	  my_player.x=my_player.x+1
	  else
	 end
end

function key_is_press()

if chat_is_active==false then
if(my_player.animator~=nil) then
  if love.keyboard.isDown("d") then
    move_cat(false)
  elseif love.keyboard.isDown("a") then
    move_cat(true)
   elseif(my_player.animator.name_main_anim=="run") then
   
   set_animation(my_player.animator,"stand")
   
	client:send("get_player_server",new_player_for_server(my_player.x,my_player.y,my_player.name,my_player.animator.name_main_anim,nil),client)
   else
   end
 
   end
end
end
function convert_key_to_rus(key)
switch()

end
function love.keypressed( key )
 if key=="tab" then
   if chat_is_active==true then
   chat_is_active=false
   else
   chat_is_active=true
   end
end
if chat_is_active==true then
if key=="space" then
text_for_chat=text_for_chat .. " "
elseif key=="return" then
client:send("send_msg",text_for_chat)
text_for_chat=""
elseif key=="backspace" then
text_for_chat=string.sub(text_for_chat,1,string.len(text_for_chat)-1)
elseif string.len(key)<2 then
text_for_chat=text_for_chat .. key
end
else 
if(nearest_build~=nil and key=="u" and nearest_build.type~="negotiation_house" and nearest_build.type~="home") then
client:send("upgrade_build",nearest_build,client)
end
	if (key=="r" or key=="t") and nearest_build~=nil and nearest_build.type=="negotiation_house" then
		if my_player.relationship[select_relationship_player] ~=nil and (my_player.relationship[select_relationship_player].friend_request==true) then
		if(key=="r") then
		client:send("update_friend_request",{my_player.name,select_relationship_player,false})
		else
		client:send("update_friend_request",{my_player.name,select_relationship_player,true})
		end
		else
				if(key=="r") then
		if(my_player.relationship[select_relationship_player] ==nil or my_player.relationship[select_relationship_player].state~=1) then
		
			client:send("send_friend_request",{my_player.name,select_relationship_player})
		else
		client:send("send_present",select_relationship_player,client)
		end
	
		else
		client:send("attack_player_request",{my_player.name,select_relationship_player})
		end
		end
	end
    if key == "1" then
   if(nearest_build~=nil and nearest_build.type=="home") then
   client:send("create_cat",{"archer",nearest_build},client)
   elseif(nearest_build~=nil and nearest_build.type=="fortress") then
   select_priotiry=1
   elseif(nearest_build~=nil and nearest_build.type=="negotiation_house") and (#all_players>0) then
   select_relationship=1
   else
    client:send("create_build","home",client)
	end
   end

    if(nearest_build~=nil and nearest_build.type=="fortress" and key=="q") then
	if(my_player.priority[select_priotiry]-1>=0)then
	if(select_priotiry<5) then
	my_player.priority[select_priotiry]=my_player.priority[select_priotiry]-1
	else
		my_player.priority[select_priotiry]=my_player.priority[select_priotiry]-10
	if(select_priotiry==5) then
	my_player.priority[6]=my_player.priority[6]+10
	else
	my_player.priority[5]=my_player.priority[5]+10
	end
	
	end

	client:send("send_priority",my_player.priority,client)
	end
	end
	if(nearest_build~=nil and nearest_build.type=="negotiation_house" and key=="q") and (select_title>1) then
   select_title=select_title-1
   end
   if(nearest_build~=nil and nearest_build.type=="negotiation_house" and key=="e") and (((select_title+1)*4)-#all_players>0) then
   select_title=select_title+1
   end
	    if(nearest_build~=nil and nearest_build.type=="fortress" and key=="e") then
	if(select_priotiry<5) then
	my_player.priority[select_priotiry]=my_player.priority[select_priotiry]+1
	else
	my_player.priority[select_priotiry]=my_player.priority[select_priotiry]+10
	if(select_priotiry==5) then
	
	my_player.priority[6]=my_player.priority[6]-10
	else
	my_player.priority[5]=my_player.priority[5]-10
	end
	
	end
	client:send("send_priority",my_player.priority,client)
	end
    if key == "2" then
	     if(nearest_build~=nil and nearest_build.type=="home") then
	 client:send("create_cat",{"sword",nearest_build},client)
	 elseif(nearest_build~=nil and nearest_build.type=="fortress") then
   select_priotiry=2
   elseif(nearest_build~=nil and nearest_build.type=="negotiation_house") and (#all_players>1) then
   select_relationship=2
   else
   has_house=true
    client:send("create_build","fortress",client)
	end
	end
    if key == "3" then
	     if(nearest_build~=nil and nearest_build.type=="home") then
    client:send("create_cat",{"shield",nearest_build},client)
	elseif(nearest_build~=nil and nearest_build.type=="fortress") then
   select_priotiry=3
    elseif(nearest_build~=nil and nearest_build.type=="negotiation_house") and (#all_players>2) then
   select_relationship=3
   else
    client:send("create_build","wall",client)
		end
   end
    if key == "4" then
	     if(nearest_build~=nil and nearest_build.type=="home") then
      client:send("create_cat",{"priest",nearest_build},client)
   elseif(nearest_build~=nil and nearest_build.type=="fortress") then
   select_priotiry=4
   elseif(nearest_build~=nil and nearest_build.type=="negotiation_house") and (#all_players>3) then
   select_relationship=4
   else
    client:send("create_build","negotiation_house",client)
		end
   end
    if key == "5" then
	     if(nearest_build~=nil and nearest_build.type=="home") then
    client:send("create_cat",{"miner",nearest_build},client)
	 elseif(nearest_build~=nil and nearest_build.type=="fortress") then
   select_priotiry=5
   else
		end
   end
	if key=="6" and nearest_build~=nil and nearest_build.type=="home" then
	  client:send("create_cat",{"woodcutter",nearest_build},client)	end
	if  key=="6" and (nearest_build~=nil and nearest_build.type=="fortress") then
   select_priotiry=6
   end
   end
end
function draw_upgrade_icons(x,y,name,lvl) 
start_y=y
x=x
if(lvl==6) then
return
end
for s=1,#all_cost[name][lvl],1 do
if(all_cost[name][lvl][s]~=0) then
love.graphics.draw(main_sprite_icon,all_sprites_icons[s],x,y,0,4,4)

love.graphics.print(""..all_cost[name][lvl][s],x+20,y)
x=x+40
end
end
love.graphics.print("U",x,y)
end
function draw_hearts(lx,ly,lhp)
if(lhp<=0) then
return
end

end_index=math.ceil(lhp/100)
for index=1,end_index,1 do

if(index~=end_index) then
love.graphics.draw(main_heart_sprite,all_heart_sprites[1],lx+((index-1)*20),ly+20)
elseif(index==end_index and index==1) then
if(11-math.floor((lhp)/10)==0) then
love.graphics.draw(main_heart_sprite,all_heart_sprites[1],lx+((index-1)*20),ly+20)
elseif(11-math.floor((lhp)/10)==11) then
love.graphics.draw(main_heart_sprite,all_heart_sprites[10],lx+((index-1)*20),ly+20)
else
love.graphics.draw(main_heart_sprite,all_heart_sprites[11-math.floor((lhp)/10)],lx+((index-1)*20),ly+20)
end
else
if(11-(math.floor((lhp-((end_index-1)*100))/10))==0) then
love.graphics.draw(main_heart_sprite,all_heart_sprites[1],lx+((index-1)*20),ly+20)
elseif(11-(math.floor((lhp-((end_index-1)*100))/10))==11) then
love.graphics.draw(main_heart_sprite,all_heart_sprites[10],lx+((index-1)*20),ly+20)
else
love.graphics.draw(main_heart_sprite,all_heart_sprites[11-(math.floor((lhp-((end_index-1)*100))/10))],lx+((index-1)*20),ly+20)
end
end
end

end
function draw_builds()
for i=1,#all_builds,1 do
love.graphics.draw(main_sprite_build,all_sprites_build[all_builds[i].type..all_builds[i].lvl],all_builds[i].x,all_builds[i].y,0,4,4)

draw_hearts(all_builds[i].x,all_builds[i].y,all_builds[i].hp)

end

end
function draw_vegetations()
for i=1,#all_vegetations,1 do
love.graphics.draw(main_sprite_vegetation,all_sprites_vegetation[all_vegetations[i].type],all_vegetations[i].x,all_vegetations[i].y,0,4,4)
end

end
function draw_chat()
for i=1,#all_msg_in_chat,1 do
 love.graphics.print(all_msg_in_chat[i],0,(i-1)*20)
end

end

function draw_negotiation_house_icons()
start_y=nearest_build.y-50
start_x=nearest_build.x-35
start_i=((select_title-1)*4)+1
index=start_i
for i=start_i,(select_title*4),1 do

if(all_players[i]~=nil) and all_players[i].has_build then
if(select_relationship+(((select_title-1)*4))==index) then
if(all_players[i].name==my_player.name) then
love.graphics.print({{1,0,0,1},"YOU"},start_x,start_y)
else
love.graphics.print({{1,0,0,1},""..all_players[i].name},start_x,start_y)
select_relationship_player=all_players[i].name
end
else
if(all_players[i].name==my_player.name) then
love.graphics.print("YOU",start_x,start_y)
else
love.graphics.print(""..all_players[i].name,start_x,start_y)
end

end
if(all_players[i].name~=my_player.name) then
if(my_player.relationship[all_players[i].name]==nil or my_player.relationship[all_players[i].name].friend_request==false) then
--if(my_player.relationship[all_players[i].name]~=nil and my_player.relationship[all_players[i].name].state==0) or (my_player.relationship[all_players[i].name]==nil) then
start_x=start_x+40
if(my_player.relationship[all_players[i].name]==nil or my_player.relationship[all_players[i].name].state~=1) then
love.graphics.draw(main_sprite_icon,all_sprites_icons[17],start_x,start_y,0,3,3)
else
love.graphics.draw(main_sprite_icon,all_sprites_icons[23],start_x,start_y,0,3,3)
end
--end
start_x=start_x+40
love.graphics.draw(main_sprite_icon,all_sprites_icons[18],start_x,start_y,0,3,3)
start_x=start_x+40
if(my_player.relationship[all_players[i].name]~=nil) then
love.graphics.draw(main_sprite_icon,all_sprites_icons[16-my_player.relationship[all_players[i].name].state],start_x,start_y,0,3,3)
else
love.graphics.draw(main_sprite_icon,all_sprites_icons[16],start_x,start_y,0,3,3)
end
start_x=nearest_build.x-35
else
start_x=start_x+40
love.graphics.draw(main_sprite_icon,all_sprites_icons[20],start_x,start_y,0,3,3)
start_x=start_x+40
love.graphics.draw(main_sprite_icon,all_sprites_icons[19],start_x,start_y,0,3,3)
end
end
start_y=start_y-30
index=index+1

end
end
end
function connect_client()
 --client = sock.newClient("88.85.171.249", 22122)
client = sock.newClient("192.168.0.12", 22122)

  init_client_requests()

 client:connect()
end
function draw_fortress_icons()
start_y=nearest_build.y-50
for i=1,6,1 do
if(i<5) then
love.graphics.draw(main_sprite_icon,all_sprites_icons[i],nearest_build.x,start_y,0,4,4)
else
love.graphics.draw(main_sprite_icon,all_sprites_icons[i+16],nearest_build.x,start_y,0,2,2)
end
love.graphics.print("" .. my_player.priority[i],nearest_build.x+20,start_y)
if(select_priotiry==i) then
love.graphics.print("Q",nearest_build.x-20,start_y)
love.graphics.print("E",nearest_build.x+80,start_y)
end
start_y=start_y-20

end
love.graphics.print("Count cats:" .. (my_player.priority[1]+my_player.priority[2]+my_player.priority[3]+my_player.priority[4]),nearest_build.x,start_y)
if(my_player.priority[1]+my_player.priority[2]+my_player.priority[3]+my_player.priority[4]~=my_player.count_cats_miner) then
love.graphics.print({{1,0,0,1},"All cats:" .. my_player.count_cats_miner},nearest_build.x,start_y-20)
else
love.graphics.print("All cats:" .. my_player.count_cats_miner,nearest_build.x,start_y-20)
end


end
function draw_home_icons()
start_x=nearest_build.x-35
love.graphics.print("COST:" .. (5+math.floor(0.2*my_player.count_cats)),start_x,nearest_build.y-100)
for i=7,12,1 do
love.graphics.draw(main_sprite_icon,all_sprites_icons[i],start_x,nearest_build.y-50,0,8,8)
start_x=start_x+35

end

end
function draw_icons()
if(my_player.resources~=nil) then
for i=1,6,1 do
love.graphics.draw(main_sprite_icon,all_sprites_icons[i],450,60+(i*20),0,4,4)
love.graphics.print(""..my_player.resources[i],470,60+(i*20))
end
end
end
function draw_shop_builds()
if(all_cost~=nil) then
x=1

names={"home","fortress","wall","negotiation_house"}

for i=1,#names,1 do
if(my_player.has_build==true) or (my_player.has_build==false and names[i]=="fortress") then
love.graphics.draw(main_sprite_build,all_sprites_build[names[i].."1"],90+(x*50),0,0,2,2)
q=0
for s=1,#all_cost[names[i]][1],1 do
if(all_cost[names[i]][1][s]~=0) then
love.graphics.draw(main_sprite_icon,all_sprites_icons[s],100+(x*50),70+(q*20),0,4,4)

love.graphics.print(""..all_cost[names[i]][1][s],120+(x*50),70+(q*20))

q=q+1
end
end
x=x+1
end
end
end
end

function draw_gui()
love.graphics.print(main_text,300,300)
draw_chat()
if(my_player.in_game==true) then
draw_icons()
if(nearest_build==nil) then
draw_shop_builds()
end
end
if(chat_is_active==true) then
    love.graphics.print("Send:" .. text_for_chat,300,450)
	end
	 love.graphics.print("X:" .. my_player.x,300,430)
	  love.graphics.print("State:" .. client:getState(),450,0)
	    love.graphics.print("Packets:" .. client:getTotalSentPackets() .. " " ..client:getTotalReceivedPackets(),450,20)
		love.graphics.print("Ping:" ..client:getRoundTripTime(),450,40)
		love.graphics.print("Players count:" ..#all_players,450,60)
end

function draw_shells()

for i=1,#all_shells,1 do

love.graphics.draw(main_sprite_shell,all_sprites_shells[all_shells[i].type], all_shells[i].x,all_shells[i].y,0,4,4)
end
endfunction draw_cats()for i=1,#all_cats,1 do

if(all_cats[i].is_mirror==true) thendraw_animator(all_cats[i].animator,all_cats[i].x,all_cats[i].y,-4,4)

else
draw_animator(all_cats[i].animator,all_cats[i].x,all_cats[i].y,4,4)
end
draw_hearts(all_cats[i].x-20,all_cats[i].y-40,all_cats[i].hp)endend
function reconect_client()
client:connect()
end
function draw_connecting()

 love.graphics.draw(error_background, 0,0,0,1,1)
love.graphics.print("Trying to connect to the server",200,0)

end
function draw_lobby()

love.graphics.draw(bg_lobby_image, 0,0,0,1,1)
love.graphics.print("Game hasn't started yet" ,200,0)
love.graphics.print("Count cats in lobby:" .. #all_players,200,30)
love.graphics.print("Game will start in " .. timer_start_game,200,60)
love.graphics.print("Index:" .. index_cat_bg,200,90)
end
function draw_fraction(x,y,id)
if(id~=-1) then

love.graphics.draw(fraction_main,all_fractions_sprites[id], x,y-40,0,1,1)
end
end
function love.draw()
if(music_audio:isPlaying()==false and not music_audio2:isPlaying()) then
music_audio:play()
end
if(client:isConnecting() or client:isDisconnected()) then
draw_connecting()
if(client:isDisconnected()) then
reconect_client()
end

return 0
end

if(is_start_game==false) then
draw_lobby()
return 0
end

key_is_press()

cam:setPosition(my_player.x, 0)
			 for i = 0, 1000 do
            love.graphics.draw(background_image, (i* background_image:getWidth())-my_player.x,0,0,1,love.graphics.getHeight() / background_image:getHeight())
    end
  love.graphics.draw(platform_image,0, love.graphics.getHeight()-50,0,love.graphics.getWidth()/platform_image:getWidth(), love.graphics.getHeight()/platform_image:getHeight()/10)


cam:draw(function(l,t,w,h)

draw_vegetations()
draw_builds()
if(nearest_build~=nil and nearest_build.type~="negotiation_house" and nearest_build.type~="home") then
draw_upgrade_icons(nearest_build.x,nearest_build.y,nearest_build.type,nearest_build.lvl+1)
end
if(nearest_build~=nil and nearest_build.type=="home") then
draw_home_icons()
elseif(nearest_build~=nil and nearest_build.type=="shop") then
draw_shop_icons()
elseif(nearest_build~=nil and nearest_build.type=="fortress") then
draw_fortress_icons()
elseif(nearest_build~=nil and nearest_build.type=="negotiation_house") then
draw_negotiation_house_icons()
end

if(all_players~=nil)then
  for i=1,#all_players,1 do
  	love.graphics.print("Name:" .. all_players[i].name,all_players[i].x,all_players[i].y-100)
	 draw_fraction(all_players[i].x,all_players[i].y,all_players[i].index_fract)
  if all_players[i].is_mirror==true then
  if(all_players[i].has_timofei) then
love.graphics.draw(timofei_sprite,all_players[i].x+25,all_players[i].y-80,0,-0.1,0.1)
end
   draw_animator(all_players[i].animator,all_players[i].x,all_players[i].y,-4,4)
  
   else 
    if(all_players[i].has_timofei) then
   	love.graphics.draw(timofei_sprite,all_players[i].x-25,all_players[i].y-80,0,0.1,0.1)
	end
   draw_animator(all_players[i].animator,all_players[i].x,all_players[i].y,4,4)
   end

   end
   end
   draw_shells()   draw_cats()
   
end)

draw_gui()
if(draw_help_id==true) then
font = love.graphics.newFont("Pixtile.ttf", 64)
	love.graphics.setFont(font)
love.graphics.print("HELP_ID",200,200)
font = love.graphics.newFont("Pixtile.ttf", 15)
	love.graphics.setFont(font)
end
end
timer_genocide=250
tick_genocide=0
function love.update(dt)
tick_genocide=tick_genocide+dt
tick=tick+dt
if(draw_help_id==true) then
timer_help_id=timer_help_id-dt
if(timer_help_id<0) then
draw_help_id=false
end
end
client:update()
if(tick_genocide>1 and is_genocide) then
tick_genocide=0
timer_genocide=timer_genocide-1
main_text="Total fucked up in " .. timer_genocide .. " seconds."
end
if(tick>=10 and is_start_game==false) then
tick=0
index_cat_bg=index_cat_bg+1
if(index_cat_bg==101) then
index_cat_bg=1
end
bg_lobby_image=love.graphics.newImage("cat"..index_cat_bg..".jpg")

end
nearest_build=find_nearest_build()
end
function load_backgrounds()
end