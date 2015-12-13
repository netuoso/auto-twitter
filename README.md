### Ruby Based Auto-Tweeting Twitter Bot

#### Getting Started

1. Clone this repository
 - `git clone https://github.com/netuoso/auto-twitter`
2. Install gems using bundler
 - `bundle install`
3. [Get your API keys](https://apps.twitter.com)
4. Setup your environment variables:
 - `export TWITTER_CONSUMER_KEY = '{{CONSUMER_KEY_HERE}}'
 - `export TWITTER_CONSUMER_SECRET = '{{CONSUMER_SECRET_HERE}}'
 - `export TWITTER_ACCESS_TOKEN = '{{ACCESS_TOKEN_HERE}}'
 - `export TWITTER_ACCESS_SECRET = '{{ACCESS_SECRET_HERE}}'
5. Test to make sure your setup works
 - `./auto-twitter.rb -a dev`
 - `rest_client.current_user.name`
 - If the above command displays your Twitter nick, everything is good.
6. [Submit any issues you encounter](https://github.com/netuoso/auto-twitter/issues/new)

#### Contributing

If you wish to contribute, clone this repository and submit a pull request with your
desired code. Make sure to include documentation supporting your change and update the README if necessary.

#### License

This project is open source and distributed under the MIT License.