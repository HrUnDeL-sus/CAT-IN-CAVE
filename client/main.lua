local sock = require "sock"
local camera = require "gamera"
my_player={x=0}
player_animator={}
all_players={}
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
function init_cat_animator(cat)
			  add_animation(cat.animator,"stand",2,500)
			   add_animation(cat.animator,"run",2,20)
set_animation(cat.animator,"stand")

end
function love.load()

	cat_image = love.graphics.newImage("cat.png")
	cat_image:setFilter("linear", "nearest")
	
	platform_image=love.graphics.newImage("platform.png")
	 background_image=love.graphics.newImage("bg.jpg")
     cam = camera.new(0,0,2000,2000)
	 cam:setWorld(0,0,2000,2000)
	 client = sock.newClient("localhost", 22123)
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
  elseif love.keyboard.isDown("a") then
     my_player.x=my_player.x-1
	 my_player.is_mirror=true
   else
   set_animation(my_player.animator,"stand")
   end
    client:send("get_player_server",new_player_for_server(my_player.x,my_player.y,my_player.name,my_player.animator.name_main_anim,my_player.is_mirror),client)
	end
end
function love.draw()

cam:setPosition(my_player.x, 0)


 love.graphics.draw(background_image,0,0)
  love.graphics.draw(platform_image,-100 ,500,0,1.5,1.5)

cam:draw(function(l,t,w,h)
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
client:update()
key_is_press()
end