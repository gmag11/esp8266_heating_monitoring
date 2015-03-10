# esp8266_heating_monitoring
Monitor radiator heater wattage using esp8266 with Nodemcu firmware and 3 x DS18B20 thermometers

Its intention is to measure inlet and outlet water temperature and ambient temp, to apply the formula found in http://www.engineeringtoolbox.com/heat-emission-radiators-d_272.html

Heater data for calculation can be found on http://www.rayco.es/defaultcont.php?idmodelo=1&idtipocontenido=72

I could get all values and precalculations but NodeMCU has not enough memory to do wattage calculation. I have to do it by exporting data to MSExcel.

If you know any way to reduce memory footprint it will be really appreciated.

I will try to make a port of this to Arduino, using ESP8266 as a wifi interface.
