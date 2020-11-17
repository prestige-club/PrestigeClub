pragma solidity 0.6.8;


/*
// SPDX-License-Identifier: MIT


/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
library SafeMath104 {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint104 a, uint104 b) internal pure returns (uint104) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint104 a, uint104 b, string memory errorMessage) internal pure returns (uint104) {
        if(!(b <= a)){
            return 0;
        }
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts with custom message when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () internal {
        address msgSender = msg.sender;
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    // function renounceOwnership() public onlyOwner {
    //     emit OwnershipTransferred(_owner, address(0));
    //     _owner = address(0);
    // }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}


/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
contract Pausable {
    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    bool private _paused;

    constructor () internal {
        _paused = false;
    }

    function paused() public view returns (bool) {
        return _paused;
    }

    modifier whenNotPaused() {
        require(!_paused, "Pausable: paused");
        _;
    }

    modifier whenPaused() {
        require(_paused, "Pausable: not paused");
        _;
    }

    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(msg.sender);
    }

    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(msg.sender);
    }
}

//Restrictions:
//only 2^32 Users
//Maximum of 2^104 / 10^18 Ether investment. Theoretically 20 Trl Ether, practically 100000000000 Ether compiles
//Maximum of (2^104 / 10^18 Ether) investment. Theoretically 20 Trl Ether, practically 100000000000 Ether compiles
contract PrestigeClub is Ownable(), Pausable() {

    struct User {
        uint104 deposit; //265 bits together
        uint104 payout;
        uint32 position;
        uint8 qualifiedPools;
        uint8 downlineBonus;
        address referer;
        address[] referrals;

        uint104 directSum;
        uint40 lastPayout;

        uint104[5] downlineVolumes;
    }
    
    event NewDeposit(address indexed addr, uint104 amount);
    event PoolReached(address indexed addr, uint8 pool);
    event DownlineBonusStageReached(address indexed adr, uint8 stage);
    event Referral(address indexed addr, address indexed referral);
    
    event Payout(address indexed addr, uint104 interest, uint104 direct, uint104 pool, uint104 downline, uint40 dayz); 
    
    event Withdraw(address indexed addr, uint104 amount);
    
    mapping (address => User) public users;
    address[] userList;

    uint32 public lastPosition = 0;
    
    uint128 public depositSum = 0;
    
    Pool[8] public pools;
    
    struct Pool {
        uint104 minOwnInvestment;
        uint8 minDirects;
        uint104 minSumDirects;
        uint8 payoutQuote; //ppm
        uint32 numUsers;
    }

    PoolState[] public states;

    struct PoolState {
        uint128 totalDeposits;
        uint32 totalUsers;
        uint32[8] numUsers;
    }
    
    DownlineBonusStage[4] downlineBonuses;
    
    struct DownlineBonusStage {
        uint32 minPool;
        uint64 payoutQuote; //ppm
    }
    
    uint40 public pool_last_draw;
    
    constructor() public {
 
        uint40 timestamp = uint40(block.timestamp);
        pool_last_draw = timestamp - (timestamp % payout_interval) - payout_interval;

        pools[0] = Pool(3 ether, 1, 3 ether, 130, 0);
        pools[1] = Pool(15 ether, 3, 5 ether, 130, 0);
        pools[2] = Pool(15 ether, 4, 44 ether, 130, 0);
        pools[3] = Pool(30 ether, 10, 105 ether, 130, 0);
        pools[4] = Pool(45 ether, 15, 280 ether, 130, 0);
        pools[5] = Pool(60 ether, 20, 530 ether, 130, 0);
        pools[6] = Pool(150 ether, 20, 1470 ether, 80, 0);
        pools[7] = Pool(300 ether, 20, 2950 ether, 80, 0);

        downlineBonuses[0] = DownlineBonusStage(3, 50);
        downlineBonuses[1] = DownlineBonusStage(4, 100);
        downlineBonuses[2] = DownlineBonusStage(5, 160);
        downlineBonuses[3] = DownlineBonusStage(6, 210);
        
        userList.push(address(0));
        
    }
    
    uint104 private minDeposit = 1 ether;
    uint104 private minWithdraw = 1000 wei; 
    
    uint40 constant private payout_interval = 1 days;
    
    function recieve() public payable whenNotPaused {
        
        require((users[msg.sender].deposit / 19 * 20) >= minDeposit || msg.value >= minDeposit, "Mininum deposit value not reached");
        
        address sender =  msg.sender;

        uint104 value = (uint104) (msg.value / 20 * 19);

        bool userExists = users[sender].position != 0;
        
        triggerCalculation();

        // Create a position for new accounts
        if(!userExists){
            lastPosition++;
            users[sender].position = lastPosition;
            users[sender].lastPayout = (pool_last_draw + 1);
            userList.push(sender);
        }

        address referer = users[sender].referer; //can put outside because referer is always set since setReferral() gets called before recieve() in recieve(address)

        if(referer != address(0)){
            updateUpline(sender, referer, value);
        }

        //Update Payouts
        if(userExists){
            updatePayout(sender);
        }

        users[sender].deposit += value;
        
        //Transfer fee
        payable(owner()).transfer(msg.value - value);
        
        emit NewDeposit(sender, value);
        
        updateUserPool(sender);
        updateDownlineBonusStage(sender);
        if(referer != address(0)){
            users[referer].directSum += value;

            updateUserPool(referer);
            updateDownlineBonusStage(referer);
        }
        
        depositSum += value;

    }
    
    
    function recieve(address referer) public payable whenNotPaused {
        
        _setReferral(referer);
        recieve();
        
    }

    uint8 public downlineLimit = 30;

    function updateUpline(address reciever, address adr, uint104 addition) private {
        
        address current = adr;
        uint8 bonusStage = users[reciever].downlineBonus;
        
        uint8 downlineLimitCounter = downlineLimit - 1 + 1;
        
        while(current != address(0) && downlineLimitCounter > 0){

            updatePayout(current);


            users[current].downlineVolumes[bonusStage] += addition;
            uint8 currentBonus = users[current].downlineBonus;
            if(currentBonus > bonusStage){
                bonusStage = currentBonus;
            }

            current = users[current].referer;
            downlineLimitCounter--;
        }
        
    }
    
    function updatePayout(address adr) private {
        
        uint40 dayz = (uint40(block.timestamp) - users[adr].lastPayout) / (payout_interval);
        if(dayz >= 1){
            
            uint104 interestPayout = getInterestPayout(adr);
            uint104 poolpayout = getPoolPayout(adr, dayz);
            uint104 directsPayout = getDirectsPayout(adr);
            uint104 downlineBonusAmount = getDownlinePayout(adr);
            
            uint104 sum = interestPayout + directsPayout + downlineBonusAmount;
            sum = (sum * dayz) + poolpayout;
            
            users[adr].payout += sum;
            users[adr].lastPayout += (payout_interval * dayz);
            
            emit Payout(adr, interestPayout, directsPayout, poolpayout, downlineBonusAmount, dayz);
            
        }
    }
    
    function getInterestPayout(address adr) public view returns (uint104){
        //Calculate Base Payouts
        uint8 quote;
        uint104 deposit = users[adr].deposit;
        if(deposit >= 30 ether){
            quote = 15;
        }else{
            quote = 10;
        }
        
        return deposit / 10000 * quote;
    }
    
    function getPoolPayout(address adr, uint40 dayz) public view returns (uint104){

        uint40 length = (uint40)(states.length);

        uint104 poolpayout = 0;

        if(users[adr].qualifiedPools > 0){
            for(uint40 day = length - dayz ; day < length ; day++){


                uint32 numUsers = states[day].totalUsers;
                uint104 streamline = (uint104) (states[day].totalDeposits / (numUsers) * (numUsers - users[adr].position));


                uint104 payout_day = 0; //TODO Merge into poolpayout, only for debugging
                uint32 stateNumUsers = 0;
                for(uint8 j = 0 ; j < users[adr].qualifiedPools ; j++){
                    uint104 pool_base = streamline / 1000000 * pools[j].payoutQuote;

                    stateNumUsers = states[day].numUsers[j];

                    if(stateNumUsers != 0){
                        payout_day += pool_base / stateNumUsers;
                    }
                }

                poolpayout += payout_day;

            }
        }
        
        return poolpayout;
    }

    function getDownlinePayout(address adr) public view returns (uint104){

        //Calculate Downline Bonus
        uint104 downlinePayout = 0;
        
        uint8 downlineBonus = users[adr].downlineBonus;
        
        if(downlineBonus > 0){
            
            uint64 ownPercentage = downlineBonuses[downlineBonus - 1].payoutQuote;

            for(uint8 i = 0 ; i < downlineBonus; i++){

                uint64 quote = 0;
                if(i > 0){
                    quote = downlineBonuses[i - 1].payoutQuote;
                }else{
                    quote = 0;
                }

                uint64 percentage = ownPercentage - quote;


                downlinePayout += users[adr].downlineVolumes[i] * percentage / 1000000;

            }

            if(downlineBonus == 4){
                downlinePayout += users[adr].downlineVolumes[downlineBonus] * 50 / 1000000;
            }

        }

        return downlinePayout;
        
    }

    function getDirectsPayout(address adr) public view returns ( uint104) {
        
        //Calculate Directs Payouts
        uint104 directsDepositSum = users[adr].directSum;

        uint104 directsPayout = directsDepositSum / 10000 * 5;

        return (directsPayout);
        
    }

    function pushPoolState() private {
        uint32[8] memory temp;
        for(uint8 i = 0 ; i < 8 ; i++){
            temp[i] = pools[i].numUsers;
        }
        states.push(PoolState(depositSum, lastPosition, temp));
        pool_last_draw += payout_interval;
    }
    
    function updateUserPool(address adr) private {
        
        if(users[adr].qualifiedPools < pools.length){
            
            uint8 poolnum = users[adr].qualifiedPools;
            
            uint104 sumDirects = users[adr].directSum;
            
            //Check if requirements for next pool are met
            if(users[adr].deposit >= pools[poolnum].minOwnInvestment && users[adr].referrals.length >= pools[poolnum].minDirects && sumDirects >= pools[poolnum].minSumDirects){
                users[adr].qualifiedPools = poolnum + 1;
                pools[poolnum].numUsers++;
                
                emit PoolReached(adr, poolnum + 1);
                
                updateUserPool(adr);
            }
            
        }
        
    }
    
    function updateDownlineBonusStage(address adr) private {

        uint8 bonusstage = users[adr].downlineBonus;

        if(bonusstage < downlineBonuses.length){
            

            //Check if requirements for next stage are met
            if(users[adr].qualifiedPools >= downlineBonuses[bonusstage].minPool){
                users[adr].downlineBonus += 1;
                
                //Update data in upline
                uint104 value = users[adr].deposit;  //Value without current stage, since that must not be subtracted

                for(uint8 i = 0 ; i <= bonusstage ; i++){
                    value += users[adr].downlineVolumes[i];
                }

                uint104 additionValue = value;


                uint8 currentBonusStage = bonusstage + 1;

                address current = users[adr].referer;
                while(current != address(0)){


                    users[current].downlineVolumes[currentBonusStage - 1] -= value;
                    users[current].downlineVolumes[currentBonusStage] += additionValue;
                    

                    current = users[current].referer;

                }

                emit DownlineBonusStageReached(adr, users[adr].downlineBonus);
                
                updateDownlineBonusStage(adr);
            }
        }
        
    }
    
    function calculateDirects() external view returns (uint128 sum, uint32 numDirects) {
        return calculateDirects(msg.sender);
    }
    
    function calculateDirects(address adr) private view returns (uint104, uint32) {
        
        address[] memory referrals = users[adr].referrals;
        
        uint104 sum = 0;
        for(uint32 i = 0 ; i < referrals.length ; i++){
            sum += users[referrals[i]].deposit;
        }
        
        return (sum, (uint32)(referrals.length));
        
    }
    
    //Endpoint to withdraw payouts
    function withdraw(uint104 amount) public whenNotPaused {
        
        updatePayout(msg.sender);

        require(amount > minWithdraw, "Minimum Withdrawal amount not met");
        require(users[msg.sender].payout >= amount, "Not enough payout available to cover withdrawal request");
        
        uint104 transfer = amount / 20 * 19;
        
        payable(msg.sender).transfer(transfer);
        
        users[msg.sender].payout -= amount;
        
        emit Withdraw(msg.sender, amount);
        
        payable(owner()).transfer(amount - transfer);
        
    }

    function _setReferral(address referer) private {
        
        if(users[msg.sender].referer == referer){
            return;
        }
        
        if(users[msg.sender].position != 0 && users[msg.sender].position < users[referer].position) {
            return;
        }
        
        require(users[msg.sender].referer == address(0), "Referer can only be set once");
        require(users[referer].position > 0, "Referer does not exist");
        require(msg.sender != referer, "Cant set oneself as referer");
        
        users[referer].referrals.push(msg.sender);
        users[msg.sender].referer = referer;

        if(users[msg.sender].deposit > 0){
            users[referer].directSum += users[msg.sender].deposit;
        }
        
        emit Referral(referer, msg.sender);
    }
    
    uint invested = 0;
    
    function invest(uint amount) public onlyOwner {
        
        payable(owner()).transfer(amount);
        
        invested += amount;
    }
    
    function reinvest() public payable onlyOwner {
        if(msg.value > invested){
            invested = 0;
        }else{
            invested -= msg.value;
        }
    }
    
    function setMinDeposit(uint104 min) public onlyOwner {
        minDeposit = min;
    }
    
    function setMinWithdraw(uint104 min) public onlyOwner {
        minWithdraw = min;
    }
    
    function pause() external onlyOwner {
        _pause();
    }
    
    function unpause() external onlyOwner {
        _unpause();
    }

    function setDownlineLimit(uint8 limit) public onlyOwner {
        require(limit > 5, "Limit too low");
        downlineLimit = limit;
    }

    //Only for BO
    function getDownline() external view returns (uint104, uint){
        uint104 sum;
        for(uint8 i = 0 ; i < users[msg.sender].downlineVolumes.length ; i++){
            sum += users[msg.sender].downlineVolumes[i];
        }

        uint numUsers = getDownlineUsers(msg.sender);

        return (sum, numUsers);
    }

    function getDownlineUsers(address adr) public view returns (uint){

        uint sum = 0;
        uint length = users[adr].referrals.length;
        sum += length;
        for(uint i = 0; i < length ; i++){
            sum += getDownlineUsers(users[adr].referrals[i]);
        }
        return sum;
    }
    
    function reCalculateImported() public onlyOwner{
        for(uint64 i = 1 ; i < lastPosition + 1 ; i++){
            address adr = userList[i];
            users[adr].payout = 0;
            users[adr].lastPayout = pool_last_draw - payout_interval;
            updatePayout(adr);
        }
    }
    
    function _import(address[] memory sender, uint104[] memory deposit, address[] memory referer) public onlyOwner {
        for(uint64 i = 0 ; i < sender.length ; i++){
            importUser(sender[i], deposit[i], referer[i]);
        }
    }
    
    function importUser(address sender, uint104 deposit, address referer) public onlyOwner {
        
        if(referer != address(0)){
            users[referer].referrals.push(sender);
            users[sender].referer = referer;
            
            emit Referral(referer, msg.sender);
        }

        uint104 value = deposit;

        // Create a position for new accounts
        lastPosition++;
        users[sender].position = lastPosition;
        users[sender].lastPayout = pool_last_draw;
        userList.push(sender);

        if(referer != address(0)){
            updateUpline(sender, referer, value);
        }

        users[sender].deposit += value;
        
        emit NewDeposit(sender, value);
        
        updateUserPool(sender);
        updateDownlineBonusStage(sender);
        
        if(referer != address(0)){
            users[referer].directSum += value;
    
            updateUserPool(referer);
            updateDownlineBonusStage(referer);
        }
        
        depositSum += value;
        
    }

    function getUserData() public view returns (
        address adr_,
        uint position_,
        uint deposit_,
        uint payout_,
        uint qualifiedPools_,
        uint downlineBonusStage_,
        uint lastPayout,
        address referer,
        address[] memory referrals_) {

            return (msg.sender, 
                users[msg.sender].position,
                users[msg.sender].deposit,
                users[msg.sender].payout,
                users[msg.sender].qualifiedPools,
                users[msg.sender].downlineBonus,
                users[msg.sender].lastPayout,
                users[msg.sender].referer,
                users[msg.sender].referrals);
    }
    
    //DEBUGGING
    //Used for extraction of User data in case of something bad happening and fund reversal needed.
    function getUserList() public view returns (address[] memory){  //TODO Probably not needed
        return userList;
    }
    
    function getUsers(address adr) public view returns (
        address adr_,
        uint32 position_,
        uint128 deposit_,
        uint128 payout_,
        uint lastPayout_,
        uint8 qualifiedPools_,
        address referer
        ){
            
            return (adr, 
                users[adr].position,
                users[adr].deposit,
                users[adr].payout,
                users[adr].lastPayout,
                users[adr].qualifiedPools,
                users[adr].referer
                );
    }
    
    function triggerCalculation() public {
        
        if(block.timestamp > pool_last_draw + payout_interval){
            pushPoolState();
        }
    }

}