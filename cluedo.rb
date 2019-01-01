require 'set'



$suspects = Set.new [ :yellow, :green, :blue, :red, :white, :purple ]
$weapons = Set.new [ :candlestick, :dagger, :pipe, :revolver, :rope, :wrench ]
$rooms = Set.new [ :kitchen, :ballroom, :conservatory, :dining, :billiard, :library, :lounge, :hall, :study ]



$facts = []
$player_cards = Set.new []


def init(cards)
    $facts = []
    $player_cards = Set.new cards
end


def owns(player, one_of)
    $facts << lambda do |cards|
        one_of.any? do |x|
            cards[player].member? x
        end
    end
end

def owns_not(player, one_of)
    $facts << lambda do |cards|
        one_of.all? do |x|
            not cards[player].member? x
        end
    end
end

def picks(n, xs)
    if n == 0
        yield Set.new
    elsif xs.length > 0
        first, *rest = xs

        picks(n - 1, rest) { |picked| yield picked + [ first ] }
        picks(n, rest) { |picked| yield picked }
    end
end

def hands
    picks(1, ($weapons - $player_cards).to_a) do |weapon|
        picks(1, ($rooms - $player_cards).to_a) do |room|
            picks(1, ($suspects - $player_cards).to_a) do |murderer|
                solution = weapon + room + murderer
                cards = $weapons + $rooms + $suspects - $player_cards - solution

                picks(6, cards.to_a) do |p1|
                    picks(6, (cards - p1).to_a) do |p2|
                        hand = { :me => $player_cards, 1 => p1, 2 => p2, :solution => solution }

                        if $facts.all? { |fact| fact[hand] }
                            yield hand
                        end
                    end
                end
            end
        end
    end
end


def solve
    init = $weapons + $rooms + $suspects
    common = { :me => init, 1 => init, 2 => init, :solution => init }

    hands do |hand|

        common.keys.each do |key|
            common[key] = common[key] & hand[key]
        end
    end

    common
end


init([:purple, :rope, :ballroom, :hall, :kitchen, :billiard])


owns(1, [ :rope, :red, :dance ])
owns(2, [ :rope, :red, :dance ])
owns_not(1, [ :dagger, :blue, :library] )
owns_not(2, [ :wrench, :green, :hall] )

# hands { |x| p x }

p solve