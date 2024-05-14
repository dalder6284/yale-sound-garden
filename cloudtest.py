from pyicloud import PyiCloudService
from pythonosc.udp_client import SimpleUDPClient
from time import sleep
import datetime

INTERVAL = 5  # INTERVAL defines how far apart each location should be delivered.

api = PyiCloudService('youricloudaccount@icloud.com')
ip = "127.0.0.1"
port = 57120
client = SimpleUDPClient(ip, port)  # Create client

def main():
    current_time = datetime.datetime.now().strftime("%H:%M:%S")
    phoneloc = api.devices[1].location()
    print([phoneloc['latitude'], phoneloc['longitude']])
    client.send_message("/coords", [phoneloc['latitude'], phoneloc['longitude'], current_time])

if __name__ == "__main__":
    while True:
        main()
        sleep(INTERVAL)