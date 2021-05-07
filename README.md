# sisymon

**Si**mpe **Sy**stem **Mon**itoring API responder

A lightweight bash tool, intended as a CGI script
for Apache or simillar on Linux environment. 

Responds with basic server vitals in JSON.

Only dependency: [jq 1.6](https://stedolan.github.io/jq/)

## Setup

Clone in this into a desired directory, i.e. `/var/www/html`

Add following lines into your virtualhosts' (sites-enabled) config  
```apacheconf
SetEnvIf    Authorization "(.*)" HTTP_AUTHORIZATION=$1
ScriptAlias "/sisymon"    "<YOUR_DIRECTORY>/sisymon/index.sh"
```

Example config
```apacheconf
<VirtualHost _default_:80>
  DocumentRoot /var/www/html
  SetEnvIf    Authorization "(.*)" HTTP_AUTHORIZATION=$1
  ScriptAlias "/sisymon" "<YOUR_DIRECTORY>/sisymon/index.sh"
  ...
</VirtualHost>
````

Also, don't forget to enable `cgi` or `cgid` module
```bash
$ sudo a2enmod cgid
$ sudo service apache2 restart
```

Install `jq`
```bash
$ sudo apt update && sudo apt install jq
```

Don't forget to set your **auth bearer** in `config.ini` (see Configuration below). Default bearer is: sysimon21

## Example use

```bash
$ curl -s \
    -H "Authorization: Bearer <YOUR_SECRET_AUTH_BEARER>" \
    <YOUR_SERVER_URL>/sisymon \
    | jq
```

## Example response

```json5
{
  "uptime": 33455688.82,          // uptime in seconds
  "load": [
    0.15,                         // system load 1m average 
    0.12,                         // system load 5m average
    0.11,                         // system load 15m average
    "5/331"                       // running / total processes
  ],
  "memory": {
    "ram": {
      "usage": "28%",
      "total": 4041540,           // kB
      "free": 2921436
    },
    "swap": {
      "usage": "22%",
      "total": 974844,
      "free": 764292
    }
  },
  "disks": [
    {
      "device": "/dev/xvda1",
      "mount": "/",
      "usage": "61%",
      "total": 19494912,          // kB
      "free": 11749972
    }
  ],
  "services": {
    "ssh": {
      "active": "active",
      "substate": "running",
      "uptime": 33456255,          // seconds
      "tasks": 4,                  // total subprocesses
      "memory": 50470912           // kB
    },
    "apache2": {
      "active": "active",
      "substate": "running",
      "uptime": 21330370,
      "tasks": 134,
      "memory": 92745728
    }
  }
}
```

## Configuration

Don't forget to `cp config.default.ini cp.ini`

```ini
[sisymon]
auth_bearer="your_super_secret_auth_bearer"   # Your super secret auth bearer
services=("ssh" "apache2" "mysql" "ntp")      # list of services to monitor
disks=("/", "/home")                          # list of disks to monitor by mount paths
```
