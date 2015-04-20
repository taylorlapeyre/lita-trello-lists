module Lita
  module Handlers
    class TrelloLists < Handler
      config :key, type: String, required: false
      config :token, type: String, required: false
      config :boards, type: Array, required: true

      TRELLO_API_URL = "https://api.trello.com/1"

      route(/^trello list (.*)$/, :list_summary, command: true, help: {
        "trello list LIST NAME" => "Show a summary of the cards in a certain list on Trello."
      })

      route(/^trello list (.+) in (.+)?$/, :list_summary, command: true, help: {
        "trello list LIST NAME in BOARD NAME" => "Show a summary of the cards in a list on a specific board on Trello."
      })

      def list_summary(message)
        list_name_fragment  = message.matches[0][0]
        board_name_fragment = message.matches[0][1]

        board_name = find_board_from_fragment(board_name_fragment)
        list_name  = find_list_from_fragment(list_name_fragment, board_name)

        if board_name_fragment && board_name.nil?
          message.reply("We couldn't find a board from the name \"#{board_name}\".")
          return
        end

        if list_name.nil?
          message.reply("We couldn't find a list from the name \"#{list_name}\".")
          return
        end

        if board_name.nil? && list_exists_in_multiple_boards?(list_name)
          response =  "The list \"#{list_name}\" appears in multiple Trello boards. Try this:\n"
          response += "> everbot trello list #{list_name_fragment} in BOARD NAME"
          message.reply(response)
          return
        end

        response = "**Cards in #{list_name}:** \n"
        response += get_cards_for(list_name, board_name).map do |card|
          members = card[:members].map { |m| "      #{m}\n" }
          [
            "-  _#{card[:name]}_",
            "    Assigned To:",
            card[:members].map { |m| "      #{m}" }
          ].flatten.join("\n")
        end.join("\n\n")
        message.reply(response)
      end

      def get_cards_for(list, board)
        possible_lists = board ? lists_in_board(board) : lists_in_all_boards
        list_id = possible_lists.select { |l| l["name"] == list }.first["id"]

        cards = trello_get("/lists/#{list_id}", cards: "open")["cards"]
        cards.map do |card|
          {
            members: card["idMembers"].map { |id| trello_get("/members/#{id}")["fullName"] },
            name: card["name"],
            url: card["shortUrl"]
          }
        end
      end

      def list_exists_in_multiple_boards?(fragment)
        list_name = best_match_in_array(fragment, all_list_names)
        all_list_names.select { |name| name == list_name }.count > 1
      end

      def find_list_from_fragment(fragment, board)
        list_names = if board
          lists_in_board(board).map  { |list| list["name"] }
        else
          all_list_names
        end

        best_match_in_array(fragment, list_names)
      end

      def find_board_from_fragment(fragment)
        best_match_in_array(fragment, all_board_names)
      end

      def best_match_in_array(fragment, collection)
        findings = collection.map do |thing|
          match = thing[/#{fragment}/i]

          length_of_match = match ? match.length : 0

          [length_of_match, thing]
        end.to_h

        findings[findings.keys.sort.last] unless findings.keys.all?(&:zero?)
      end

      def lists_in_all_boards
        boards.map { |board| board["lists"] }.flatten
      end

      def lists_in_board(board_name)
        boards.select { |board| board["name"] == board_name }.first["lists"]
      end

      def all_board_names
        boards.map { |board| board["name"] }
      end

      def all_list_names
        boards.map do |board|
          board["lists"].map { |list| list["name"] }
        end.flatten
      end

      def boards
        if @cached_data.nil? || (Time.now.sec - @last_access.sec) >= 5
          @cached_data = config.boards.map do |board_id|
            trello_get("/boards/#{board_id}", lists: "open")
          end
          @last_access = Time.now
        end
        @cached_data
      end

      def trello_get(url, params={})
        params.merge!({
          key: config.key,
          token: config.token
        })

        MultiJson.load(http.get(TRELLO_API_URL + url, params).body)
      end
    end

    Lita.register_handler(TrelloLists)
  end
end
