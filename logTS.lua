require("temperature")

pin=4 --GPIO2

deviceAddress = {}
configs = {}
temperatures = {}
corr = {1,1.014,1}

initBus(pin)
deviceAddress = searchDS (pin)

function leerTemp ()
     configs = readTemp (pin,deviceAddress)
     temperatures = convertTemp (configs,corr)
     if (temperatures[1]~=85) then -- when DS18B20 has any error it reports 85ºC. It happens sometimes.
          sendTS(temperatures)
     end
     temperatures=nil
     configs=nil     
end

function sendTS (temps)
     -- conection to thingspeak.com
     print("Sending data to thingspeak.com")
     --local P50=1000
     local t1 = temperatures[3] - temperatures[1]
     local t2 = temperatures[3] - temperatures[2]
     local t3 = temperatures[1] - temperatures[2]
     local calOn = if (t1>5) then 1 else 0 end -- Heater is on when Tin > Tout + 5
     --[[local watt -- Enabling this gives outofmemory error
     -- http://www.engineeringtoolbox.com/heat-emission-radiators-d_272.html
     -- http://www.rayco.es/defaultcont.php?idmodelo=1&idtipocontenido=72
     if ((t1 > 0) and (t2 > 0) and (t3 > 0)) then
          watt = 126 * 5 * (t1 / ( logn ( t2 / t3 ,20) ) / 49.32 ) ^ 1.33
     else
          watt = 0
     end
     print ("watt: "..watt)]]--
     print ("diff: "..t1.." "..t2.." "..t3)
     local conn=net.createConnection(net.TCP, 0) 
     conn:on("receive", function(conn, payload) print(payload) end)
     -- api.thingspeak.com 184.106.153.149
     conn:connect(80,'184.106.153.149') 
     conn:send("GET /update?key=YOUR_KEY="..temps[3].. --Inlet temperature
               "&field2="..temps[1].. --Outlet temperature
               "&field3="..temps[2].. --Ambient temperature
               --"&field4="..watt..  --Current wattage (disabled)
               "&field5="..t1.. -- Inlet - Outlet
               "&field6="..t2.. -- Inlet - ambient
               "&field7="..t3.. -- Outlet - Ambient
               "&field8="..calOn..  -- Is heater on?
               " HTTP/1.1\r\n") 
     conn:send("Host: api.thingspeak.com\r\n") 
     conn:send("Accept: */*\r\n") 
     conn:send("User-Agent: Mozilla/4.0 (compatible; esp8266 Lua; Windows NT 5.1)\r\n")
     conn:send("\r\n")
     conn:on("sent",function(conn)
                      print("Closing connection")
                      conn:close()
                  end)
     conn:on("disconnection", function(conn)
                                print("Got disconnection...")
     end)
end

--[[function logn (z,resol) -- Not needed as wattage calculation is not working
     local sum=0
     if (not resol) then resol = 20 end
     for n=0,resol do
          sum = sum + (1/(2*n+1))*((z-1)/(z+1))^(2*n+1)
     end
     return 2*sum
end]]--

tmr.alarm(0,60000,1,function () leerTemp() end) -- measure temp and send it every minute
