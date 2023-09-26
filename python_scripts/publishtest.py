#/home/dean/dean/projects1/withoutbonus/python_scripts/publishtest.py
# Import necessary libraries
import asyncio
from nats.aio.client import Client as NATS
from datetime import datetime
import random

# Define the main asynchronous function
async def run():
    # Create Future objects to signal when publishing and receiving are complete
    publish_done = asyncio.Future()
    message_received = asyncio.Future()

    # Initialize the first NATS client
    nc1 = NATS()
    await nc1.connect("nats://3.78.247.64:4222")  # Connect to the first NATS server

    # Initialize the second NATS client
    nc2 = NATS()
    await nc2.connect("nats://18.197.138.216:4222")  # Connect to the second NATS server

    # Define callback function that triggers when a message is received
    async def cb(msg):
        print(f"Received a message on '{msg.subject}' from {msg._client.connected_url.netloc}: {msg.data.decode()}")  # Print the received message
        unique_id = msg.data.decode().split(" ")[-1]  # Extract the unique ID from the message
        print(f"Unique ID of message: {unique_id}")  # Print the unique ID
        message_received.set_result(True)  # Signal that message was received

    await nc1.subscribe("foo", cb=cb)  # Subscribe to 'foo' topic on the first server and set the callback function

    # Create a unique identifier for the message to be published
    unique_id = f"{datetime.utcnow().isoformat()}_{random.randint(1, 1000)}"

    # Publish a message with the unique ID on the second NATS server
    msg = f"Hello, NATS! {unique_id}"
    await nc2.publish("foo", msg.encode())
    print(f"Publish completed on the second server. Unique ID: {unique_id}")  # Print confirmation of the published message
    publish_done.set_result(True)  # Signal that publishing is complete

    # Wait until both the publishing and message receiving are confirmed
    await asyncio.gather(publish_done, message_received)

    # Close both NATS client connections
    await nc1.close()
    await nc2.close()

# Run the asynchronous loop
if __name__ == '__main__':
    loop = asyncio.get_event_loop()
    loop.run_until_complete(run())
