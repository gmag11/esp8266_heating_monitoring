FileToExecute="logTS.lua"
wifi.setmode(wifi.STATION)
wifi.sta.config("SSID","password")
wifi.sta.connect()
tmr.alarm(1, 1000, 1, function()
     if wifi.sta.getip() == nil then
          print("Connecting to AP...")
     end
end)
l = file.list()
for k,v in pairs(l) do
  if k == FileToExecute then
    print("*** You've got 5 sec to stop timer 0 ***") -- tmr.stop(0)
    tmr.alarm(0, 5000, 0, function()
      print("Executing ".. FileToExecute)
      dofile(FileToExecute)
    end)
  end
end
