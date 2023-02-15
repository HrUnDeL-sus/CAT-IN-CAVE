local sock = require "sock"
local camera = require "gamera"
my_player={x=0}
player_animator={}
all_players={}
all_builds={}
all_vegetations={}
all_sprites_build={}
all_sprites_vegetation={}
chat_is_active=false
text_for_chat=""
all_msg_in_chat={}
tick=0
sred_move_player_min=0
sred_move_player_max=0
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
function new_player(lx,ly,lname,lanimator,lis_mirror)
return {
x=lx,
y=ly,
name=lname,
animator=lanimator,
is_mirror=lis_mirror
}

end
function init_vegetation_sprites()
main_sprite_vegetation=love.graphics.newImage("vegetation.png")
main_sprite_vegetation:setFilter("linear", "nearest")
for i=1,13,1 do
all_sprites_vegetation[i]=love.graphics.newQuad(8*(i-1),0,8,8,main_sprite_vegetation)
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
for i=1,5,1 do
all_sprites_build["tower"..i]=love.graphics.newQuad(32*(i-1),32*4,32,32,main_sprite_build)
end
for i=1,5,1 do
all_sprites_build["shop"..i]=love.graphics.newQuad(32*(i-1),32*5,32,32,main_sprite_build)
end
all_sprites_build["negotiation_house1"]=love.graphics.newQuad(0,32*2,32,32,main_sprite_build)
end
function init_cat_animator(cat)
			  add_animation(cat.animator,"stand",2,40)
			   add_animation(cat.animator,"run",2,20)
			   
end
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
	 lplayer=new_player(player.x,player.y,player.name,new_animator(cat_image,16,16),false)

table.insert(all_players,lplayer)

init_cat_animator(all_players[#all_players])
select_current_cat_animation_from_server(all_players[#all_players],player.current_animation)

else

all_players[id]=new_player(player.x,player.y,all_players[id].name,all_players[id].animator,player.is_mirror)

select_current_cat_animation_from_server(all_players[id],player.current_animation)
 if(my_player.name==all_players[id].name) then

	 all_players[id]=my_player

end
end
end
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
client:on("get_message",function(msg)
table.insert(all_msg_in_chat,msg)
if(#all_msg_in_chat>10) then
table.remove(all_msg_in_chat,1)
end

end)
  client:on("builds",function(lbuilds)
	  all_builds=lbuilds
	  end)
	  client:on("vegetations", function(vegetations)
	  all_vegetations=vegetations
	  print("SIZE:" .. #all_vegetations)
	  end)
	 client:on("update_player",function(lplayer)
	 
	 add_player_in_players(lplayer)
	 end)
	 	      client:on("get_player", function (player)
			  if(my_player.animator~=nil) then
			  my_player=new_player(player.x,player.y,player.name,my_player.animator)
				select_current_cat_animation_from_server(my_player,player.current_animation)
			  else
			  print("THAT")
			  my_player=new_player(player.x,player.y,player.name,new_animator(cat_image,16,16))
			  init_cat_animator(my_player)
			  
			  select_current_cat_animation_from_server(my_player,player.current_animation)
			  end
			 
end)

end
function love.load()

	cat_image = love.graphics.newImage("cat.png")
	cat_image:setFilter("linear", "nearest")
	init_build_sprites()
	init_vegetation_sprites()
	platform_image=love.graphics.newImage("platform.png")
	 background_image=love.graphics.newImage("bg.jpg")
     cam = camera.new(0,0,20000,720)
	 cam:setWorld(0,0,20000,720)
	 	
	 client = sock.newClient("88.85.171.249", 22123)

	 init_client_requests()

	  client:connect()

end
function love.quit()

end
function move_cat(is_left)
sred_move_player_min=my_player.x
set_animation(my_player.animator,"run")
	 my_player.is_mirror=is_left

	
	 client:send("get_player_server",new_player_for_server(my_player.x,my_player.y,my_player.name,my_player.animator.name_main_anim,my_player.is_mirror),client)
	 if(is_left==true) then
	 my_player.x=my_player.x-1
	 else 
	  my_player.x=my_player.x+1
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
    print("NAME:" .. my_player.animator.name_main_anim)
   set_animation(my_player.animator,"stand")
   
	client:send("get_player_server",new_player_for_server(my_player.x,my_player.y,my_player.name,my_player.animator.name_main_anim,nil),client)
   else
   end
 
   end
end
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
   if key == "1" then
    client:send("create_build","home1",client)
   end
      if key == "2" then
    client:send("create_build","fortress1",client)
   end
      if key == "3" then
    client:send("create_build","wall1",client)
   end
      if key == "4" then
    client:send("create_build","tower1",client)
   end
      if key == "5" then
    client:send("create_build","shop1",client)
   end
      if key == "6" then
    client:send("create_build","negotiation_house1",client)
   end

   end
end
function draw_builds()
for i=1,#all_builds,1 do

love.graphics.draw(main_sprite_build,all_sprites_build[all_builds[i].type],all_builds[i].x,all_builds[i].y,0,4,4)
end

end
function draw_vegetations()
for i=1,#all_vegetations,1 do
love.graphics.draw(main_sprite_vegetation,all_sprites_vegetation[all_vegetations[i].type],all_vegetations[i].x,all_vegetations[i].y,0,4,4)
end

end
function love.draw()
key_is_press()
cam:setPosition(my_player.x, 0)
			 for i = 0, 1000 do
            love.graphics.draw(background_image, (i* background_image:getWidth())-my_player.x,0,0,1,love.graphics.getHeight() / background_image:getHeight())
    end
  love.graphics.draw(platform_image,0, love.graphics.getHeight()-50,0,love.graphics.getWidth()/platform_image:getWidth(), love.graphics.getHeight()/platform_image:getHeight()/10)
for i=1,#all_msg_in_chat,1 do
 love.graphics.print(all_msg_in_chat[i],0,(i-1)*20)
end

cam:draw(function(l,t,w,h)
draw_builds()
draw_vegetations()
if(all_players~=nil)then
  for i=1,#all_players,1 do
   love.graphics.print("UID:" .. all_players[i].name,all_players[i].x,all_players[i].y-50)
   if(all_players[i].name==my_player.name) then
   if(chat_is_active==true) then
    love.graphics.print("Send:" .. text_for_chat,all_players[i].x,all_players[i].y-100)
	end
	 love.graphics.print("X:" .. all_players[i].x,all_players[i].x,all_players[i].y-150)
	  love.graphics.print("State:" .. client:getState(),all_players[i].x,all_players[i].y-200)
	    love.graphics.print("Packets:" .. client:getTotalSentPackets(),all_players[i].x,all_players[i].y-250)
		love.graphics.print("Ping:" ..client:getRoundTripTime(),all_players[i].x,all_players[i].y-300)
		love.graphics.print("Players count:" ..#all_players,all_players[i].x,all_players[i].y-350)
	end
  if all_players[i].is_mirror==true then
 
   draw_animator(all_players[i].animator,all_players[i].x,all_players[i].y,-4,4)
   else 
   draw_animator(all_players[i].animator,all_players[i].x,all_players[i].y,4,4)
   end
  
  end
 end
end)

end

function love.update(dt)
tick=tick+dt
client:update()

end