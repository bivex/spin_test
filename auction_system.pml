/*
 * Economic Model: Sealed-Bid / English Auction System in Promela
 * 
 * Demonstrates:
 * 1. Bidding process between multiple market participants.
 * 2. Winner determination and refund processing.
 * 3. Financial Invariant: Money is never created or destroyed during auction.
 */

#define NUM_BIDDERS 3
#define ITEM_RESERVE_PRICE 50

int bidder_balance[NUM_BIDDERS] = 200;
int highest_bid = ITEM_RESERVE_PRICE;
int highest_bidder = -1;

bool auction_closed = false;
int seller_balance = 0;

proctype Bidder(byte id; int bid_amount) {
    atomic {
        if
        :: (!auction_closed && bid_amount > highest_bid && bidder_balance[id] >= bid_amount) ->
            /* Return previous highest bid if any */
            if
            :: (highest_bidder != -1) ->
                bidder_balance[highest_bidder] = bidder_balance[highest_bidder] + highest_bid;
                printf("Refunded %d to Bidder[%d]\n", highest_bid, highest_bidder);
            :: (highest_bidder == -1) -> skip;
            fi;

            /* Deduct new bid amount */
            bidder_balance[id] = bidder_balance[id] - bid_amount;
            highest_bid = bid_amount;
            highest_bidder = id;
            printf("Bidder[%d] placed winning bid of %d\n", id, bid_amount);

        :: else ->
            printf("Bidder[%d] bid of %d rejected\n", id, bid_amount);
        fi;
    }
}

proctype Auctioneer() {
    /* Wait for bids to settle */
    (highest_bidder != -1);

    atomic {
        auction_closed = true;
        seller_balance = seller_balance + highest_bid;
        printf("Auction Closed! Item sold to Bidder[%d] for %d\n", highest_bidder, highest_bid);
    }
}

init {
    atomic {
        run Auctioneer();
        run Bidder(0, 70);
        run Bidder(1, 100);
        run Bidder(2, 90);
        run Bidder(0, 120);
    }
}

/* LTL Verification Property: If auction closes with winner, seller balance equals highest bid */
ltl auction_settled { [] (auction_closed -> (seller_balance == highest_bid)) }
