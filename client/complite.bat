"C:\Program Files\7-Zip\7z.exe" a  game.zip *.lua *.png *.jpg *.ttf *.ogv
copy /b love.exe+game.zip game.exe
game.exe