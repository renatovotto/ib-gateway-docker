# IB Gateway

A Docker container to run the Interactive Brokers IB Gateway on a remote 
server. Exposes port 4001 and 4002 for the paper and live trading accounts.

## Usage

1. Clone the repository `git clone git@github.com:renatovotto/docker-ibgateway.
   git`
2. Go to the repository folder `cd docker-ibgateway`
3. Configure the IB Gateway settings on a local system.
4. Head to the "Jts" folder of your local installation
5. Copy the `jts.ini` file into the repository folder
6. Copy the `ibg.xml` file. It's inside one of the 2 folders with a very long
   and cryptic name. One is for the paper and the other for the live 
   trading account settings
7. Edit the `Dockerfile` and changing the `IB_SETTINGS_FOLDER` variable to the
   name of your settings folder name.
8. Build the image with by running `docker buildx build -t ib_gateway .`
9. Run the IB Gateway by running `docker run -d --rm -e
   ARGS="username=IB_USERNAME password=IB_PASSWORD" -p 4001:4001 -p 4002:4002 
   ib_gateway`
---
