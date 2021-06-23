// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.7.0;

contract TestingStorage{
    string variable;
    
//create a function to read this variable from storage 

function get() public view returns(string memory){
    return variable;
    
}

//sets the value of the variable from outside the smart contract 
function set(string memory _value) public{
    variable = _value;
}
//sets a default value for this variable
constructor () public{
    variable = "defaultValue";
}
}

/**************************/

contract SimplifyTestingStorage{
    string public variable = "defaultValue";
    
//sets the value of the variable from outside the smart contract 
function set(string memory _value) public{
    variable = _value;
}
}

/***************************/

contract CreatingDifferentStateVariables{
    
  bool public BoolVariable = true; //creates a boolean state variable that can be either true or false
  int public IntegerVariable = -100; //integers can be positive or negative 
  uint public UintegerVariable = 100; //unsigned integers can not be negative 
  uint256 public CanGoHighVariable = 9999999999999999999999999999999;
  uint8 public RestrictedVariable = 255; //this limits the value to 8 bits 
}

/************************/

contract EnumDataStructure{
    enum TimeOfTheDay { Morning, Afternoon, Evening }
    TimeOfTheDay public CurrentTime; //checks the current time of the day 
    
    constructor() public {
        CurrentTime = TimeOfTheDay.Morning; //sets the default time to morning (i.e. uint8: 0)
    }
    function lets_call_it_a_day() public {
        CurrentTime = TimeOfTheDay.Evening; //updates the current time to Evening (i.e. uint8: 2)
    }    
    function isEvening() public view returns(bool) {
        return CurrentTime == TimeOfTheDay.Evening; //should return true once we called it a day 
    }
}

/*************************/

contract PeopleStructandArray {
    
    Person[] public people; //this declares a people array in which the person struct is stored.
    
    //calling the people() function outside the smart contract will not return the entire array. Instead it will accept a zero-based index argument.
    //the first person in the people array can be accessed like this: people(0)


    uint256 public peopleCount; //serves as a counter cache i.e. to know how many people are inside the array
    
    struct Person { //this models a person with three different attributes.
        string _firstName;
        string _lastName;
        uint8 _age; //different data types can be specified in the same struct.
    }
    
    
    function addPerson (string  memory _firstName, string  memory _lastName, uint8 _age) public {
        people.push(Person(_firstName, _lastName, _age)); //adds the new person to the people array with the push function 
        peopleCount += 1; //increments the peopleCount variable by 1. Is one-based.
    }
}

/***************************/

contract PeopleStructandMapping {
    uint256 peopleCount = 0;
    
    mapping(uint => Person) public people; //mapping allows to store key-value pairs. It will store person structs and therefore replace the people array.
    
    //the key is an uint, the value is a person stuct. The key will be treated like a database id.
    
    struct Person { 
        uint _id; //uses the peopleCount counter cache to create an id for the person.
        string _firstName;
        string _lastName;
        uint8 _age;
    }
    
    function addPerson (string  memory _firstName, string  memory _lastName, uint8 _age) public {
        peopleCount += 1; //increments the peopleCount variable by 1.
        people[peopleCount] = Person(peopleCount, _firstName, _lastName, _age);
    }
}

/***********************/

contract VisibilityandModifier {
    uint256 public peopleCount = 0;
    
    mapping(uint => Person) public people; //mapping allows to store key-value pairs. It will store person structs and therefore replace the people array.
    
    //the key is an uint, the value is a person stuct. The key will be treated like a database id.
    
    address owner; //stores the owner of this smart contract 
    
    modifier onlyOwner() { //modifier allows to add a permission. This modifier will only allow an owner to call the addPerson() function.
       require(msg.sender == owner); //checks if the person calling the function is the owner.
       _;
    }
    
    struct Person { 
        uint _id; //uses the peopleCount counter cache to create an id for the person.
        string _firstName;
        string _lastName;
        uint8 _age;
    }
    
    constructor() public {
        owner = msg.sender; //sets the owner as the account that deploys the smart contract.
    }
    
    function addPerson (
        string  memory _firstName,
        string  memory _lastName, 
        uint8 _age
    )    
        
        public
        onlyOwner 
    {
        incrementCount(); //increments the peopleCount variable by 1 internally.
        people[peopleCount] = Person(peopleCount, _firstName, _lastName, _age);
        
    }
    
    function incrementCount() internal { //function is only accessible inside the smart contract, not by the public interface for other accounts.
        peopleCount +=1;
    }
}

/******************************/

contract TimeRestriction {
    uint256 public peopleCount = 0;
    
    mapping(uint => Person) public people; //mapping allows to store key-value pairs. It will store person structs and therefore replace the people array.
    
    //the key is an uint, the value is a person stuct. The key will be treated like a database id.
    
    uint256 startTime; //creates variable to store the startTime (in unix time).
    
    modifier onlyWhileOpen() { //checks that the current time on the blockchain is past the specified startTime.
        require(block.timestamp >= startTime); //restricts access to the addPerson() function until after the startTime.
        _;
    }
    
    
    struct Person { 
        uint _id; //uses the peopleCount counter cache to create an id for the person.
        string _firstName;
        string _lastName;
        uint8 _age;
    }
    
    constructor() public {
       startTime = 1624022971; //sets start time. Use https://www.unixtimestamp.com/ to generate a timestamp.
    }
    
    function addPerson (
        string  memory _firstName,
        string  memory _lastName, 
        uint8 _age
    )    
        
        public
        onlyWhileOpen 
    {
        incrementCount(); //increments the peopleCount variable by 1 internally.
        people[peopleCount] = Person(peopleCount, _firstName, _lastName, _age);
        
    }
    
    function incrementCount() internal { //function is only accessible inside the smart contract, not by the public interface for other accounts.
        peopleCount +=1;
    }
}

