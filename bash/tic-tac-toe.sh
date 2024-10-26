#!/usr/bin/env sh

## Random moves cba making logic.
get_computer_move() {
    available_moves=$(get_available_moves)
    random_index=$(( (RANDOM % $(printf "%s" "$available_moves" | wc -w)) + 1 ))
    printf "%s" "$available_moves" | cut -d' ' -f$random_index
}

display_board() {
    printf '\033c' # This is clear symbol | we don't want to use clear bashism
    printf " ${BOARD[1]} | ${BOARD[2]} | ${BOARD[3]} \n"
    printf -- "---+---+---\n" ## -- (end of options) is need to not cause errors
    printf " ${BOARD[4]} | ${BOARD[5]} | ${BOARD[6]} \n"
    printf -- "---+---+---\n"
    printf " ${BOARD[7]} | ${BOARD[8]} | ${BOARD[9]} \n"
    printf "\n"
    printf "Available moves: $(get_available_moves)\n"
}

get_available_moves() {
    for i in 1 2 3 4 5 6 7 8 9; do
        case "${BOARD[$i]}" in
            X|O) ;;
            *) printf "%s " "$i" ;;
        esac
    done
}

check_win() {
    PLAYER=$1

    [ "${BOARD[1]}" = "$PLAYER" ] && [ "${BOARD[2]}" = "$PLAYER" ] && [ "${BOARD[3]}" = "$PLAYER" ] && return 0
    [ "${BOARD[4]}" = "$PLAYER" ] && [ "${BOARD[5]}" = "$PLAYER" ] && [ "${BOARD[6]}" = "$PLAYER" ] && return 0
    [ "${BOARD[7]}" = "$PLAYER" ] && [ "${BOARD[8]}" = "$PLAYER" ] && [ "${BOARD[9]}" = "$PLAYER" ] && return 0
    [ "${BOARD[1]}" = "$PLAYER" ] && [ "${BOARD[4]}" = "$PLAYER" ] && [ "${BOARD[7]}" = "$PLAYER" ] && return 0
    [ "${BOARD[2]}" = "$PLAYER" ] && [ "${BOARD[5]}" = "$PLAYER" ] && [ "${BOARD[8]}" = "$PLAYER" ] && return 0
    [ "${BOARD[3]}" = "$PLAYER" ] && [ "${BOARD[6]}" = "$PLAYER" ] && [ "${BOARD[9]}" = "$PLAYER" ] && return 0
    [ "${BOARD[1]}" = "$PLAYER" ] && [ "${BOARD[5]}" = "$PLAYER" ] && [ "${BOARD[9]}" = "$PLAYER" ] && return 0
    [ "${BOARD[3]}" = "$PLAYER" ] && [ "${BOARD[5]}" = "$PLAYER" ] && [ "${BOARD[7]}" = "$PLAYER" ] && return 0
    return 1
}

# Function to check for a draw
check_draw() {
    for i in 1 2 3 4 5 6 7 8 9; do
        if [ "${BOARD[$i]}" != "X" ] && [ "${BOARD[$i]}" != "O" ]; then
            return 1
        fi
    done
    return 0
}

save_game() {
    printf "%s\n" "${BOARD[@]}" > game_state.txt
    printf "%s\n%s\n%s\n%s\n%s\n" "$CURRENT_PLAYER" "$PLAYER_1_NAME" "$PLAYER_2_NAME" "$PLAYER_SYMBOL" "$GAME_MODE" >> game_state.txt
    printf "Game saved successfully!\n"
}

# Function to load the game state
load_game() {
    if [ ! -f game_state.txt ]; then
        printf "No saved game found.\n"
        return 1
    fi

    mapfile -t BOARD < game_state.txt
    CURRENT_PLAYER=$(sed -n '11p' game_state.txt)
    PLAYER_1_NAME=$(sed -n '12p' game_state.txt)
    PLAYER_2_NAME=$(sed -n '13p' game_state.txt)
    PLAYER_SYMBOL=$(sed -n '14p' game_state.txt)
    GAME_MODE=$(sed -n '15p' game_state.txt)

    printf '\033c' # This is clear symbol | we don't want to use clear bashism
    printf "Game loaded successfully!\n"
    printf "Loaded data:\n"
    printf "Board: ${BOARD[*]}\n"
    printf "Current Player: %s\n" "$CURRENT_PLAYER"
    printf "Player 1 Name: %s\n" "$PLAYER_1_NAME"
    printf "Player 2 Name: %s\n" "$PLAYER_2_NAME"
    printf "Player Symbol: %s\n" "$PLAYER_SYMBOL"
    printf "Game Mode: %s\n" "$GAME_MODE"
    printf "Press Enter to continue..."
    read
    return 0
}

