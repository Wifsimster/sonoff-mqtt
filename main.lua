require('config')
require('functions')

gpio.mode(RELAY, gpio.OUTPUT)
gpio.write(RELAY, gpio.LOW)
gpio.mode(BTN, gpio.INPUT, gpio.PULLUP)
gpio.mode(LED, gpio.OUTPUT)
gpio.write(LED, gpio.HIGH)

mac = wifi.sta.getmac()
ip = wifi.sta.getip()
m = mqtt.Client(CLIENT_ID, 120, "", "")

m:lwt("/lwt", '{"mac":"'..mac..'"}', 0, 0)

-- Try to reconnect to broker when communication is down
m:on("offline", function(con)
    ip = wifi.sta.getip()
    print ("MQTT reconnecting to "..BROKER_IP.." from "..ip)
    tmr.alarm(1, 10000, 0, function()
        node.restart()
    end)
end)

-- Toggle switch when button change state
debounced = 0
gpio.trig(BTN, "down", function (level)
    if (debounced == 0) then
        debounced = 1
        tmr.alarm(6, debounced, 0, function() debounced = 0; end)      
        if (gpio.read(RELAY) == 1) then
            gpio.write(RELAY, gpio.LOW)
            print("Relay was on, turning it off")
        else
            gpio.write(RELAY, gpio.HIGH)
            print("Relay was off, turning it on")
        end
        mqtt_activity()
        mqtt_state()
    end
end)

-- Toggle relay when message received from MQTT broker
m:on("message", function(conn, topic, data)
    mqtt_activity()
    print("Message received: " .. topic .. " : " .. data)
    parse = cjson.decode(data)
    mac = parse.mac
    action = parse.action
    if(mac == wifi.sta.getmac()) then
        if (action == "ON") then
            print("Relay enable")
            gpio.write(RELAY, gpio.HIGH)
            mqtt_state()
        elseif (action == "OFF") then
            print("Relay disable")
            gpio.write(RELAY, gpio.LOW)
            mqtt_state()
        elseif (action == "STATE") then
            mqtt_state()
        elseif (action == "PING") then
            mqtt_ping()
        elseif (action == "ONLINE") then
            mqtt_online()
        elseif (action == "IP") then
            mqtt_ip()
        elseif (action == "NAME") then
            mqtt_name()
        elseif (action == "TYPE") then
            mqtt_type()
        elseif (action == "RESET") then
            print("Restart node")
            node.restart()
        else
            print("Invalid action (" .. action .. ")")
        end
    end
end)

print("Connecting to "..BROKER_IP..":"..BROKER_PORT.."...")
m:connect(BROKER_IP, BROKER_PORT, 0, 1, function(conn)
    print("Connected to "..BROKER_IP..":"..BROKER_PORT.." as "..CLIENT_ID)
    gpio.write(LED, gpio.HIGH)
    mqtt_online()
    mqtt_subscribe()
end)
