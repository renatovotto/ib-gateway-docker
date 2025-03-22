# IB Gateway

A Docker container to facilitate launching and running the Interactive 
Brokers IB Gateway on a remote server.

### Features
- Allows both live and paper trading mode
- Exposes port 4001 and 4002 for the paper and live trading accounts

## Usage

1. Clone the repository `git clone git@github.com:renatovotto/docker-ibgateway.
   git`
2. Go to the repository folder `cd docker-ibgateway`
3. Configure the IB Gateway settings on a local system, for both live and
   paper accounts
4. Head to the "Jts" folder of your local installation and copy the `jts.ini` 
   file into the repository folder
5. Look for the `ibg.xml` files. They are inside the two folders with a very 
   long and cryptic name. One is for the paper and the other for the live 
   trading account settings. Copy them as `l.xml` and `p.xml` in the 
   repository folder. If you are not sure which one is which, lauch the IB
   Gateway in paper or live mode, enable the "show log" option, change one item
   in the settings, press apply, and read the name of the path where it is
   saving the settings, the long name should be there
6. Edit the `Dockerfile` assigning the folder names to the `ENV` variables
   `LIVE_TRADING_SETTINGS_FOLDER` and `PAPER_TRADING_SETTINGS_FOLDER`
7. Build the Docker image by running `docker build -t ib-gateway .`
8. Launch the IB Gateway by running:

    `docker run -d --rm -e m=p -e u=ib_username -e p=ib_password
    -e d=display_mode -p 127.0.0.1:4002:4002 ib-gateway`
   
   Where:

   - `m`: Trading mode, can be either "l" for live trading or "p" for paper
   trading
   - `d`: Display mode:
     - "" (omitted) or "h": headless, use Xvfb with `DISPLAY=:1`
     - "d": use Docker host's display, `DISPLAY=host.docker.internal:0`
     - Any other value: custom DISPLAY, e.g., `127.0.0.1:10` or `host.name:7`

   The script will automatically set up the display mode based on `d`, either
   running headless, using the Docker host's display, or a custom one assigned 
   by the user.
---
