pragma solidity >=0.5.0 < 0.9.0;

contract ItemManager{


    enum SupplyChainState{ Created , Paid, Delivered }

    struct item {
        string identifer ;
        uint amount;
        ItemManager.SupplyChainState _state;

    }

    mapping(uint => item) public items;
    uint itemIndex;

    event SupplyChainStep(uint _itemIndex,uint _step);


    function createItem(string memory _identifier , uint _price) public  {
        items[itemIndex].identifer = _identifier;
        items[itemIndex].amount = _price;
        items[itemIndex]._state = SupplyChainState.Created;
        emit SupplyChainStep(itemIndex, uint(items[itemIndex]._state));
        itemIndex++;

    }

    function triggerPayemnt(uint _itemIndex)  public payable {
        require(items[_itemIndex].amount == msg.value , "Only full payments accepted");
        require(items[_itemIndex]._state == SupplyChainState.Created, "Item is not created yet");
        
        items[_itemIndex]._state = SupplyChainState.Paid;
        emit SupplyChainStep(_itemIndex, uint(items[_itemIndex]._state));

    }


    function triggerDelivery(uint _itemIndex) public {

        require(items[_itemIndex]._state == SupplyChainState.Paid,"Item is further in the chain");
        items[_itemIndex]._state = SupplyChainState.Delivered;
          emit SupplyChainStep(_itemIndex, uint(items[_itemIndex]._state)); 


    }
}