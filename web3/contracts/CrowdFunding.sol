// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

contract CrowdFunding {
    struct Campaign {
        address owner;
        string title;
        string description;
        uint256 target;
        uint256 deadline;
        uint256 amountCollected;
        string image;
        address[] donators;
        uint256[] donations;
    }

    mapping(uint256 => Campaign) public campaigns;

    uint256 public numberOfCampaigns = 0;

    //pass in all the parameters needed for 'createCampaign' function and return a number as the id of the Campaign
    function createCampaign(
        address _owner, 
        string memory _title, 
        string memory _description, 
        uint256 _target, 
        uint256 _deadline, 
        string memory _image) public returns (uint256) {

        Campaign storage campaign = campaigns[numberOfCampaigns];

        //a check to see everything is okay -- our code will not proceed further until the require is satisfied
        require(campaign.deadline < block.timestamp, "The deadline should be a date in the future");

        campaign.owner = _owner;
        campaign.title = _title;
        campaign.description = _description;
        campaign.target = _target;
        campaign.deadline = _deadline;
        campaign.amountCollected = 0;
        campaign.image = _image;

        numberOfCampaigns++;

        //if everything went right we return number of campaigns with the index of the most newly created campaign
        return numberOfCampaigns -1;

    }
//payable is a key word the signifies that we are going to send some cryptocurrency throughout this function 
    function donateToCampaign(uint256 _id) public payable {
        //this is what we are trying to send from our front end
        uint256 amount = msg.value;

        //the campaigns is from the mapping we created at the top
        Campaign storage campaign = campaigns[_id];

        //push the address of the person donated + the amount they donated
        campaign.donators.push(msg.sender);
        campaign.donations.push(amount);

        //to make the transaction we set the variable to let us know that that the transaction has been sent or not + send it to the owner of the campaign
        (bool sent,) = payable(campaign.owner).call{value: amount}("");

        if(sent) {
            campaign.amountCollected = campaign.amountCollected + amount;
        }
    }
    //first we need to know from which campaign do we need to get the donators from...only a view function and will return an array of addresses from memory and an array of numbers of donations
    function getDonators(uint256 _id) view public returns (address[] memory, uint256[] memory) {
        return (campaigns[_id].donators, 
        campaigns[_id].donations);
    }

//takes no parameters because we return all campaigns
    function getCampaigns() public view returns (Campaign[] memory) {
        //get all campaigns...we are creating a new variable of all Campaigns which is of a type of array of multiple Campaigns structures
        Campaign[] memory allCampaigns = new Campaign[](numberOfCampaigns);

        // loop through all of the campaigns and populate the allCampaigns variable 
        for(uint i = 0; i < numberOfCampaigns; i++) {
            Campaign storage item = campaigns[i];
            
            //we fetch the specific campaign from storage and populate it into allCampaigns
            allCampaigns[i] = item;
        }

        return allCampaigns;

    }
}