initialize_players() {
    printf "Player 1 | Please enter your name: "
    read PLAYER_1_NAME
    if [ "$GAME_MODE" = "1" ]; then
        printf "Player 2 | Please enter your name: "
        read PLAYER_2_NAME
    else
        PLAYER_2_NAME="Computer"
    fi

    printf "%s, do you want to play as X or O? (X starts first) (defaults to X) " "$PLAYER_1_NAME"
    read PLAYER_SYMBOL

    if [ "$PLAYER_SYMBOL" != "X" ] && [ "$PLAYER_SYMBOL" != "O" ]; then
        PLAYER_SYMBOL="X"
    fi

    # Always start with X
    CURRENT_PLAYER="X"
}

# Initialize the board
BOARD=(" " "1" "2" "3" "4" "5" "6" "7" "8" "9")

# Main game loop
printf "Welcome to Tic-Tac-Toe!\n"

# Start menu
while true; do
    printf "1. Play with a friend\n"
    printf "2. Play against the computer\n"
    printf "3. Load saved game\n"
    printf "Enter your choice (1, 2, or 3): "
    read GAME_MODE

    if [ "$GAME_MODE" = "1" ] || [ "$GAME_MODE" = "2" ]; then
        initialize_players
        BOARD=(" " "1" "2" "3" "4" "5" "6" "7" "8" "9")
        break
    elif [ "$GAME_MODE" = "3" ]; then
        if load_game; then
            break
        fi
    else
        printf "Invalid choice. Please enter 1, 2, or 3.\n"
    fi
done

# Main game loop
while true; do
    display_board

    if [ "$CURRENT_PLAYER" = "$PLAYER_SYMBOL" ]; then
        printf "%s [%s], enter your move (1-9), 's' to save, or 'q' to quit: " "$PLAYER_1_NAME" "$CURRENT_PLAYER"
        read MOVE
    elif [ "$GAME_MODE" = "1" ]; then
        printf "%s [%s], enter your move (1-9), 's' to save, or 'q' to quit: " "$PLAYER_2_NAME" "$CURRENT_PLAYER"
        read MOVE
    else
        MOVE=$(get_computer_move)
        printf "Computer [%s] chooses move: %s\n" "$CURRENT_PLAYER" "$MOVE"
        sleep 0.5
    fi

    case "$MOVE" in
        s|S)
            save_game
            continue
            ;;
        q|Q)
            printf "Thanks for playing!\n"
            exit 0
            ;;
    esac

    if [ "$MOVE" -lt 1 ] || [ "$MOVE" -gt 9 ] || [ "${BOARD[$MOVE]}" = "X" ] || [ "${BOARD[$MOVE]}" = "O" ]; then
        printf "Invalid move. Try again.\n"
        continue
    fi

    BOARD[$MOVE]=$CURRENT_PLAYER

    # CHECK FOR WINS/DRAWS
    if check_win "$CURRENT_PLAYER"; then
        display_board
        # Display WIN/LOSS message
        if [ "$CURRENT_PLAYER" = "$PLAYER_SYMBOL" ]; then
            printf "Congratulations %s! You win!\n" "$PLAYER_1_NAME"
        elif [ "$GAME_MODE" = "2" ]; then
            printf "Sorry %s, you lost to the Computer!\n" "$PLAYER_1_NAME"
        else
            printf "Congratulations %s! You win!\n" "$PLAYER_2_NAME"
        fi
        break
    fi

    if check_draw; then
        display_board
        printf "It's a draw!\n"
        break
    fi

    if [ "$CURRENT_PLAYER" = "X" ]; then
        CURRENT_PLAYER="O"
    else
        CURRENT_PLAYER="X"
    fi
done

printf "Thanks for playing!\n"
