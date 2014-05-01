# Docker Ghost

This creates a Docker container that you can run a [Ghost][1] blog in, if it is using SQLite. It mounts the code/content from the host machine so you don't need to worry about accessing your data inside the container. It also features [Varnish][2] . In [my testing][3], Ghost could only server ~40req/s, so Varnish will keep your site up if you happen to experience more requests than Ghost can handle.

To use it, you will need to mount the directory that your site resides in. On my server, my Ghost blog is at `/var/node/ruin`, so the startup command looks like:

		docker run -d -v /var/node/ruin:/ghost -m 1024m -p 127.0.0.1:2368:8080 --name=ghost btobolaski/ghost:latest
		
If you would like ghost to live on a different port, just change the `2368` in the command.

After that, I would recommend setting up nginx on your Docker host and setting up a reverse proxy. This is what my config looks like:

```
server {
    listen 80;
    server_name ruin.io www.ruin.io;

    location / {
        proxy_set_header   X-Real-IP $remote_addr;
        proxy_set_header   Host      $http_host;
        proxy_pass         http://127.0.0.1:2368;
        client_max_body_size       10m;
	      client_body_buffer_size    128k;
    }
}
```

[1]:https://ghost.org
[2]:https://www.varnish-cache.org
[3]:https://ruin.io/2014/03/29/clustering-ghost/