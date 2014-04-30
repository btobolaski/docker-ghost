backend default {
    .host = "localhost";
    .port = "2368";
    .probe = {
        .url = "/";
        .interval = 1s;
        .timeout = 1s;
        .window = 5;
        .threshold = 3;
    }
}


sub vcl_recv {
    # If the client uses shift-F5, get (and cache) a fresh copy. Nice for
    # systems without content invalidation. Big sites will want to disable
    # this.
    if (req.http.cache-control ~ "no-cache") {
        set req.hash_always_miss = true;
    }

    set req.http.x-pass = "false";
    # TODO: I haven't seen any urls for logging access. When the
    # analytics parts of ghost are done, this needs to be added in the
    # exception list below.
    if (req.url ~ "^/(api|signout)") {
        set req.http.x-pass = "true";
    } elseif (req.url ~ "^/ghost" && (req.url !~ "^/ghost/(img|css|fonts)")) {
        set req.http.x-pass = "true";
    }

    if (req.backend.healthy) {
        set req.grace = 30s;
    } else {
        unset req.http.Cookie;
        set req.grace = 6h;
    }

    if (req.http.x-pass == "true") {
        return(pass);
    }
    unset req.http.cookie;
}

sub vcl_fetch {
    # Only modify cookies/ttl outside of the management interface.
    set beresp.grace = 6h;
    if (req.http.x-pass != "true") {
        unset beresp.http.set-cookie;
        if (beresp.status >= 500) {
            set beresp.saintmode = 10s;
            return(restart);
        }
        if (beresp.status < 500 && beresp.ttl <= 30s ) {
            set beresp.ttl = 30s;
            unset beresp.http.cache-control;
        }
    }
}
