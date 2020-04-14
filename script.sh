#!/bin/bash

# Name: Dimitri Russell
# ID #: 1801488

# Before running make certain that the data.txt file is in the same directory as the script.sh file
# Then run the command 'bash script.sh'


getWinningNumbers(){
    winningNumbers[0]=$(shuf -i 1-35 -n 1)

    for(( i=1; i<5; i++ ))
    do
        winningNumbers[i]=$(shuf -i 1-35 -n 1)
            
        flag=1
        while [ "$flag" == 1 ]; do
            for (( j=0; j<=i-1; j++ )); do
                if [ ${winningNumbers[i]} == ${winningNumbers[j]} ]; then
                    winningNumbers[i]=$(shuf -i 1-35 -n 1)
                    break
                else
                   flag=2
                fi
            done 
        done
    done
    winningBonusBall=$(shuf -i 1-10 -n 1)
}

getPlayerNumbers(){
    if [ $choice == 1 ]; then
        playerNumbers[0]=$(shuf -i 1-35 -n 1)

        for(( i=1; i<5; i++ ))
        do
            playerNumbers[i]=$(shuf -i 1-35 -n 1)
            
            flag=1
            while [ "$flag" == 1 ]; do
                for (( j=0; j<=i-1; j++ )); do
                    if [ ${playerNumbers[i]} == ${playerNumbers[j]} ]; then
                        playerNumbers[i]=$(shuf -i 1-35 -n 1)
                        break
                    else
                        flag=2
                    fi
                done 
            done
        done
        bonusBall=$(shuf -i 1-10 -n 1)
    
    else
        printf "\nEnter 5 numbers in range 1-35\n\n"
        for (( i=0; i<5; i++ )); do
            read -p "Number $(($i+1)) : " playerNumbers[i]
            
            while ! [[ ${playerNumbers[i]} =~ ^[0-9]+$ ]] || [ ${playerNumbers[i]} -gt 35 ] || [ ${playerNumbers[i]} -lt 1 ]; do
                read -p "ERROR: Must be integer in range 1-35, Re-enter value : " playerNumbers[i]
            done

            if [ $i == 0 ]; then 
                continue 
            fi

            flag=1
            while [ $flag == 1 ]; do
                for (( j=0; j<=i-1; j++ )); do
                    if [ ${playerNumbers[i]} == ${playerNumbers[j]} ]; then
                        read -p "ERROR: No number should repeat, Re-enter value : " playerNumbers[i]
                        
                        while ! [[ ${playerNumbers[i]} =~ ^[0-9]+$ ]] || [ ${playerNumbers[i]} -gt 35 ] || [ ${playerNumbers[i]} -lt 1 ]; do
                            read -p "ERROR: Must be integer in range 1-35, Re-enter value : " playerNumbers[i]
                        done

                        break
                    else
                        flag=2
                    fi
                done 
            done
        done
        printf "\nEnter bonus ball number(1-10) : "
        read bonusBall
        while ! [[ ${bonusBall} =~ ^[0-9]+$ ]] || [ ${bonusBall} -gt 10 ] || [ ${bonusBall} -lt 1 ]; do
            read -p "ERROR: Must be integer in range 1-10, Re-enter value : " bonusBall
        done    
    fi
}

calculateWinnings(){
    full=$(($play*100000+$jackpot))
    case ${match[0]} in

    5)
        if [ ${match[1]} == 1 ]; then
            if [ $bettingAmount == 300 ]; then
                winnings=$full
            else
                winnings=$(($full*2/3))
            fi
        else
            if [ $bettingAmount == 300 ]; then
                winnings=2200000
            else
                winnings=1450000
            fi
        fi
        ;;
    4)
        if [ ${match[1]} == 1 ]; then
            if [ $bettingAmount == 300 ]; then
                winnings=120000
            else
                winnings=80000
            fi
        else
            if [ $bettingAmount == 300 ]; then
                winnings=15000
            else
                winnings=10000
            fi
        fi
        ;;
    3)
        if [ ${match[1]} == 1 ]; then
            if [ $bettingAmount == 300 ]; then
                winnings=4000
            else
                winnings=2600
            fi
        else
            if [ $bettingAmount == 300 ]; then
                winnings=600
            else
                winnings=400
            fi
        fi
        ;;
    *)
        winnings=0
        ;;
    esac
}

loadFile(){
    while read p p2
    do
        jackpot=$p  
        play=$p2
    done < data.txt
}

saveFile(){
    echo $jackpot" "$play > data.txt
}


menu(){
    printf "**************************************\n"
    printf "*                                    *\n"
    printf "*        C.O.N LOTTORY SYSTEM        *\n"
    printf "*                                    *\n"
    printf "**************************************\n\n"
    
    read -p "Enter betting amount (300jm or 200jm) : " bettingAmount
    while [ $bettingAmount != 200 ] && [ $bettingAmount != 300 ]; do
        read -p "ERROR: Bet can only be 300 or 200, Re-enter amount : " bettingAmount
    done

    printf "\n\nHow do you wish to generate your numbers?"
    printf "\n1.Computer generated"
    printf "\n2.Manual entry\n"

    read -p "Enter the number beside your choice : " choice

    while [ $choice != 1 ] && [ $choice != 2 ]; do
        read -p "ERROR: Invalid, Re-enter choice : " choice
    done
}

main(){
    loadFile
    menu
    getPlayerNumbers
    getWinningNumbers

    clear

    printf "\n-------------------\n| WINNING NUMBERS |\n-------------------\n"
    for(( i=0; i<5; i++ )) do
        printf "${winningNumbers[i]} "
    done   
    printf "\nBonus Ball : $winningBonusBall\n"

    printf "\n------------------\n| PLAYER NUMBERS |\n------------------\n"
    for(( i=0; i<5; i++ )) do
        printf "${playerNumbers[i]} "
    done       
    printf "\nBonus Ball : $bonusBall\n"

    match[0]=0
    match[1]=0
    for(( i=0; i<5; i++ )) do
        for(( j=0; j<5; j++ )) do
            if [ ${playerNumbers[i]} == ${winningNumbers[j]} ]; then
                match[0]=$((${match[0]}+1))
            fi
        done  
    done  
    if [ $bonusBall == $winningBonusBall ]; then
        match[1]=1
    fi

    calculateWinnings

    printf "\n\n*************************\n"
    printf "*       WINNINGS        *\n"
    printf "*************************\n"
    printf "\t$winnings\n\n"

    if [ $winnings == 0 ]; then
        printf "...Better luck next time\n"
    else
        printf "!!! CONGRATULATIONS !!!\n"
    fi

    play=$(($play+1))
    saveFile
}

playerNumbers=()
winningNumbers=()

bonusBall=0
winningBonusBall=0

match=()
winnings=0
jackpot=0
play=0

bettingAmount=0
choice=0

main
