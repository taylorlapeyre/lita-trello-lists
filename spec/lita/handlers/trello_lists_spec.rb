require "spec_helper"

describe Lita::Handlers::TrelloLists, lita_handler: true do
  before do
    # Trello's "welcome" boards
    Lita.config.handlers.trello_lists.boards  = ["bKbdmCKB", "9dnaRkNt", "VVPQBpZE"]
  end

  it { is_expected.to route_command("trello list Basics").to(:list_summary) }
  it { is_expected.to route_command("trello list Basics Things").to(:list_summary) }
  it { is_expected.to route_command("trello list Basics in Welcome Board").to(:list_summary) }

  it "responds with a summary when given a list name" do
    send_command "trello list Basics"
    expect(replies).to_not be_empty
    expect(replies.last).to match /Welcome to Trello/
  end

  it "can list the cards of a list in a specific board" do
    send_command "trello list Getting Started in How to Use Trello for Android"
    expect(replies).to_not be_empty
    expect(replies.last).to match /Tap on a card/
  end

  it "can find a list with a partial string match" do
    send_command "trello list interm"
    expect(replies).to_not be_empty
    expect(replies.last).to match /Intermediate/
  end

  it "responds with a helpful message when the list is in multiple boards" do
    send_command "trello list Getting Started"
    expect(replies).to_not be_empty
    expect(replies.last).to match /appears in multiple Trello boards/
  end

  it "responds with a helpful message when the list isn't found" do
    send_command "trello list foobar"
    expect(replies).to_not be_empty
    expect(replies.last).to match /We couldn't find a list/
  end

  it "responds with a helpful message when the board isn't found" do
    send_command "trello list Basics in Foobar"
    expect(replies).to_not be_empty
    expect(replies.last).to match /We couldn't find a board/
  end
end
