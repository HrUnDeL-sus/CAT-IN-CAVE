local sock = require "sock"
local camera = require "gamera"
my_player={x=0}
player_animator={}
all_players={}
all_builds={}
all_sprites_build={}

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
function init_build_sprites()
main_sprite_build=love.graphics.newImage("builds.png")
main_sprite_build:setFilter("linear", "nearest")
for i=1,5,1 do
all_sprites_build["home"..i]=love.graphics.newQuad(32*i-1,0,32,32,main_sprite_build)
end
for i=1,5,1 do
all_sprites_build["fortress"..i]=love.graphics.newQuad(32*i-1,32,32,32,main_sprite_build)
end
for i=1,5,1 do
all_sprites_build["wall"..i]=love.graphics.newQuad(32*i-1,32*3,32,32,main_sprite_build)
end
for i=1,5,1 do
all_sprites_build["tower"..i]=love.graphics.newQuad(32*i-1,32*4,32,32,main_sprite_build)
end
for i=1,5,1 do
all_sprites_build["shop"..i]=love.graphics.newQuad(32*i-1,32*5,32,32,main_sprite_build)
end
all_sprites_build["negotiation_house1"]=love.graphics.newQuad(0,32*2,32,32,main_sprite_build)
end
function init_cat_animator(cat)
			  add_animation(cat.animator,"stand",2,500)
			   add_animation(cat.animator,"run",2,20)
set_animation(cat.animator,"stand")

end
function init_client_requests()
  client:on("builds",function(lbuilds)
	  all_builds=lbuilds
	  end)
	 client:on("players",function(lplayers)
	
	 for i=1,#lplayers,1 do
	 if(all_players[i]==nil) then
	 all_players[i]=new_player(lplayers[i].x,lplayers[i].y,lplayers[i].name,new_animator(cat_image,16,16),false)
	 
	 init_cat_animator(all_players[i])
	 else
	 all_players[i]=new_player(lplayers[i].x,lplayers[i].y,lplayers[i].name,all_players[i].animator,lplayers[i].is_mirror)

	 if(lplayers[i].current_animation=="") then
	  set_animation(all_players[i].animator,"stand")
	  else 
	 set_animation(all_players[i].animator,lplayers[i].current_animation)
end

	 end
	 if(all_players[i].name==my_player.name) then
	 my_player=all_players[i]
	 end
	 end
	 end)
	 	      client:on("get_player", function (player)
			  if(my_player.animator~=nil) then
			  my_player=new_player(player.x,player.y,player.name,my_player.animator)
			  else
			  my_player=new_player(player.x,player.y,player.name,new_animator(cat_image,16,16))
			  init_cat_animator(my_player)
			  end
			  my_player=player	
end)

end
function love.load()

	cat_image = love.graphics.newImage("cat.png")
	cat_image:setFilter("linear", "nearest")
	init_build_sprites()
	platform_image=love.graphics.newImage("platform.png")
	 background_image=love.graphics.newImage("bg.jpg")
     cam = camera.new(0,0,2000,2000)
	 cam:setWorld(0,0,2000,2000)
	 	
	 client = sock.newClient("88.85.171.249", 22123)
	 init_client_requests()

	  client:connect()

end
function love.quit()

end

function key_is_press()
if(my_player.animator~=nil) then
  set_animation(my_player.animator,"run")
   if love.keyboard.isDown("d") then
     my_player.x=my_player.x+1
	 my_player.is_mirror=false
	 client:send("get_player_server",new_player_for_server(my_player.x,my_player.y,my_player.name,my_player.animator.name_main_anim,my_player.is_mirror),client)
  elseif love.keyboard.isDown("a") then
     my_player.x=my_player.x-1
	 my_player.is_mirror=true
	 client:send("get_player_server",new_player_for_server(my_player.x,my_player.y,my_player.name,my_player.animator.name_main_anim,my_player.is_mirror),client)
   elseif(my_player.animator.name_main_anim=="run") then
   set_animation(my_player.animator,"stand")
   client:send("get_player_server",new_player_for_server(my_player.x,my_player.y,my_player.name,my_player.animator.name_main_anim,my_player.is_mirror),client)
   else
   end
   end
end
function love.keypressed( key )
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
function draw_builds()
for i=1,#all_builds,1 do

love.graphics.draw(main_sprite_build,all_sprites_build[all_builds[i].type],all_builds[i].x,all_builds[i].y,0,4,4)
end

end
function love.draw()

cam:setPosition(my_player.x, 0)
            love.graphics.draw(background_image,0,0,0,love.graphics.getWidth()/background_image:getWidth(), love.graphics.getHeight()/background_image:getHeight())
  love.graphics.draw(platform_image,0, love.graphics.getHeight()-50,0,love.graphics.getWidth()/platform_image:getWidth(), love.graphics.getHeight()/platform_image:getHeight()/10)

cam:draw(function(l,t,w,h)
draw_builds()
if(all_players~=nil)then
  for i=1,#all_players,1 do
  if all_players[i].is_mirror==true then
 
   draw_animator(all_players[i].animator,all_players[i].x,all_players[i].y,-4,4)
   else 
   draw_animator(all_players[i].animator,all_players[i].x,all_players[i].y,4,4)
   end
   love.graphics.print("Count " .. all_players[i].x,50+100*i,100)
  end
 end
end)

end

function love.update(dt)
   if dt < 1/120 then
      love.timer.sleep(1/120 - dt)
   end
client:update()
key_is_press()
end