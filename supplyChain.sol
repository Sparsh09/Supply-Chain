pragma solidity >=0.5.0 < 0.9.0;


contract Ownable {
    address payable owner;
    constructor () {
        owner = payable(msg.sender);
    }

    modifier onlyOwner() {
        require(isOwner(), "You are not the owner");
        _;
    }

    function isOwner() public view returns(bool){
        return (msg.sender == owner); 
    }
}


contract Item {
    uint public priceInWei;
    uint public index;
    uint public pricePaid;
    ItemManager parentContract;
    
    constructor(ItemManager _parentContract , uint _priceInWei, uint _index) {
        priceInWei = _priceInWei;
        index = _index;
        parentContract = _parentContract;
    }
    receive() external payable{
        require(pricePaid == 0, "Item is already paid");
        require(priceInWei == msg.value , "Only full payements is required");
        pricePaid += msg.value;
       (bool success, ) = address(parentContract).call{value:msg.value}(abi.encodeWithSignature("triggerPayemnt(uint256)",index));
       require(success , "The transaction wasnot successful, cancelling");
    }
    fallback() external {}
}

contract ItemManager is Ownable{
    enum SupplyChainState{ Created , Paid, Delivered }

    struct item {
        Item _item;
        string identifer ;
        uint amount;
        ItemManager.SupplyChainState _state;
    }

    mapping(uint => item) public items;
    uint itemIndex;
    event SupplyChainStep(uint _itemIndex,uint _step, address _itemAddress);


    function createItem(string memory _identifier , uint _price) public onlyOwner{
        Item nitem = new Item(this, _price, itemIndex);
        items[itemIndex]._item = nitem;
        items[itemIndex].identifer = _identifier;
        items[itemIndex].amount = _price;
        items[itemIndex]._state = SupplyChainState.Created;
        emit SupplyChainStep(itemIndex, uint(items[itemIndex]._state), address(nitem));
        itemIndex++;
    }

    function triggerPayemnt(uint _itemIndex)  public payable {
        require(items[_itemIndex].amount == msg.value , "Only full payments accepted");
        require(items[_itemIndex]._state == SupplyChainState.Created, "Item is not created yet");
        items[_itemIndex]._state = SupplyChainState.Paid;
        emit SupplyChainStep(_itemIndex, uint(items[_itemIndex]._state), address(items[_itemIndex]._item));
    }


    function triggerDelivery(uint _itemIndex) public onlyOwner{
        require(items[_itemIndex]._state == SupplyChainState.Paid,"Item is further in the chain");
        items[_itemIndex]._state = SupplyChainState.Delivered;
        emit SupplyChainStep(_itemIndex, uint(items[_itemIndex]._state), address(items[_itemIndex]._item));
    }
}