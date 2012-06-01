This is a simple implementation of the google OAUTH lifecycle

It has a dependency on jQuery and knockoutjs (but the knockoutjs can be easily removed!)

To use, just create the OAuth class and call authenticate when running it:

```
$(function() {
	var auth = new OAuth(window);
	auth.authenticate(function(isAuth) {
		alert(isAuth ? 'User has let me access stuff' : 'or not');
	});
});
```

Note that this class will redirect on the authenticate call, and is expecting the redirect from google to hit the same page that it is called from.