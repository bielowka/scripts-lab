#!/bin/bash

# Plansza do gry
board=(" " " " " " " " " " " " " " " " " " " ")
current_player="X"
is_with_computer=false

# Funkcja do wyświetlania planszy
display_board() {
    echo " ${board[0]} | ${board[1]} | ${board[2]} "
    echo "---+---+---"
    echo " ${board[3]} | ${board[4]} | ${board[5]} "
    echo "---+---+---"
    echo " ${board[6]} | ${board[7]} | ${board[8]} "
}

# Funkcja do sprawdzenia wygranej
check_winner() {
    local b=("${board[@]}")
    local win_conditions=(
        "0 1 2" "3 4 5" "6 7 8" # wiersze
        "0 3 6" "1 4 7" "2 5 8" # kolumny
        "0 4 8" "2 4 6"         # przekątne
    )
    for condition in "${win_conditions[@]}"; do
        set -- $condition
        if [[ ${b[$1]} != " " && ${b[$1]} == ${b[$2]} && ${b[$2]} == ${b[$3]} ]]; then
            echo "true"
            return
        fi
    done
    echo "false"
}

# Funkcja sprawdzająca remis
check_draw() {
    for cell in "${board[@]}"; do
        if [[ $cell == " " ]]; then
            echo "false"
            return
        fi
    done
    echo "true"
}

# Funkcja zapisywania gry
save_game() {
    local modified_board=("${board[@]/ /Y}")
    echo "${modified_board[*]}" > save_game.txt
    echo "$current_player" >> save_game.txt
    echo "Gra została zapisana!"
    sleep 1
}

# Funkcja wczytywania gry
load_game() {
    if [[ -f save_game.txt ]]; then
        IFS=" " read -r -a board < <(head -n 1 save_game.txt)
        for i in "${!board[@]}"; do
            if [[ ${board[$i]} == "Y" ]]; then
                board[$i]=" "
            fi
        done
        current_player=$(tail -n 1 save_game.txt)
        echo "Gra została wczytana!"
    else
        echo "Brak zapisanej gry do wczytania."
    fi
    sleep 1
}

# Funkcja minimax do oceny ruchów
minimax() {
    local depth=$1
    local is_maximizing=$2
    local winner=$(check_winner)

    if [[ $winner == "X" ]]; then
        echo -10 # Gracz wygrywa
        return
    elif [[ $winner == "O" ]]; then
        echo 10 # Komputer wygrywa
        return
    elif [[ $(check_draw) == "true" ]]; then
        echo 0 # Remis
        return
    fi

    local best_score
    if [[ $is_maximizing == "true" ]]; then
        best_score=-1000
        for i in "${!board[@]}"; do
            if [[ ${board[$i]} == " " ]]; then
                board[$i]="O"
                score=$(minimax $((depth + 1)) false)
                board[$i]=" "
                best_score=$((score > best_score ? score : best_score))
            fi
        done
    else
        best_score=1000
        for i in "${!board[@]}"; do
            if [[ ${board[$i]} == " " ]]; then
                board[$i]="X"
                score=$(minimax $((depth + 1)) true)
                board[$i]=" "
                best_score=$((score < best_score ? score : best_score))
            fi
        done
    fi
    echo "$best_score"
}

computer_move() {
    echo "Ruch komputera..."
    sleep 1
    local best_score=-1000
    local best_move=-1

    for i in "${!board[@]}"; do
        if [[ ${board[$i]} == " " ]]; then
            board[$i]="O"
            score=$(minimax 0 false)
            board[$i]=" "
            if [[ $score -gt $best_score ]]; then
                best_score=$score
                best_move=$i
            fi
        fi
    done

    board[$best_move]="O"
}

# Funkcja gry
play_game() {
    while true; do
        clear
        echo "Kółko i krzyżyk"
        display_board
##
#        if [[ $is_with_computer == "true" && $current_player == "O" ]]; then
#            computer_move
#            if [[ $(check_winner) == "true" ]]; then
#                clear
#                display_board
#                echo "Komputer wygrywa!"
#                sleep 3
#                > save_game.txt # Czyścimy zapis
#                break
#            elif [[ $(check_draw) == "true" ]]; then
#                clear
#                display_board
#                echo "Remis!"
#                > save_game.txt # Czyścimy zapis
#                break
#            fi
#            current_player="X"
#            continue
#        fi
##
        echo "Gracz $current_player, wybierz pole (0-8) lub 'save' aby zapisać grę lub 'exit' aby zakonczyc:"
        read -r move
        if [[ $move == "save" ]]; then
            save_game
            continue
        elif [[ $move == "exit" ]]; then
            echo "Zakończono grę."
            break
        elif [[ ! $move =~ ^[0-8]$ ]] || [[ ${board[$move]} != " " ]]; then
            echo "Nieprawidłowy ruch. Spróbuj ponownie."
            sleep 1
            continue
        fi
        board[$move]=$current_player
        if [[ $(check_winner) == "true" ]]; then
            clear
            display_board
            echo "Gracz $current_player wygrywa!"
            sleep 3
            > save_game.txt # Czyścimy zapis
            break
        elif [[ $(check_draw) == "true" ]]; then
            clear
            display_board
            echo "Remis!"
            > save_game.txt # Czyścimy zapis
            break
        fi
        current_player=$([[ $current_player == "X" ]] && echo "O" || echo "X")
    done
}

# Menu główne
main_menu() {
    while true; do
        clear
        echo "Kółko i krzyżyk - Menu główne"
        echo "1. Nowa gra"
        echo "2. Wczytaj grę i graj 1v1"
        echo "3. Nowa gra z komputerem"
        echo "4. Wczytaj grę i graj z komputerem"
        echo "5. Wyjście"
        read -r choice
        case $choice in
            1)
                board=(" " " " " " " " " " " " " " " " " " " ")
                current_player="X"
                is_with_computer=false
                play_game
                ;;
            2)
                load_game
                is_with_computer=false
                play_game
                ;;
            3)
                board=(" " " " " " " " " " " " " " " " " " " ")
                current_player="X"
                is_with_computer=true
                play_game
                ;;
            4)
                load_game
                is_with_computer=true
                play_game
                ;;
            5)
                echo "Do widzenia!"
                break
                ;;
            *)
                echo "Nieprawidłowy wybór. Spróbuj ponownie."
                sleep 1
                ;;
        esac
    done
}

# Uruchomienie menu głównego
main_menu
