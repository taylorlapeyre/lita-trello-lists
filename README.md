# lita-trello-lists

This is a Lita handler for displaying your Trello lists through Lita.

## Installation

Add lita-trello-lists to your Lita instance's Gemfile:

``` ruby
gem "lita-trello-lists"
```

## Configuration

You will need to set at least one configuration variable:

``` ruby
lita.handlers.trello_lists.boards = ['123456', 'abcsfgf']
```

You can find the ID of one of your boards through its URL.

Additionally, if your boards are private, you will need to supply your Trello API key and a token. You can find out how to get these things through the [Trello API documentation](https://trello.com/docs/).

``` ruby
lita.handlers.trello_lists.key = "2345n32b42oijkn3b24j34jn34"
lita.handlers.trello_lists.token = "sahfiu23kjriuejknr239r0ofiwjben023ork2inw"
```

## Usage

Say you have a board names "Engineering" and a list in it called "In Progress". The following are all equivalent:

```
> @robot trello list in progress
> @robot trello list progress in engineering
> @robot trello list in progress in eng
```
