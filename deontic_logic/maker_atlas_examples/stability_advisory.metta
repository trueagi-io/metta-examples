;https://mips.makerdao.com/mips/details/MIP104#1-1-1-4

;1.1.1.5: Stability Advisory Council Requirements
;1.1.1.5.1
;Stability Advisory Council members can be individuals,
;groups of people, legal entities, or companies.
;They can be pseudonymous or known entities.
;Stability Advisory Council members must be aligned with
;the long-term goals of MakerDAO Endgame.
;
;1.1.1.5.2
;Desired competencies for members of the Stability Advisory Council,
;as many of the following as possible:
;
;Expertise in capital markets, bonds, equities.
;Experience as a market analyst or economist.
;Expertise in tokenomics.
;Expertise in fund management and risk profiles.
;Deep knowledge of decentralized collateral accounting and finance.
;Experience in credit risk, market risk, liquidity risk, and operational risk.
;Deep understanding of principles of portfolio construction, asset allocation,
;diversification strategies, and performance measurement.
;Experience in smart contract and DeFi risk management.
;Experience in economic modeling of high-volatility portfolios.
;Expertise in Value at Risk analysis with detailed knowledge about
;the limitations of the method.

;(= (council-member m1) True)
;(= (council-member m2) True)
;(= (council-member m3) True)
;(= (council-member m4) True)
;(= (council-member m5) True)

;(being m1 individual)
;(being m2 group)
;(being m3 legal-entity)
;(being m4 company)
;(being m5 government)

(= (individual m1) True)
(= (group m2) True)
(= (legal-entity m3) True)
(= (company m4) True)
(= (government m5) True)

;(= (permissible (council-member $m))
;    (or (unify (being $m $r) (being $s individual)
;     True False)
;     (or (unify (being $m $r) (being $s group)
;     True False)
;     (or (unify (being $m $r) (being $s legal-entity)
;     True False)
;     (unify (being $m $r) (being $s company)
;     True False)))))

(= (permissible (council-member $m))
    (or (== (individual $m) True)
     (or (== (group $m) True)
     (or (== (legal-entity $m) True)
     (== (company $m) True)))))


;!(permissible (council-member m1))
;!(permissible (council-member m5))

(= (permissible economics) True)
(= (permissible capital-markets) True)
(= (permissible tokenomics) True)
(= (permissible credit-risk) True)
(= (permissible portfolio-construction) True)


(= (economics m1) True)
(= (capital-markets m2) True)
(= (tokenomics m3) True)
(= (credit-risk m4) True)
(= (portfolio-construction m5) True)

(= (tokenomics m1) True)

(= (permissible (experience $e $m))
    (and (== ($e $m) True)
     (== (permissible $e) True)))


(= (omissible (experience $e $m))
    (unify ($e $m) ($s $m) True False))

;How to do that one of the experience types became optional?
;m1 has both economics and tokenomics
;E.g. we want to call !(optional (experience economics m1)) and get true


(= (optional (experience $e $m))
    (and (permissible (experience $e $m))
    (omissible (experience $e $m))))


;!(unify (economics m1) (tokenomics m1) True False)

!(permissible (experience chill m1))
