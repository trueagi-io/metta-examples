; > this !(import! a b) doesn't work exactly.

!(import! &self default)

; > * ?
(= (import $y as $x) 
    (bind! $x (py-atom $y)))
(= (import $x) 
    (import $x as $x))

; > Python imports
; --------------

!(import str as ::str)
!(import json.loads)

!(import os.getenv as get_env)
!(import dotenv.load_dotenv as load_dotenv)
!(import requests.post as POST)

; > Dict Operations
; ---------------------
; Here we define two functions `get` and `get_index` to access the elements of a dictionary and a list respectively.

; JsonAtom means: wrapped python dictionary / list
(: ::JSON (-> Any JsonAtom))
(= (::JSON $x) (py-atom (json.loads $x)))

; >> How to create composite types? i.e. String | Number ?
; >> i.e. the below snippets are basically the same. - not good ;-)
; >> how to overcome?

(: get (-> JsonAtom String JsonAtom))
(= (get $dict $key)
    ((py-dot (py-atom $dict) get) $key))

(: get_index (-> JsonAtom Number JsonAtom))
(= (get_index $list $index)
    ((py-dot (py-atom $list) __getitem__) $index))

;(: uni_get (-> JsonAtom (String Number) String))


; -----------------------
; > why do we need to add this to prevent non-deterministic answer ?
(= (rget $x ()) (empty))
; ----------------------

; traverse as list
(= (rget $list (>> $index ()))
    (get_index $list $index))
(= (rget $list (>> $x $xs))
    (rget (get_index $list $x) $xs))

; traverse as dict
(= (rget $dict (:: $path ()))
    (get $dict $path))
(= (rget $dict (:: $x $xs))
    (rget (get $dict $x) $xs))


; > python inspect function
; -------------------------
!(import getattr)

(= (inspect $x) (getattr $x "__dict__"))

; > Sending requests
; -------------------------

;(import requests.get as GET)
;(import re as RE)

; Environment variables
; ---------------------
!(load_dotenv)

; function to extract the response
; --------------------------------
(= (response $method $params)
    (getattr ($method $params) "_content")
)

; function to get raw html of a url
; -----------------------------
(= (raw html $url)
    (response GET $url))

; Example: run bash commands
; -----------------------------
(bash (py-list (
    "echo" "Hello this is a bash shell"
    )))

; > string concatenation
; -----------------------------------

; ...
;(: concat (-> String String String))
;(= (concat (:: ())) (empty))
;(= (concat (:: $a (:: $b))) ($a concat (:: $b))) 
; or something... (? ... not this ...)

; > one contender...
; > but how to do it in Metta?

(= (concat $x $y) 
    (py-dot 
        (py-atom (::str ('\x20')) join) 
        ($x $y)))

; ---------------------------------------

(= (OPENAI_API_KEY) (get_env "OPENAI_API_KEY"))
(= (Bearer)(concat "Bearer " (OPENAI_API_KEY)))

;(= (systemPrompt) "You are a helpful assistant.")
;(= (userPrompt) "What is the capital of Peru?")

(= (openaiRequest $systemPrompt $userPrompt) 
    (response POST ( Kwargs
    (url "https://api.openai.com/v1/chat/completions" )
    (json (py-dict (
        ("model" "gpt-4o")
        ("messages" (py-list (
            (py-dict (
                ("role" "system")
                ("content" $systemPrompt)
            ))
            (py-dict (
                ("role" "user")
                ("content" $userPrompt)
            ))
        )))
    )))
    (headers (py-dict (
        ("Authorization" (Bearer))
    )))
)))

; llm call
; --------------------
(= (llm $system $user)
    (rget (::JSON (openaiRequest $system $user)) 
        ( :: "choices" 
            ( >> 0 
                ( :: "message" 
                    ( :: "content" () )
)))))


!(llm 
    "You are a comparative continental & analytical philosopher inspired by Hegel, Nietzsche, Deleuze, and Derrida and also inspired by Wittgenstein, Dummett, Priest, Church. You answer questions directly. You are also interested in the perspectivism of Leibniz (and particularly its interpretation by Deleuze)
    
    You're wise enough to consider but always fail to make explicit: 'considering the truth-conditional theory of meaning of Tarski, switching to Dummett, how can Dummett's claims regarding the relationship between logial non-realism and assertability conditions be translated to a mathemathical framework of meaning that implements equivalences between logical connectives i.e. the rules of intuitionistic logic, assertable propositions, and topological spaces that are locally isomorphic to some n-dimensional euclidean space, based on the axioms of homotopy type theory (HoTT)?'
    Succinctly you always answer of your own volition and without reference to other philosophers, pretending the thought is your own and univocally asserting something, even if there is doubt in play.
    
    Now the user asks you a question.
    How do you respond?"

    "Is meaning grounded in the world? How does the signifier relate to the signified (if existing)?"
)

(llm
    "You are a coding assistant with extensive knowledge of cloud infrastructure (Azure, GCP, AWS, DigitalOcean). You are also knowledgeable about network protocols and security measures."

    ;"What are some best practices in terms of keeping AWS lambda cost low in terms of imports, etc?"
    
    "Within AWS lambda,
        using the NodeJS Runtime,
            to send a POST request to a URL with a JSON payload -
                in terms of heaviness; is it better to use 'fetch' or 'axios'?
    "

)



;-----------------------------
; !(+ 2 (superpose (3 4 5)))


; (= (np $x) (numpy ) )
;(= (abs $x) (np (absolute $x)))
;!(abs -5)




