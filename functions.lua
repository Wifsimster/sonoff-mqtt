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

function mqtt_state()
    TOPIC = '/data/'
    DATA = '{"mac":"'..mac..'","state":"'..gpio.read(RELAY)..'"}'
    m:publish(TOPIC, DATA, 0, 0, function(conn)
        print(TOPIC.." : "..CLIENT_ID.." - "..DATA)
    end)
end

function mqtt_subscribe()
    mqtt_activity()
    TOPIC = '/action/'
    m:subscribe(TOPIC, 2, function(m)
        print("Successfully subscribed to the topic: "..TOPIC)
    end)
end

function mqtt_ping()
    mqtt_activity()
    TOPIC = '/ping/'
    DATA = '{"mac":"'..mac..'"}'
    m:publish(TOPIC, DATA, 0, 0, function(conn)
        print(TOPIC.." : "..CLIENT_ID)
    end)
end

function mqtt_online()
    mqtt_activity()
    TOPIC = '/online/'
    DATA = '{"mac":"'..mac..'","ip":"'..ip..'","name":"'..CLIENT_ID..'","type":"'..DEVICE_TYPE..'"}'
    m:publish(TOPIC, DATA, 0, 0, function(conn)
        print(TOPIC.." : "..CLIENT_ID)
    end)
end

function mqtt_ip()
    TOPIC = '/ip/'
    mqtt_activity()
    DATA = '{"mac":"'..mac..'","ip":"'..ip..'"}'
    m:publish(TOPIC, DATA, 0, 0, function(conn)
        print(TOPIC.." : "..DATA)
    end)
end

function mqtt_name()
    TOPIC = '/name/'
    mqtt_activity()
    DATA = '{"mac":"'..mac..'","name":"'..CLIENT_ID..'"}'
    m:publish(TOPIC, DATA, 0, 0, function(conn)
        print(TOPIC.." : "..DATA)
    end)
end

function mqtt_type()
    TOPIC = '/type/'
    mqtt_activity()
    DATA = '{"mac":"'..mac..'","type":"'..DEVICE_TYPE..'"}'
    m:publish(TOPIC, DATA, 0, 0, function(conn)
        print(TOPIC.." : "..DATA)
    end)
end
