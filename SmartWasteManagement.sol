// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SmartWasteManagement {
    address public owner; // Contract owner's address
    uint public transactionCount; // Total number of waste transactions

    enum WasteType { Organic, NonBiodegradable }

    // Structure to represent a waste transaction
    struct WasteTransaction {
        uint transactionId;
        address sender;
        WasteType wasteType;
        uint quantity;
        string location;
        string description;
        uint timestamp;
        bool disputed;
    }

    // Mapping to store waste transactions
    mapping(uint => WasteTransaction) public wasteTransactions;

    // Mapping to store user balances in digital coupons
    mapping(address => uint) public userBalances;

    // Mapping to store user transaction history
    mapping(address => uint[]) public userTransactionHistory;

    // Mapping to store fines and their dispute status
    mapping(address => uint) public fines;
    mapping(address => bool) public fineDisputed;

    // Event to log waste transactions
    event WasteTransactionRecorded(uint indexed transactionId, address indexed sender, WasteType wasteType, uint quantity, string location, string description, uint timestamp);

    // Event to log fine imposition
    event FineImposed(address indexed user, uint fineAmount);

    // Event to log digital coupon distribution
    event DigitalCouponIssued(address indexed user, uint couponAmount);

    // Event to log fine dispute resolution
    event FineDisputed(address indexed user, uint fineAmount);

    // Modifiers
    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function");
        _;
    }

    // Constructor
    constructor() {
        owner = msg.sender;
    }

    // Function to record waste transactions
    function recordWasteTransaction(WasteType _wasteType, uint _quantity, string memory _location, string memory _description) public {
        require(_quantity > 0, "Quantity must be greater than zero");

        // Increment transaction count
        transactionCount++;

        // Create a new waste transaction
        WasteTransaction memory newTransaction = WasteTransaction({
            transactionId: transactionCount,
            sender: msg.sender,
            wasteType: _wasteType,
            quantity: _quantity,
            location: _location,
            description: _description,
            timestamp: block.timestamp,
            disputed: false
        });

        // Store the transaction in the mapping
        wasteTransactions[transactionCount] = newTransaction;
        userTransactionHistory[msg.sender].push(transactionCount);

        // Emit the event
        emit WasteTransactionRecorded(transactionCount, msg.sender, _wasteType, _quantity, _location, _description, block.timestamp);

        // Issue digital coupons as an incentive (simplified example)
        uint couponAmount = calculateCouponAmount(_wasteType, _quantity);
        if (couponAmount > 0) {
            userBalances[msg.sender] += couponAmount;
            emit DigitalCouponIssued(msg.sender, couponAmount);
        }
    }

    // Function to impose a fine (onlyOwner can call this function)
    function imposeFine(address _user, uint _fineAmount) public onlyOwner {
        require(_fineAmount > 0, "Fine amount must be greater than zero");

        // Implement fine imposition logic (e.g., transfer tokens to a specific account)
        fines[_user] += _fineAmount;

        // Emit the event
        emit FineImposed(_user, _fineAmount);
    }

    // Function to dispute a fine
    function disputeFine() public {
        require(fines[msg.sender] > 0, "No fines to dispute");

        fineDisputed[msg.sender] = true;

        // Emit the event
        emit FineDisputed(msg.sender, fines[msg.sender]);
    }

    // Function to resolve a disputed fine (onlyOwner can call this function)
    function resolveFine(address _user, uint _fineAmount) public onlyOwner {
        require(fineDisputed[_user], "Fine is not disputed");
        require(fines[_user] >= _fineAmount, "Fine amount exceeds disputed amount");

        // Transfer fine amount to owner
        fines[_user] -= _fineAmount;
        // Resolve dispute
        fineDisputed[_user] = false;

        // Emit the event
        emit FineImposed(_user, _fineAmount);
    }

    // Function to check user's digital coupon balance
    function getUserBalance() public view returns (uint) {
        return userBalances[msg.sender];
    }

    // Internal function to calculate coupon amount based on waste type and quantity
    function calculateCouponAmount(WasteType _wasteType, uint _quantity) internal pure returns (uint) {
        // Simplified logic - adjust based on your requirements
        if (_wasteType == WasteType.Organic) {
            return _quantity * 2; // 2 coupons per unit for organic waste
        } else {
            return _quantity * 3; // 3 coupons per unit for non-biodegradable waste
        }
    }

    // Function to get user's transaction history
    function getUserTransactionHistory() public view returns (uint[] memory) {
        return userTransactionHistory[msg.sender];
    }
}

