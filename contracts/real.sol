pragma solidity 0.8.13;

contract lottery{
    uint256 start_timestamp;
    uint256 start_price;
    uint256 finish_price;
    uint256 finish_timestamp;
    
    mapping(address => uint) bet_amount;
    mapping(address => bool) bet_info;
    address [] bets;

    uint fee = 30;
    
    uint bet_up_total;
    uint bet_down_total;
    address admin = 0x449713a131320f7685f9Afac321655cbC0193a2d;
    bool round_status;
    

    modifier onlyOwner() {
        require(msg.sender == admin);
        _;
    }

   function start(uint256 bnb_price) view external onlyOwner {
       require(round_status == false, "another betting is already started");

        round_status = true;
        start_price = bnb_price;
        start_timestamp = block.timestamp;
    }

    function finish(uint256 bnb_price) view external onlyOwner {
        require(round_status == true, "betting not started");
        require(start_timestamp + 10 minutes < block.timestamp, "Not 10min yet");
        // if(start_timestamp + 11 >= now()){
        //     round_status = status.cancaled;
        //     return;
        // }
        finish_price = bnb_price;
        finish_timestamp = block.timestamp;
        round_status = false;

        claim();
    }
    function bet_up(uint256 amount) view external {
        require(bet_amount[msg.sender] == 0, "already commited!!");
        bet_amount[msg.sender] = amount;
        bet_info[msg.sender] = true;
        bets.push(msg.sender);

        BNB.transfer(address(this), amount);
        bet_up_total += amount;
    }
    function bet_down(uint amount) view external {
        require(bet_amount[msg.sender] == 0, "already commited!!");
        bet_amount[msg.sender] = amount;
        bet_info[msg.sender] = false;
        BNB.transfer(address(this), amount);
        bet_down_total += amount;
    }
    function claim() view internal {
        require(round_status == false, "betting not finished!!!");
        // if(bet_info[] != start_price){
        //     amount = bet_amount[msg.sendar];
        // }
        // if(bet_info[msg.sender] == true){
        //     revwrd(amount / bet_up_total) * (bet_up_info + bet_down_total) * (1 - fee);
        // } else BNB.transfer(address msg.sender, uint reward)

        for (uint256 i = 0; i < bets.length; i++) {
            // bets[i], bet_amount[bets[i]], bet_info[bets[i]]
            uint256 amount = bet_amount[msg.sendar];
            uint256 reward;
            address recipient = bets[i];

            if ( bet_info[bets[i]] ) {  // up
                reward = (amount / bet_up_total) * (bet_up_total + bet_down_total) * (100 - fee) / 100;
            } else {    // down
                reward = (amount / bet_down_total) * (bet_up_total + bet_down_total) * (100 - fee) / 100;
            }

            payable(recipient).transfer(reward);
        }
    }
}