pragma solidity 0.6.8;

import "hardhat/console.sol";

// SPDX-License-Identifier: UNLICENCED

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
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
contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () internal {
        address msgSender = _msgSender();
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
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

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
contract Pausable is Context {
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
        emit Paused(_msgSender());
    }

    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}

//Restrictions:
//only 2^32 Users
//Maximum of 2^104 / 10^18 Ether investment. Theoretically 20 Trl Ether, practically 100000000000 Ether compiles
contract PrestigeClub is Ownable(), Pausable() {

    struct User {
        uint104 deposit; //265 bits together
        uint104 payout;
        uint32 position;
        uint8 qualifiedPools;
        uint8 downlineBonus;
        address referer;
        address[] referrals;
        
        uint104 downlinesum;
        uint40 lastPayout;
    }
    
    event NewDeposit(address indexed addr, uint104 amount);
    event PoolReached(address indexed addr, uint8 pool);
    event DownlineBonusStageReached(address indexed adr, uint8 stage);
    event Referral(address indexed addr, address indexed referral);
    
    //event InterestPayout(address indexed addr, uint256 amount);
    //event DirectPayout(address indexed addr, uint256 amount);
    //event PoolPayout(address indexed addr, uint256 amount);
    //event DownlinePayout(address indexed addr, uint256 amount);
    
    event Payout(address indexed addr, uint104 interest, uint104 direct, uint104 pool, uint104 downline);
    
    event Withdraw(address indexed addr, uint104 amount);
    
    mapping (address => User) users;
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
        //uint minDirects;
        uint64 payoutQuote; //ppm
    }
    
    uint40 public pool_last_draw = uint40(block.timestamp);
    
    constructor() public {
 
        /*pools[0] = Pool(0.3 ether, 1, 0.3 ether, 130, 0);  //TODO Alles * 10
        pools[1] = Pool(1.5 ether, 3, 0.5 ether, 130, 0);   //TODO Make Sum
        pools[2] = Pool(1.5 ether, 4, 4.4 ether, 130, 0);
        pools[3] = Pool(3 ether, 10, 10.5 ether, 130, 0);
        pools[4] = Pool(4.5 ether, 15, 28 ether, 130, 0);
        pools[5] = Pool(6 ether, 20, 53 ether, 130, 0);
        pools[6] = Pool(15 ether, 20, 147 ether, 80, 0);
        pools[7] = Pool(30 ether, 20, 295 ether, 80, 0);*/
        
        /*pools[0] = Pool(0.3 ether, 1, 0.3 ether, 130, 0); 
        pools[1] = Pool(0.5 ether, 1, 0.5 ether, 130, 0);
        pools[2] = Pool(0.5 ether, 3, 4.4 ether, 130, 0);
        pools[3] = Pool(0.5 ether, 3, 5 ether, 130, 0);
        pools[4] = Pool(0.5 ether, 3, 5 ether, 130, 0);
        pools[5] = Pool(2 ether, 5, 5 ether, 130, 0);
        pools[6] = Pool(3 ether, 5, 5 ether, 80, 0);
        pools[7] = Pool(5 ether, 5, 10 ether, 80, 0);*/
        
        pools[0] = Pool(1000 wei, 1, 1000 wei, 130, 0); 
        pools[1] = Pool(1000 wei, 1, 1000 wei, 130, 0);
        pools[2] = Pool(0.5 ether, 3, 4.4 ether, 130, 0);
        pools[3] = Pool(0.5 ether, 3, 5 ether, 130, 0);
        pools[4] = Pool(0.5 ether, 3, 5 ether, 130, 0);
        pools[5] = Pool(2 ether, 5, 5 ether, 130, 0);
        pools[6] = Pool(3 ether, 5, 5 ether, 80, 0);
        pools[7] = Pool(5 ether, 5, 10 ether, 80, 0);
        
        downlineBonuses[0] = DownlineBonusStage(3, 50);
        downlineBonuses[1] = DownlineBonusStage(4, 100);
        downlineBonuses[2] = DownlineBonusStage(5, 160);
        downlineBonuses[3] = DownlineBonusStage(6, 210);
        
        userList.push(address(0));
        
    }
    
    uint104 private minDeposit = 1000 wei;//0.1 ether; //TODO 0.1
    uint104 private minWithdraw = 0.1 ether; //TODO; Maybe remove? since this could prevent users from withdrawing
    
    uint40 constant private payout_interval = 5 seconds /*12 hours /*days*/;
    
    function recieve() public payable whenNotPaused {

        console.log("Recieve %s", _msgSender());

        require(users[_msgSender()].deposit >= minDeposit || msg.value >= minDeposit, "Mininum deposit value not reached");
        
        uint104 value = (uint104) (msg.value / 20 * 19);

        bool userExists = users[_msgSender()].position != 0;

        // Create a position for new accounts
        if(!userExists){
            lastPosition++;
            users[_msgSender()].position = lastPosition;
            users[_msgSender()].lastPayout = uint40(block.timestamp);
            userList.push(_msgSender());
        }
        
        if(block.timestamp > pool_last_draw + payout_interval){
            pushPoolState();
        }

        address referer = users[_msgSender()].referer; //can put outside because referer is always set since setReferral() gets called before recieve()

        if(referer != address(0)){
            updateUpline(referer, value);
        }

        //Update Payouts
        if(userExists){
            updatePayout(_msgSender());
        }

        users[_msgSender()].deposit += value;
        
        //Pay fee
        payable(owner()).transfer(msg.value - value);
        
        emit NewDeposit(_msgSender(), value);
            
        updateUserPool(_msgSender());
        updateDownlineBonusStage(_msgSender());
        if(referer != address(0)){
            updateUserPool(referer);
            updateDownlineBonusStage(referer);
        }
        
        depositSum += value;

    }
    
    function recieve(address referer) public payable whenNotPaused {
        
        _setReferral(referer);
        recieve();
        
    }
    
    function updateUpline(address adr, uint104 addition) private {
        
        address current = adr;

        console.log("updateUpline");
        
        while(current != address(0)){
            
            console.log(current);

            updatePayout(current);
            
            users[current].downlinesum += addition;
            current = users[current].referer;
        }
        
    }
    
    function updatePayout(address adr) private {
        
        uint40 dayz = (uint40(block.timestamp) - users[adr].lastPayout) / (payout_interval);
        console.log(" - ");
        console.log("Position %s", users[adr].position);
        console.log("Dayz %s", dayz);
        if(dayz >= 1){
            
            uint104 interestPayout = getInterestPayout(adr);
            uint104 poolpayout = getPoolPayout(adr, dayz);
            (uint104 directsPayout, uint104 downlineBonusAmount) = getPayout(adr);

            console.log("Got updatePayout for %s days %s", dayz, adr);
            
            uint104 sum = interestPayout + poolpayout + directsPayout + downlineBonusAmount;

            console.log("Sum: %s", sum);
            
            users[adr].payout += (sum * dayz);
            users[adr].lastPayout += (payout_interval * dayz);
            
            emit Payout(adr, interestPayout, directsPayout, poolpayout, downlineBonusAmount);
            
        }
    }
    
    function getInterestPayout(address adr) public view returns (uint104){
        //Calculate Base Payouts
        uint8 quote;
        uint104 deposit = users[adr].deposit;
        if(deposit >= 1.5 ether){ //TODO 30 ether
            quote = 15;
        }else{
            quote = 10;
        }
        
        console.log("Interest %s", deposit / 10000 * quote);
        return deposit / 10000 * quote;
    }
    
    function getPoolPayout(address adr, uint40 dayz) public view returns (uint104){

        uint40 length = (uint40)(states.length);
        console.log("Length %s", length);

        uint104 poolpayout = 0;

        for(uint40 day = length - dayz ; day < length ; day++){

            console.log("Day %s", day);
            console.log("Address %s", adr);

            uint32 numUsers = states[day].totalUsers;
            uint104 streamline = (uint104) (states[day].totalDeposits / (numUsers) * (numUsers - users[adr].position));

            console.log("Streamline: %s", streamline);
            console.log("QualifiedPools: %s", users[adr].qualifiedPools);
            console.log("LastPosition: %s, adr: %s", numUsers, adr);

            uint104 payout_day = 0; //TODO Merge into poolpayout, only for debugging
            uint32 numUsers = -1;
            for(uint8 j = 0 ; j < users[adr].qualifiedPools ; j++){
                uint104 pool_base = streamline / 1000000 * pools[j].payoutQuote;
                console.log("State %s", states[day].totalDeposits);
                console.log("State2 %s", states[day].numUsers[j]);

                numUsers = states[day].numUsers[j];

                if(numUsers != 0){
                    payout_day += pool_base / numUsers;
                }else{
                    console.log("WTF NO 0!!!!");
                }
            }
            console.log("day poolpayout %s", payout_day);

            poolpayout += payout_day;

        }

        console.log("poolpayout %s", poolpayout);
        
        return poolpayout;
    }

    function getPayout(address adr) public view returns (uint104, uint104) {
        
        //Calculate Directs Payouts
        (uint104 directsDepositSum, ) = calculateDirects(users[adr]);
        
        uint104 directsPayout = directsDepositSum / 10000 * 5;
        
        //Calculate Downline Bonus
        uint104 streamline = 0; //Reusing streamline for stack depth
        
        uint8 downlineBonus = users[adr].downlineBonus;
        
        if(downlineBonus > 0){
            
            streamline = users[adr].downlinesum / 1000000 * downlineBonuses[downlineBonus - 1].payoutQuote;

        }
        
        console.log("directs %s stream %s", directsPayout, streamline);

        return (directsPayout, streamline);
        
    }

    function pushPoolState() private {
        console.log("Push Pool state %s", states.length + 1);
        uint32[8] memory temp;
        for(uint8 i = 0 ; i < 8 ; i++){
            temp[i] = pools[i].numUsers;
        }
        states.push(PoolState(depositSum, lastPosition-1, temp));
        pool_last_draw += payout_interval;
    }
    
    function updateUserPool(address adr) private {
        
        if(users[adr].qualifiedPools < pools.length){
            
            uint8 poolnum = users[adr].qualifiedPools;
            
            uint104 sumDirects = 0;
            for(uint32 i = 0 ; i < users[adr].referrals.length ; i++){
                sumDirects += users[users[adr].referrals[i]].deposit;
            }
            
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
        
        if(users[adr].downlineBonus < downlineBonuses.length){
            
            uint bonusstage = users[adr].downlineBonus;
            
            //Check if requirements for next stage are met
            if(users[adr].qualifiedPools >= downlineBonuses[bonusstage].minPool){// && user.referrals.length >= downlineBonuses[bonusstage].minDirects){
                users[adr].downlineBonus += 1;
                
                emit DownlineBonusStageReached(adr, users[adr].downlineBonus);
                
                updateDownlineBonusStage(adr);
            }
            
        }
        
    }
    
    function getDownline() external view returns (uint104 sum, uint32 numUsers) {
        return getDownline(users[_msgSender()]);
    }
    
    function getDownline(User memory user) private view returns (uint104, uint32) {
        uint104 sum = 0;
        uint32 num = 0;
        
        address[] memory referrals = user.referrals;
        for(uint32 i = 0 ; i < referrals.length ; i++){
            (uint104 sum2, uint32 num2) = getDownline(users[referrals[i]]);
            
            sum += sum2 + users[referrals[i]].deposit;
            num += num2 + 1;
        }
        
        return (sum, num);
    }
    
    function calculateDirects() external view returns (uint128 sum, uint32 numDirects) {
        return calculateDirects(users[_msgSender()]);
    }
    
    function calculateDirects(User memory user) private view returns (uint104, uint32) {
        
        address[] memory referrals = user.referrals;
        
        uint104 sum = 0;
        for(uint32 i = 0 ; i < referrals.length ; i++){
            sum += users[referrals[i]].deposit;
        }
        
        return (sum, (uint32)(referrals.length));
        
    }
    
    function withdraw(uint104 amount) public whenNotPaused {
        
        require(amount > minWithdraw, "Minimum Withdrawal amount not met");
        require(users[_msgSender()].payout >= amount, "Not enough payout available to cover withdrawal request");
        
        uint104 transfer = amount / 20 * 19;
        
        payable(_msgSender()).transfer(transfer);
        
        users[_msgSender()].payout -= amount;
        
        emit Withdraw(_msgSender(), amount);
        
        payable(owner()).transfer(amount - transfer);
        
    }
    
    
    function setReferral(address referer) public whenNotPaused {
        
        _setReferral(referer);
        
        updateUserPool(referer);
        updateDownlineBonusStage(referer);
    }

    function _setReferral(address referer) private {
        
        if(users[_msgSender()].referer == referer){
            return;
        }
        
        if(users[_msgSender()].position != 0 && users[_msgSender()].position < users[referer].position) {
            return;
        }
        
        require(users[_msgSender()].referer == address(0), "Referer can only be set once");
        require(users[referer].position > 0, "Referer does not exist");
        require(_msgSender() != referer, "Cant set oneself as referer");
        
        users[referer].referrals.push(_msgSender());
        users[_msgSender()].referer = referer;
        
        emit Referral(referer, _msgSender());
    }
    
    function totalDeposits() public view returns (uint) {
        uint104 sum = 0;
        for(uint32 i = 1 ; i < userList.length ; i++) {
            sum += users[userList[i]].deposit;
        }
        return sum;
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

            return (_msgSender(), 
                users[_msgSender()].position,
                users[_msgSender()].deposit,
                users[_msgSender()].payout,
                users[_msgSender()].qualifiedPools,
                users[_msgSender()].downlineBonus,
                users[_msgSender()].lastPayout,
                users[_msgSender()].referer,
                users[_msgSender()].referrals);
    }
    
    //TODO DEBUG
    function getUserList() public view returns (address[] memory){
        return userList;
    }
    
    function getUsers(address adr) public view returns (
        address adr_,
        uint32 position_,
        uint128 deposit_,
        uint128 payout_,
        uint8 qualifiedPools_,
        address referer,
        address[] memory referrals_){
            
            return (adr, 
                users[adr].position,
                users[adr].deposit,
                users[adr].payout,
                users[adr].qualifiedPools,
                users[adr].referer,
                users[adr].referrals);
    }
    
    function triggerCalculation() public { //TODO Either onlyOwner or remove
        //calculatePayouts();
        //calculateStreamlineForAll();
    } 

}