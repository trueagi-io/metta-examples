(room  "The Study")
(room  "The Hall")
(room  "The Lounge")
(room  "The Dining Room")
(room  "The Kitchen")
(room  "The Ballroom")
(room  "The Conservatory")
(room  "The Billiards Room")
(room  "The Library")


(character "Miss Scarlet")
(character "Professor Plum")
(character "Colonel Mustard")
(character "Mrs. Peacock")
(character "Reverand Green")
(character  "Mrs. White")



(weapon "candlestick")
(weapon  "dagger")
(weapon  "revolver")
(weapon "lead pipe")
(weapon "wrench")
(weapon "rope")


(player player1)
(player player2)
(player player3)
(player player4)


; state to store the value indicating that the card was checked
(= (new-state-value! $var_name $value)
                        (let $new-state (new-state $value)
                        (add-atom &self ((checked $var_name)  $new-state))

                        ))
;functions to get and set card state
(= (get-card-state-value $var_name)(match &self ((checked $var_name) $x)  (get-state $x) ))

(= (set-card-state-value $var_name $value) (change-state! (match &self ((checked $var_name) $x)  $x) $value))

; set all cards unchecked
!(match &self (character $t) (new-state-value! (character $t) False))
!(match &self (weapon $t) (new-state-value! (weapon $t) False))
!(match &self (room $t) (new-state-value! (room $t) False))



; state to store the value indicating that the player is not active
(= (new-state-value! $player $value)
                        (let $new-state (new-state $value)
                        (add-atom &self ((is_not_active $player)  $new-state))

                        ))
;functions to get and set player's state
(= (get-player-state-value $player)(match &self ((is_not_active $player)  $x)  (get-state $x) ))

(= (set-player-state-value $player $value) (change-state! (match &self ((is_not_active $player)  $x)  $x) $value))


;set all players active
!(match &self (player $t) (new-state-value! $t False))



; this is the solution of the problem:
;!(bind! &target (character "Colonel Mustard") (weapon   "dagger") (room  "The Ballroom"))


; distribute cards between players
(player1 (room  "The Hall"))
(player1 (character "Reverand Green"))
(player1  (weapon  "revolver"))
(player1  (character "Mrs. Peacock"))
(player1  (character "Miss Scarlet"))

(player2  (room  "The Kitchen"))
(player2  (room  "The Study"))
(player2  (room  "The Library"))
(player2  (character "Professor Plum"))
(player2  (weapon "rope"))

(player3  (room  "The Billiards Room"))
(player3  (weapon "wrench"))
(player3  (room  "The Conservatory"))
(player3  (room  "The Dining Room"))


(player4  (room  "The Lounge"))
(player4  (character  "Mrs. White"))
(player4  (weapon "lead pipe"))
(player4  (weapon "candlestick"))


(player1 left player2)
(player2 left player3)
(player3 left player4)
(player4 left player1)


;define variable to store (Sate False)
!(bind! &false (new-state False))



;one turn of the game

(= (process_accusation $player $room  $weapon $character $start_player)
    (if (== $start_player $player) win
         (case (match &self ($player left $next_player) $next_player)
            (
                ($next_player
                    (case (match &self ($next_player ($room_name $room)) $room_name)
                        (
                            (%void%
                                (case (match &self ($next_player ($weapon_name $weapon)) $weapon_name)
                                    (
                                        (%void%
                                            (case (match &self ($next_player ($character_name $character)) $character_name)
                                                (
                                                 (%void%     (if (== $start_player None )
                                                                (process_accusation $next_player $room  $weapon $character $player)
                                                                (process_accusation $next_player $room  $weapon $character $start_player)
                                                             ))
                                                 (character (set-card-state-value (character $character) True))
                                                )
                                            )
                                         )
                                        (weapon (set-card-state-value (weapon $weapon) True))
                                    )
                                )
                            )
                            (room (set-card-state-value (room $room) True))
                        )
                    )
                 )

                 (%void% ("There is no player" $player))
            )
        )
    )

)
;!(process_accusation player1 "The Study" "candlestick"  "Professor Plum" None)

; define state to store accusations and select one accusation from them
;--------------------------------------
!(let $test (new-state ())
    (add-atom &self ( = (test-state) $test) )
)

(= (set-test-state $val)
    (let() (change-state! (test-state) $val) (empty))
)

(= (get-test-state)
   (get-state (test-state))
)
;---------------------------------------


(= (get-accusation $player)

    (let ($r $w $c) (match &self (,
                    (character $c) ((checked (character $c)) &false)
                    (room $r) ((checked (room $r)) &false)
                    (weapon $w) ((checked (weapon $w)) &false)) ($r $w $c) )
        (case  (match &self ($player ($room_name $r)) $room_name)
            (
                ( %void%
                     (case (match &self ($player ($character_name $c)) $character_name)
                        (
                            (%void%
                                (case (match &self ($player ($weapon_name $w)) $weapon_name)
                                    (
                                        (%void%  ($r $w $c) )
                                    )
                                )
                            )
                        )

                    )
                )
            )
        )
    )
)



(= (process-game $player)
    (superpose
        (

            (set-test-state (get-accusation $player))
            (let ($r $w $c) (get-test-state)
                (superpose
                    (
                        (step $player , room $r ,  weapon $w , character $c)
                        (let $result (process_accusation $player $r  $w $c None)
                            (if ( == $result win)
                                ($player $r $w $c)
                                (let $x (match &self (,($player left $x) ((is_not_active $x) &false)) $x)
                                     (process-game $x)
                                )
                            )
                        )
                    )
                )
            )
        )
    )
)

!(process-game player1)

