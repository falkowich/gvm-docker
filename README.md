# gvm-docker

## WIP - DO NOT USE IN PROD:

### To try this out:

#### Download and build the image.

```
git clone https://github.com/falkowich/gvm-docker.git
cd gvm-docker
docker build -t falkowich/gvm:dev gvmd/. 
```

#### Start the container

```
docker-compose up -d
```

#### Then some manual stuff

Until things settles in this repo and is functioning as is should :)

```
docker-compose exec gvm /bin/bash
sudo su - gvm
export PATH=/opt/gvm/bin:/opt/gvm/sbin:/opt/gvm/.local/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
gvmd --create-scanner='TEST OPENVAS Scanner' --scanner-type='OpenVas' --scanner-host=/opt/gvm/var/run/ospd.sock
```

#### Then it should work :tm:

Browse to your host on https://127.0.0.1

Want latest status, change anything, help out?  

Pls create issue's or join here [slack invite](https://join.slack.com/t/sadsloth/shared_invite/enQtODI0MTM2Nzc4OTQ0LWZmOThkYzY4MzAwZjVjYzhmMDdkYTY3MmFkOTk0YmNlZmQ2MWMwNDM5MmE4ZjUzZmU5MmU0YjQzYmE3YzhjZmU) :) 