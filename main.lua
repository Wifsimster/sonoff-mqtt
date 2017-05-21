require('config')

TOPIC = "/sensors/relay/"
RELAY_PIN = 6
BTN_PIN = 3
DEBOUNCE = 250
MQTT_LED = 7

gpio.mode(RELAY_PIN, gpio.OUTPUT)
gpio.write(RELAY_PIN, gpio.LOW)
gpio.mode(BTN_PIN, gpio.INPUT, gpio.PULLUP)
gpio.mode(MQTT_LED, gpio.OUTPUT)
gpio.write(MQTT_LED, gpio.HIGH)

mac = wifi.sta.getmac()
ip = wifi.sta.getip()
m = mqtt.Client(CLIENT_ID, 120, "", "")

-- Flash the led on MQTT activity
function mqtt_activity()
    if (gpio.read(MQTT_LED) == 1) then 
        gpio.write(MQTT_LED, gpio.HIGH) 
    end
    gpio.write(MQTT_LED, gpio.LOW)
    tmr.alarm(5, 50, 0, function() 
        gpio.write(MQTT_LED, gpio.HIGH) 
    end)
end

-- Say hello to broker
function mqtt_online()
    DATA = '{"mac":"'..mac..'","ip":"'..ip..'","state":"'..gpio.read(RELAY_PIN)..'","online":"true","type":"switch"}'
    m:publish("/online/", DATA, 0, 0, function(conn)
        print(CLIENT_ID.." : "..DATA.." to "..TOPIC)
    end)
end

-- Publish MQTT activity to broker
function mqtt_update()
    DATA = '{"mac":"'..mac..'","ip":"'..ip..'","state":"'..gpio.read(RELAY_PIN)..'"}'
    m:publish(TOPIC, DATA, 0, 0, function(conn)
        print(CLIENT_ID.." : "..DATA.." to "..TOPIC)
    end)
end

m:lwt("/lwt", '{"message":"'..CLIENT_ID..'","topic":"'..TOPIC..'","ip":"'..ip..'"}', 0, 0)

-- Try to reconnect to broker when communication is down
m:on("offline", function(con)
    ip = wifi.sta.getip()
    print ("MQTT reconnecting to " .. BROKER_IP .. " from " .. ip)
    tmr.alarm(1, 10000, 0, function()
        node.restart()
    end)
end)

-- Toggle switch when button change state
debounced = 0
gpio.trig(BTN_PIN, "down", function (level)
    if (debounced == 0) then
        debounced = 1
        tmr.alarm(6, debounced, 0, function() debounced = 0; end)      
        if (gpio.read(RELAY_PIN) == 1) then
            gpio.write(RELAY_PIN, gpio.LOW)
            print("Relay was on, turning it off")
        else
            gpio.write(RELAY_PIN, gpio.HIGH)
            print("Relay was off, turning it on")
        end
        mqtt_activity()
        mqtt_update()
    end
end)

-- Toggle relay when message received from MQTT broker
m:on("message", function(conn, topic, data)
    mqtt_activity()
    print("Message received: " .. topic .. " : " .. data)
    parse = cjson.decode(data)
    mac = parse.mac
    state = parse.state
    if(mac == wifi.sta.getmac()) then
        if (state == "1") then
            print("Relay enable")
            gpio.write(RELAY_PIN, gpio.HIGH)
        elseif (state == "0") then
            print("Relay disable")
            gpio.write(RELAY_PIN, gpio.LOW)
        else
            print("Invalid state (" .. state .. ")")
        end
    end
end)

-- Subscribe to MQTT broker
function mqtt_sub()
    mqtt_activity()
    m:subscribe(TOPIC, 2, function(m)
        print("Successfully subscribed to the topic: "..TOPIC)
    end)
end

print("Connecting to MQTT: "..BROKER_IP..":"..BROKER_PORT.."...")
m:connect(BROKER_IP, BROKER_PORT, 0, 1, function(conn)
    gpio.write(MQTT_LED, gpio.HIGH)
    print("Connected to MQTT: "..BROKER_IP..":"..BROKER_PORT.." as "..CLIENT_ID)    
    mqtt_online()
    mqtt_sub()  
end)