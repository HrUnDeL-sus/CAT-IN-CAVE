"C:\Program Files\7-Zip\7z.exe" a  game.zip *.lua *.png *.jpg *.ttf *.ogg
copy /b love.exe+game.zip game.exe
game.exe