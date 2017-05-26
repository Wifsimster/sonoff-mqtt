require('config')

-- Flash the led on MQTT activity
function mqtt_activity()
    if (gpio.read(LED) == 1) then 
        gpio.write(LED, gpio.HIGH)
    end
    gpio.write(LED, gpio.LOW)
    tmr.alarm(5, 50, 0, function()
        gpio.write(LED, gpio.HIGH)
    end)
end

-- Publish MQTT activity to broker
function mqtt_update()
    DATA = '{"mac":"'..mac..'","state":"'..gpio.read(RELAY)..'"}'
    m:publish(TOPIC, DATA, 0, 0, function(conn)
        print(TOPIC.." : "..CLIENT_ID.." - "..DATA..)
    end)
end

-- Subscribe to MQTT broker
function mqtt_sub()
    mqtt_activity()
    m:subscribe(TOPIC, 2, function(m)
        print("Successfully subscribed to the topic: "..TOPIC)
    end)
end

-- Say hello to MQTT broker
function mqtt_online()
    mqtt_activity()
    DATA = '{"mac":"'..mac..'","ip":"'..ip..'","name":"'..CLIENT_ID..'","type":"'..DEVICE_TYPE..'"}'
    m:publish(ONLINE_TOPIC, DATA, 0, 0, function(conn)
        print(TOPIC.." : "..CLIENT_ID)
    end)
end

-- Ping MQTT broker
function mqtt_ping()
    tmr.alarm(2, 10000, 0, function()
        mqtt_activity()
        DATA = '{"mac":"'..mac..'"}'
        m:publish(PING_TOPIC, DATA, 0, 0, function(conn)
            print(TOPIC.." : "..CLIENT_ID)
        end)
    end)
end