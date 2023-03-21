"C:\Program Files\7-Zip\7z.exe" a  game.zip *.lua  *.ttf *.ogg  *.wav *.png
copy /b love.exe+game.zip game.exe
game.exe
