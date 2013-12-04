
# Hook into vcl_recv to disallow path caching
sub custom__recv {
  # # Do not cache these paths.
  # if (req.url ~ "^/foo\.php$" ||
  #     req.url ~ "^.*/bar/.*$") {
  #     req.url ~ "^.*/baz/.*$") {
  #      return (pass);
  # }
}

sub custom__fetch {
  # if (req.url ~ "/fboauth/connect") {
  #   return (hit_for_pass);
  # }
}

# In the event of an error, show friendlier messages.
sub vcl_error {
  set obj.http.Content-Type = "text/html; charset=utf-8";
  synthetic {"
<html>
<head>
  <title>Page Unavailable</title>
  <style>
    body { background: #303030; text-align: center; color: white; }
    #page { border: 1px solid #CCC; width: 500px; margin: 100px auto 0; padding: 30px; background: #323232; }
    a, a:link, a:visited { color: #CCC; }
    .error { color: #222; }
  </style>
</head>
<body onload="setTimeout(function() { window.location = '/' }, 5000)">
  <div id="page">
    <h1 class="title">Page Unavailable</h1>
    <p>The page you requested is temporarily unavailable.</p>
    <p>We're redirecting you to the <a href="/">homepage</a> in 5 seconds.</p>
    <div class="error">(Error "} + obj.status + " " + obj.response + {")</div>
  </div>
</body>
</html>
"};
  return (deliver);
}
