pragma solidity 0.4.20;

/*
Group:

Basil Abushama -- bshama@berkeley.edu -- 3031845454
Uriel Rodriguez -- urodriguezg@berkeley.edu -- 24484915

*/

contract Betting {

    /* Constructor function, where owner and outcomes are set */
    function Betting(uint[] _outcomes) public {
        for (uint i=0; i<_outcomes.length; i++){
            outcomes[i] = _outcomes[i];
        }
        owner = msg.sender;
    }

    /* Fallback function */
    function() public payable {
        revert();
    }

    /* Standard state variables */
    address public owner;
    address public gamblerA;
    address public gamblerB;
    address public oracle;

    /* Structs are custom data structures with self-defined parameters */
    struct Bet {
        uint outcome;
        uint amount;
        bool initialized;
    }

    /* Keep track of every gambler's bet */
    mapping (address => Bet) bets;
    /* Keep track of every player's winnings (if any) */
    mapping (address => uint) winnings;
    /* Keep track of all outcomes (maps index to numerical outcome) */
    mapping (uint => uint) public outcomes;

    /* Add any events you think are necessary */
    event BetMade(address gambler);
    event BetClosed();

    /* Uh Oh, what are these? */
    modifier ownerOnly() {
        if (msg.sender != owner) {
            throw;
        }
        _;
    }
    modifier oracleOnly() {
        if (msg.sender != oracle) {
            throw;
        }
        _;
    }
    modifier outcomeExists(uint outcome) {
        if (outcomes[outcome] == 0) {
            throw;
        }
        _;
    }

    /* Owner chooses their trusted Oracle */
    function chooseOracle(address _oracle) public ownerOnly() returns (address) {
        oracle = _oracle;
        return oracle;
    }

    /* Gamblers place their bets, preferably after calling checkOutcomes */
    function makeBet(uint _outcome) public payable returns (bool) {
        if (gamblerA != 0 && gamblerB != 0) {
            throw;
        }
        else if (gamblerA == 0) {
            gamblerA = msg.sender;
            bets[gamblerA] = Bet(_outcome, msg.value, true);
            BetMade(gamblerA);
            BetClosed();
        }
        else {
            gamblerB = msg.sender;
            bets[gamblerB] = Bet(_outcome, msg.value, true);
            BetMade(gamblerB);
            BetClosed();
        }
    }

    /* The oracle chooses which outcome wins */
    function makeDecision(uint _outcome) public oracleOnly() outcomeExists(_outcome) {
        if (_outcome == bets[gamblerA].outcome && _outcome != bets[gamblerB].outcome) {
            winnings[gamblerA] += bets[gamblerA].amount;
            winnings[gamblerA] += bets[gamblerB].amount;
        }
        else if (_outcome != bets[gamblerA].outcome && _outcome == bets[gamblerB].outcome) {
            winnings[gamblerB] += bets[gamblerA].amount;
            winnings[gamblerB] += bets[gamblerB].amount;
        }
        else if (_outcome == bets[gamblerA].outcome && _outcome == bets[gamblerB].outcome) {
            winnings[gamblerA] += bets[gamblerA].amount;
            winnings[gamblerB] += bets[gamblerB].amount;
        }
        else {
            winnings[gamblerA] += 0;
            winnings[gamblerB] += 0;
        }
    }

    /* Allow anyone to withdraw their winnings safely (if they have enough) */
    function withdraw(uint withdrawAmount) public returns (uint) {
        if (winnings[msg.sender] >= withdrawAmount) {
            winnings[msg.sender] -= withdrawAmount;
            if (!msg.sender.send(withdrawAmount)) {
                winnings[msg.sender] += withdrawAmount;
            }
        }
        return winnings[msg.sender];
    }

    /* Allow anyone to check the outcomes they can bet on */
    function checkOutcomes(uint outcome) public view returns (uint) {
        return outcomes[outcome];
    }

    /* Allow anyone to check if they won any bets */
    function checkWinnings() public view returns(uint) {
        return winnings[msg.sender];
    }

    /* Call delete() to reset certain state variables. Which ones? That's upto you to decide */
    function contractReset() public ownerOnly() {
        delete owner;
        delete gamblerA;
        delete gamblerB;
        delete oracle;
    }
}
