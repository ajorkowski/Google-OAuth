@OAuth = class OAuth
	constructor: (@window) ->
		# These are your application constants
		# First you will need to register your app so that users can allow you access
		@clientId = 'yourappid.apps.googleusercontent.com'
		
		# Next pick your scope (what api's do you want to connect to)
		scope = 'https://www.google.com/calendar/feeds/'

		# Finally you must specify where to redirect back to
		# Note: this must match what you have set up in your app setup
		# And it can be localhost
		redirectUrl = 'http://www.yourwebsite.com/'

		# Use this token when you access google api items
		# I use knockout to watch when the access becomes available
		@accessToken = ko.observable()

		data = $.param
			response_type: 'token'
			client_id: @clientId
			redirect_uri: encodeURI redirectUrl
			scope: encodeURI scope	

		@initialUrl = 'https://accounts.google.com/o/oauth2/auth?' + data
		@validationUrl = 'https://www.googleapis.com/oauth2/v1/tokeninfo'

	authenticate: (cb) =>
		params = @findParams()
		error = params['error']

		# Clear the hash
		# I do this to make the url look tidy
		@window.location.hash = ""

		if error == 'access_denied'
			return cb false

		token = params['access_token']

		# If we haven't errored and we haven't got an access token, go grab it
		if not token?	
			@window.location = @initialUrl
			return

		# Once we have a token we have to validate it, make sure it is for our app
		# and that it is still kicking
		$.ajax(@validationUrl, { crossDomain: true, data: { access_token: token }, dataType: 'jsonp' })
		.fail(() -> cb false)
		.done (data) =>
			# Check if error, or if the audience matches our api
			# The audience matching is absolutely essential for security
			if not data.error? and data.audience == @clientId
				@accessToken(token)
				cb true
			else
				cb false


	findParams: () =>
		params = {}
		queryString = @window.location.hash.substring(1)
		regex = /([^&=]+)=([^&]*)/g

		while (m = regex.exec(queryString)) 
			params[decodeURIComponent m[1]] = decodeURIComponent m[2]

		return params