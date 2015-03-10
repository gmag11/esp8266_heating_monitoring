function initBus (owPin)--iniciar bus 1wire
     ow.setup(owPin)
     ow.reset (owPin)
     print(0)
end

function searchDS (owPin)
     --buscar dispositivos
     local devices = 0
     local addresses = {}
     repeat
          local address = ow.search(owPin)
          addresses[devices+1]=address
          if (address ~= nil) then 
               local crc = ow.crc8(string.sub(address,1,7))
               if (crc == address:byte(8)) then
                    devices=devices+1
               end
          end
     until (address == nil)
     ow.reset(owPin)
         
     return addresses
end

function readTemp (owPin,addresses)
     --leer temperaturas
     local configsDS = {}
     ow.reset(owPin)
     ow.skip(owPin)
     ow.write(owPin, 0x44, 1)
     tmr.delay(200000) 
     for i=1,table.getn(addresses) do
          local present = ow.reset(owPin)
          ow.select(owPin, addresses[i])
          ow.write(owPin, 0xBE, 1)
          local data = nil
          data = ow.read_bytes(owPin,9)
          configsDS[i] = data
          local crc = ow.crc8(string.sub(data,1,8))
          tmr.wdclr()
     end
     
     return configsDS
end

function bxor(a,b)
   local r = 0
   for i = 0, 31 do
      if ( a % 2 + b % 2 == 1 ) then
         r = r + 2^i
      end
      a = a / 2
      b = b / 2
   end
   return r
end

function convertTemp (configsDS,corrDS)
     --Convertir temperaturas
     local temps = {}
     for i=1,table.getn(configsDS) do
          local t = (configsDS[i]:byte(1) + configsDS[i]:byte(2) * 256)
          --print(t)
          if (t > 32768) then
               t = (bxor(t, 0xffff)) + 1
               t = (-1) * t
          end
          t = (t * 625 /10000) / (corrDS[i] or 1)
          print("Temp "..i..": "..t)
          temps[i]=t
     end
     return temps
end
