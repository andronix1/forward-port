# forward-port.sh

It is util for easily create and remove forward-port services

## Getting started

Run `setup.sh`
```
chmod +x setup.sh
./setup.sh
```
It will offer you install `forward-port.sh` script if it isn't installed.

After script installed you can manage services:
```
$ ./setup.sh add
# Enter service name: my-forward-service
# Enter SSH connection string: user@host
# Enter address to forward: localhost:8080
# Enter target port: 8080
```

If you wanna delete forward service:
```
$ ./setup.sh remove
# Enter service name: my-forward-service
```
