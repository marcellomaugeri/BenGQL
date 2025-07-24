```
docker build --platform=linux/amd64 -t petclinic .   
docker run --rm -it -p 8080:8080 petclinic          
```

# Not working:
The issue relies on the Docker-In-Docker, probably the container must be open with the `--privileged` flag.
Tried also to mounth the volume with the `-v /var/run/docker.sock:/var/run/docker.sock` flag, but it did not work.