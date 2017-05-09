require('config')

TOPIC = "/sensors/relay/data"
RELAY_PIN = 6
BTN_PIN = 3
DEBOUNCE = 250
MQTT_LED = 7

gpio.mode(RELAY_PIN, gpio.OUTPUT)
gpio.write(RELAY_PIN, gpio.LOW)
gpio.mode(BTN_PIN, gpio.INPUT, gpio.PULLUP)
gpio.mode(MQTT_LED, gpio.OUTPUT)
gpio.write(MQTT_LED, gpio.HIGH)

ip = wifi.sta.getip()
m = mqtt.Client(CLIENT_ID, 120, "", "")

-- Flash the led on MQTT activity
function mqttAct()
    if (gpio.read(MQTT_LED) == 1) then gpio.write(MQTT_LED, gpio.HIGH) end
    gpio.write(MQTT_LED, gpio.LOW)
    tmr.alarm(5, 50, 0, function() gpio.write(MQTT_LED, gpio.HIGH) end)
end

-- Publish MQTT activity to broker
function mqtt_update()    
    DATA = '{"mac":"'..wifi.sta.getmac()..'", "ip":"'..ip..'",'
    DATA = DATA..'"state":"'..gpio.read(RELAY_PIN)..'"}'
    m:publish(TOPIc, DATA, 0, 0)    
end

m:lwt("/lwt", '{"message":"'..CLIENT_ID..'", "topic":"'..TOPIC..'", "ip":"'..ip..'"}', 0, 0)

-- Try to reconnect to broker when communication is down
m:on("offline", function(con)
    ip = wifi.sta.getip()
    print ("MQTT reconnecting to " .. BROKER_IP .. " from " .. ip)
    tmr.alarm(1, 10000, 0, function()
        node.restart();
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
        mqttAct()
        mqtt_update()
    end
end)

-- Toggle switch when message received from MQTT broker
m:on("message", function(conn, topic, data)
    mqttAct()
    print("Message received: " .. topic .. " : " .. data)
    if (data == "ON") then
        gpio.write(RELAY_PIN, gpio.HIGH)
    elseif (data == "OFF") then
        gpio.write(RELAY_PIN, gpio.LOW)
    else
        print("Invalid command (" .. data .. ")")
    end
    mqtt_update()
end)

-- Subscribe to MQTT broker
function mqtt_sub()
    mqttAct()
    m:subscribe(TOPIC, 2, function(m)
        print("Successfully subscribed to the topic: "..TOPIC)
    end)
end

print("Connecting to MQTT: "..BROKER_IP..":"..BROKER_PORT.."...")
m:connect(BROKER_IP, BROKER_PORT, 0, 1, function(conn)
    gpio.write(MQTT_LED, gpio.HIGH)
    print("Connected to MQTT: "..BROKER_IP..":"..BROKER_PORT.." as "..CLIENT_ID)
    mqtt_sub()
end)