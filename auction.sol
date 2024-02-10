pragma solidity ^0.4.17;

contract Auction {
    struct Item {
        uint256 itemId;
        uint256[] itemTokens;
    }

    struct Person {
        uint256 remainingTokens;
        uint256 personId;
        address addr;
    }

    mapping(address => Person) tokenDetails;
    Person[4] bidders;

    Item[3] public items;
    address[3] public winners;
    address public beneficiary;

    uint256 bidderCount = 0;

    modifier OnlyOwner {
        require(msg.sender == beneficiary);
        _;
    }

    function Auction() public payable {
        beneficiary = msg.sender;
        uint256[] memory emptyArray;
        items[0] = Item({itemId: 0, itemTokens: emptyArray});
        items[1] = Item({itemId: 1, itemTokens: emptyArray});
        items[2] = Item({itemId: 2, itemTokens: emptyArray});
    }

    function register() public payable {
        bidders[bidderCount].personId = bidderCount;

        bidders[bidderCount].addr = msg.sender;
        bidders[bidderCount].remainingTokens = 5; 
        tokenDetails[msg.sender] = bidders[bidderCount];
        bidderCount++;
    }

    function bid(uint256 _itemId, uint256 _count) public payable {
        require(tokenDetails[msg.sender].remainingTokens > 0);
        require(tokenDetails[msg.sender].remainingTokens >= _count);
        require(_itemId <= 2);

        tokenDetails[msg.sender].remainingTokens =
            tokenDetails[msg.sender].remainingTokens -
            _count;
        bidders[tokenDetails[msg.sender].personId]
            .remainingTokens = tokenDetails[msg.sender].remainingTokens;
        Item storage bidItem = items[_itemId];

        for (uint256 i = 0; i < _count; i++) {
            bidItem.itemTokens.push(tokenDetails[msg.sender].personId);
        }
    }

    function revealWinners() public OnlyOwner {
        for (uint256 id = 0; id < 3; id++) {
            Item storage currentItem = items[id];
            if (currentItem.itemTokens.length != 0) {
                uint256 randomIndex = (block.number /
                    currentItem.itemTokens.length) %
                    currentItem.itemTokens.length;
                uint256 winnerId = currentItem.itemTokens[randomIndex];

                winners[id] = bidders[winnerId].addr;
            }
        }
    }

    function getPersonDetails(uint256 id)
        public
        constant
        returns (
            uint256,
            uint256,
            address
        )
    {
        return (
            bidders[id].remainingTokens,
            bidders[id].personId,
            bidders[id].addr
        );
    }
}
