# Sonoff Wifi Wireless Switch throught a MQTT broker

Command a [sonoff wifi switch](https://www.itead.cc/sonoff-wifi-wireless-switch.html) throught a MQTT broker.

> This LUA script is for ESP8266 hardware.

## Description

You can get this awesome hackable switch on eBay or Banggood for under 5€ !

<img src="https://github.com/Wifsimster/sonoff-mqtt/blob/master/sonoff_wifi_switch.jpg" alt="Switch" width="150px"/>
<img src="https://github.com/Wifsimster/sonoff-mqtt/blob/master/sonoff-parts.jpg" alt="Parts" width="150px"/>

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
* ``main.lua``: Main file

## Principle

// TODO
