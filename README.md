# Overview
This is a repo of Dockerfile for `bitcoinsv` node. The Dockerfile is based on the template of [zquestz/docker-bitcoin](https://github.com/zquestz/docker-bitcoin). 

# Get Start
Build image and run container:
```
docker build -t bsv .
docker container run -d --name bsv --restart=always -v /data/full_node_data/data:/data -p 8333:8333 -p 8332:8332 -p 28332:28332 bsv
```
# How to stop container
Notice there is no way to trap SIGKILL, therefore bitcoind container will shutdown ugly (which will cause [issue #11600 - Rolling Forward](https://github.com/bitcoin/bitcoin/issues/11600)) if you stop it with SIGKILL, for example, using `docker kill` and `docker rm -f`. 

What's more, as mentioned in article [Gracefully Stopping Docker Containers](https://www.ctl.io/developers/blog/post/gracefully-stopping-docker-containers/#:~:text=The%20docker%20stop%20command%20attempts,SIGKILL%20signal%20will%20be%20sent.), when the command `docker stop` is issued, it first try to send a SIGTERM signal to the root process (PID 1, if your process is not run as PID 1, you need make sure the SIGTERM signal is properly propogated to the child processes of root process, which is covered in the article [How to propagate SIGTERM to a child process in a Bash script](http://veithen.io/2014/11/16/sigterm-propagation.html)), if the process has not exited within the timeout period (specify it through `--time, -t` option, default value is 10s) a SIGKILL signal will be sent. 

So we also need to confirm that the timeout period is longer enough (around 3mins) for the graceful shutdown of bitcoind. For example, give it 10 min to execute `bitcoin-cli stop` command:
```
docker stop -t 600 bitcoind
```

When you run the full node as a pod in Kubernetes, be sure to add `terminationGracePeriodSeconds` to give the pod time to gracefully shutdown# bitcoinsv-docker-image
