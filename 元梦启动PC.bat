cd /d I:\Downloads\PC\
set EXEPATH=./LetsGo/Binaries/Win64/LetsGoClient.exe
if not exist %EXEPATH% set EXEPATH=./LetsGo/Binaries/Win64/LetsGoClient-Win64-Shipping.exe
start /B  %EXEPATH% -featureleveles31 -resx=1920 -resy=1080 -windowed