/************************/

contract PseudoICO {
    
    mapping(address => uint256) public balances; //creates mapping to track the token balances.
    
    event Purchase( //declares an event.
        address indexed _buyer, //the account calling the buyToken function. It is possible to filter events by using indexed.
        uint256 _amount //amount of tokens.
        );

    address payable mywallet; //declares the wallet where the ether funds will be sent whenever an account buys tokens.
    
        
    constructor(address payable _wallet) public {
        mywallet = _wallet;
    }
    
    fallback() external payable { //this function gets called anytime an account sends Ether to the smart contract.
        buyToken();
    }
    
    //public vs. external: public can be called inside as well as outside, external can only be called outside.
    
    function buyToken() public payable { //this function increments the balance of the person calling it.
        balances[msg.sender] += 1;
        mywallet.transfer(msg.value); //transfers the ether funds to mywallet. 
        emit Purchase(msg.sender, 1); //this triggers the event whenever a token gets purchased. Here _buyer is msg.sender and _amount is 1.
        }    
    }
    
    /**************************/
    
    contract PseudoERC20Token { //does not contain all the functionalities of a real ERC20 smart contract.
    string name;
    mapping(address => uint256) public balances;
    
    function mint() public {
        balances[tx.origin] += 1; //tx.origin will reference the account that originated the transaction, msg.sender would wrongly reference the address of the contract that called the buyToken() function.
    }
}


contract InteractingWithPseudoERC20Token {
    
    address payable mywallet; //declares the wallet where the ether funds will be sent whenever an account buys tokens.
    address public token; //stores the address of the token in a state variable.
        
    constructor(address payable _wallet, address _token) public {
        mywallet = _wallet;
        token = _token; //sets the value for the token address.
    }
    
    
    function buyToken() public payable {
        PseudoERC20Token(address(token)).mint(); //calls the mint function of the above contract.
        mywallet.transfer(msg.value); //transfers the ether funds to mywallet. 
       
        }    
    }
    
    /********************/
    
    //following code lines should exemplify how contract inheritance can work.

contract ParentToken { 
    string public name;
    mapping(address => uint256) public balances; //keeps track of the balances.
    
    constructor(string memory _name) public {
        name = _name;
    }
    
    function mint() public virtual {
        balances[tx.origin] += 1;
    }
}


contract ChildToken is ParentToken { //this contract inherits from the above contract while adding some more characteristics. 
    
    string public symbol;
    address[] public owners; //stores the address of all the token owners using an array.
    uint256 public ownerCount; //sets the count of all the owners.
    
    constructor(
        string memory _name, //overrides the name of the ParentToken.
        string memory _symbol //use inheritance to give it a unique symbol.
    )
        ParentToken(_name)      
    public {
        symbol = _symbol;
    }
    
    function mint() override public { //use inheritance to add some extra behavior to the mint() function.
        super.mint(); //preserves the behavior of the above mint() function (i.e. update the balances).
        ownerCount ++; //increments the number of people who own the token.
        owners.push(msg.sender); //adds the new owner to the array of owners.
    }
}

/***************************/

//using libraries and math. libraries are used to manage math functions.
//libraries are ment to be used inside smart contracts.

library Math { //declares the library. this library prevents the "divide by zero error" by stopping the function before.
    function divide(uint256 a, uint256 b) internal pure returns (uint256) { //defines a function inside the library.
        require(b > 0); //makes sure the denominator is greater than zero.
        uint256 c = a / b;
        return c;
        
    }
}

contract DoSomeMath {
    uint256 public value; //stores a value.
    
    function compute(uint _number1, uint _number2) public { //computes the value.
        value = Math.divide(_number1, _number2); //imorts the divide function from the above created library.
    
    }
}

/***********************/

//his is to test the delegatecall function

contract B {
    // NOTE: storage layout must be the same as contract A
    uint public num;
    address public sender;
    uint public value;

    function setVars(uint _num) public payable {
        num = _num;
        sender = msg.sender;
        value = msg.value;
    }
}

contract B2 {
    // NOTE: storage layout must be the same as contract A
    uint public num;
    address public sender;
    uint public value;

    function setVars(uint _num) public payable {
        num = 2 * _num; //this will multiply the input by 2 and store the result inside contract A.
        sender = msg.sender;
        value = msg.value;
    }
}

contract A {
    uint public num;
    address public sender;
    uint public value;

    function setVars(address _contract, uint _num) public payable {
        (bool success, bytes memory data) = _contract.delegatecall( //delegatecall makes it possible to update this contract without changing code inside of it.
            abi.encodeWithSignature("setVars(uint256)", _num)
        );
    }
}
