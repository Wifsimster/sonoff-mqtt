-- Wifi Settings
AP = "WIFWIFI"
PWD = "192Wifsimster!!"

-- MQTT Broker
BROKER_IP = "192.168.0.35"
BROKER_PORT = 1883

-- MQTT Settings
CLIENT_ID = "ESP8266-"..node.chipid()
ONLINE_TOPIC = "/online/"
PING_TOPIC = "/ping/"
DATA_TOPIC = "/sensors/relay/"
DEVICE_TYPE = "switch"

-- Device Settings
DEBOUNCE = 250
BTN = 3         -- GPIO 0
RELAY = 6       -- GPIO 12
LED = 7         -- GPIO 13