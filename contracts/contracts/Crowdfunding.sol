// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.7.0 <0.9.0;

contract Crowdfunding {

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;  
    }


    // events
    event CampaignCreated(address indexed creator, uint256 indexed campaignId, uint256 targetAmount, uint256 deadline);
    event Donated(address indexed donor, uint256 indexed campaignId, uint256 amount);
    event CampaignEnded(uint256 indexed campaignId);

    // struct for a campaign
    struct Campaign {
        uint id;
        string title;
        string description;
        address benefactor;
        uint256 goal;
        uint256 deadline;
        uint256 amountRaised;
        bool ended;
    }
    mapping(address => Campaign) public campaigns;

    address public owner;

    uint256 public nextCampaignId;


    // constructor that sets the owner
    constructor() {
        owner = msg.sender;
    }


    // function that creates a campaign
    function create_campaign(string memory _title, string memory _description, uint _goal, uint _deadline) public {
        require(msg.sender != owner, "Owner cannot create a campaign");
        require(campaigns[msg.sender].benefactor != msg.sender, "Cannot create more than one campaign");

        Campaign memory newCampaign = Campaign({
            id: nextCampaignId,
            title: _title,
            description: _description,
            benefactor: msg.sender,
            goal: _goal,
            deadline: _deadline,
            amountRaised: 0,
            ended: true
        });
        campaigns[msg.sender] = newCampaign;
        nextCampaignId++;     

    }

    // function that donates to a campaign
    function donate_campaign(uint _id) public payable {
        
        

        require(campaigns[msg.sender].benefactor == msg.sender, "Cannot donate to your own campaign");
        require(campaigns[msg.sender].id == _id, "Campaign does not exist");
        // require(campaigns[msg.sender].ended == false, "Campaign not active");
        require(block.timestamp > campaigns[msg.sender].deadline, "Campaign has ended");
        require(msg.value > 0, "Donation must be greater than 0");


        campaigns[msg.sender].amountRaised += msg.value;
       

        emit Donated(msg.sender, _id, msg.value);

    }

    // function that ends a campaign

    // function end_campaign() public view {
    //     require(campaigns[msg.sender].benefactor == msg.sender, "Cannot end other campaigns");
    //     require(block.timestamp > campaigns[msg.sender].deadline, "Campaign has not ended yet");

    //     // automatically transfer funds to the beneficiary
       
    //     // Automatically transfer funds to the benefactor
    //     campaigns[msg.sender].benefactor =+ campaigns[msg.sender].amountRaised;

    //     Campaign.amountRaised = 0;
    //     Campaign.ended = true;


    //     emit CampaignEnded(Campaign.id);
    // }


    // function that withdraws left over funds by only owner
    // only owner can withdraw left overfunds
    function withdraw() public payable onlyOwner {
       uint256 balance = address(this).balance;
       require(balance > 0, "No funds to withdraw");

        (bool success, ) = owner.call{value: balance}("");
        require(success, "Failed to send Ether");
    }
}