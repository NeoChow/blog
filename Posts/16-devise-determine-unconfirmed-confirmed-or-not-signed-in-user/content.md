I am developing a JSON api in rails that is using Devise to authenticate users. If the user does a GET request to the root URL, I return a list of useful URLs. I want to return different URLS depending on the status of the user:

- **Not Signed In** - register and sign_in URLs
- **Not Confirmed** - resend_confirmation, register, and sign_in URLs
- **Confirmed** - URLs to content

Normally, a route will immediately be rejected if the user is not a valid and confirmed user. To get around this and determine the 3 scenarios, I did the following:

Add a skip before filter for the index route:

    // ruby
    class HomeController
        skip_before_filter :authenticate_user!, only: [:index]
        # ...
    end

Then I can use this in my index route:

    // ruby
    def index
        user  = nil

        # if using token authentication
        # token_user = nil

        caught = catch(:warden) do
            user = warden.authenticate :scope => :user

            # if using token authentication
            # token_user = authenticate_user_from_token!
        end

        if user # or token_user # if using token authentication
            # User is confirmed
        elsif caught and caught[:message] == :unconfirmed
            # User is unconfirmed
        else
            # User is not signed in
        end
    end
