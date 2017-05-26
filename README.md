# Sonoff Wifi Wireless Switch throught a MQTT broker

Command a [sonoff wifi switch](https://www.itead.cc/sonoff-wifi-wireless-switch.html) throught a MQTT broker.

> This LUA script is for ESP8266 hardware.

## Description

<img src="https://github.com/Wifsimster/sonoff-mqtt/blob/master/sonoff_wifi_switch.jpg" alt="Switch" width="200px"/>

You can get this awesome hackable switch on eBay or Banggood for under 5€ !

## Parts

<img src="https://github.com/Wifsimster/sonoff-mqtt/blob/master/sonoff-parts.jpg" alt="Parts"/>

## Pins

Programmer | Sonoff (counting from top to bottom)
-------- | --------
3V3 | 1
TX	| 2 (RX)
RX	| 3 (TX)
GND	| 4
GPIO 14 | 5

## Files

* ``config.lua``: Configuration variables
* ``init.lua``: Connect to a wifi AP and then execute main.lua file
* ``functions.lua``: Handy MQTT functions
* ``main.lua``: Main file

## MQTT messages

### Publish to /online/

Presentation of the device to MQTT broker :
```json
{"mac":"5E:FF:56:A2:AF:15","ip":"192.168.0.1","name":"ESP8266-45643","type":"switch"}
```

### Publish to /ping/

Stay alive message for the MQTT broker :
```json
{"mac":"5E:FF:56:A2:AF:15"}
```

### Subscribe to /sensors/relay/

Turn ON the relay :
```json
{"mac":"5E:FF:56:A2:AF:15","state":"1"}
```

Turn OFF the relay :
```json
{"mac":"5E:FF:56:A2:AF:15","state":"0"}
```
