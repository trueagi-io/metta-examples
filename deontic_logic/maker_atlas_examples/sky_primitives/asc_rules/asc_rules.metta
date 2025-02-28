;ASC rules
;
;The ASC rules ensure that Stars all participate in
;maintaining the stability and peg of USDS.
;
;# Actively stabilizing collateral (ASC):
;
;ASC is collateral that is actively market making against USDS,
;supporting its peg and bidding at a price of at least 0.999 USD per USDS
;(10bps downside spread).
;
;ASC can be USDC and USDT in the PSM, curve, other stablecoins,
;or crypto assets, as long as it is enforced that they enable
;real time redemption of USDS at at least 0.999 USD per USDS.
;
;ASC can also be offchain as RWA loans to market makers,
;as long as there is clear public real time information about the exposure,
;proving that it is at all times used to provide buy support of at least
;0.999 USD per USDS
;
;If a Star doesn’t maintain at least 20% of its collateral portfolio in ASC,
;it will continuously be penalized at a rate of 200% APY on the missing ASC.
;This penalty is settled monthly at the settlement cycle, and retroactively
;calculated per second.
;
;# Demand Absorption Buffer
;
;Demand Absorption Buffer is a type of ASC consisting of USDS that is
;for sale for at most 1.001 USD per USDS. Every Star must maintain a DAB
;equivalent to 25% of their standard ASC requirement. USDS held by a Star is
;not considered a part of its collateral portfolio for the purposes of
;calculating ASC requirements. DAB requirements can also be fulfilled by
;autonomous systems that generate USDS dynamically through the allocation as
;needed.
;
;# Peg Defense Event
;
;A Peg Defense Event is a situation where the volume weighted average price
;of USDS on SkyLink enabled blockchains falls below 0.999 USD per USDS.
;
;In this situation, all Stars must immediately begin to buy USDS at
;a rate of at least 6.25% of their ASC requirement every 6 hours.
;
;If they fail to fulfill this requirement, a penalty of 20 bps on
;all missing buy volume is applied, calculated in finished blocks of
;6 hours from the Peg Defense Event begins, and settled retroactively at
;the monthly settlement cycle.
;
;Peg Defense can be performed both by selling other types of collateral for
;USDS, or by using USDS, or generating new USDS via the allocation system,
;that is then used as collateral on e.g. aave to borrow USDC or USDT and
;buy USDS with it.
;
;# ALM obligation transfer
;
;The ASC and Peg Defense obligation can be transfered against payment to
;a different Star, through the ALM obligation transfer system.
;Both ASC and Peg Defense responsibilities are transferred together,
;as they are tied together.

(= (asset usdt) 100)
(= (asset usds) 200)
(= (asset usdc) 300)

(= (apy-rate r1) 2)

(= (penalize $asset $rate)
     (let $res (/ $asset $rate)
     $res)
)

(= (stabilizing_collateral $asset $threshold $rate)
       (if(>= $asset $threshold)
        (penalize $asset $rate)
        False
       )
 )

(= (volume_weighted_average_price usdt) 1000)

;(bind! acc1 (usdt 100))
;(bind! acc2 (usdt 200))
;(bind! acc3 (usdt 300))
;
;(= (asset s1) (usdt 100))
;(= (asset s2) (usdt 200))
;(= (asset s3) (usdc 100))

(= (star_agent a1) s1)

!(bind! &acc1 (new-state (usdt 100)))

(= (asset s1) &acc1)

!(change-state! &acc1 (usdt 200))

(= (increase_by_quant $num $quant)
    (+ $num $quant)
)

(= (buy $agent $quant)
    (asset $agent)
)

(= (peg_defense_event $vwap $threshold $agent_list)
    (if(>= $vwap $threshold)
        (buy $asset )
       )
)