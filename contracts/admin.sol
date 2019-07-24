
pragma solidity ^0.5.0;

import "./right.sol";
import "./Migrations.sol";

contract admin is right {
    event RoleCreated(uint256 role);
    event BearerAdded(address account, uint256 role);
    event BearerRemoved(address account, uint256 role);
    /**
     * @notice A role, which will be used to group users.
     * @dev The role id is its position in the roles array.
     * @param description A description for the role.
     * @param admin The only role that can add or remove bearers
     * from this role. To have the role bearers to be also the role
     * admins you should pass roles.length as the admin role.
     * @param bearers Addresses belonging to this role.
     */
    struct Role {
        string description;
        uint256 admin;
        address[] bearers;
    }
    /**
     * @notice All roles ever created.
     */
    Role[] public roles;
    /**
     * @notice The contract constructor, empty as of now.
     */
    constructor() public {
    }
    /**
     * @notice Create a new role.
     * @dev If the _admin parameter is the id of the newly created
     * role msg.sender is added to it automatically.
     * @param _roleDescription The description of the role being 
     * created.
     * @param _admin The role that is allowed to add and remove 
     * bearers from the role being created.
     * @return The role id.
     */

    
    address[10] accounts =
    [ 0x77bDa9fA7e6a74eeDfc76E1D1ee2E47B01356840,
    0x0Aee156F132a913AB6aBA6Efd23146c13787f249,
    0xD7f6bE6fb84592c7E6421cf504752B1A55a22FDc,
    0x53479e1BDF0B892E041eAdb81F041fA6b20490B7,
    0x41F410E5475A877f05d405f6be96755b09C3eD63,
    0x6A04C0ab60994989795159374B3Aa6F878f2b57F,
    0xBAE2E2cd214ea0cC404A82E48e3f7006d5ec2C5B,
    0x3a16Eb1C62548b76505fA1bf90DC3B25FB866f1A,
    0x3348e65CDECb1b3033668160fF5416a21Ee09933,
    0x5EF977f1B098cca2706040B9c188608FA68434d4 ];

    modifier rightOnly(){
        if(msg.sender != accounts[0]) _;
    }

    function addRole(string memory _roleDescription,uint256 _admin) public returns(uint256)
    {
        require(_admin <= roles.length,"Admin role doesn't exist.");
        uint256 role = roles.push(
            Role({
                description: _roleDescription,
                admin: _admin,
                bearers: new address[](0)
            })
        ) - 1;
        emit RoleCreated(role);
        if (_admin == role) {
            roles[role].bearers.push(msg.sender);
            emit BearerAdded(msg.sender, role);
        }
        return role;
    }
    /**
     * @notice Verify whether an address is a bearer of a role
     * @param _account The account to verify.
     * @param _role The role to look into.
     * @return Whether the account is a bearer of the role.
     */
    function hasRole(address _account,uint256 _role)
        public
        view
        returns(bool)
    {
        if (_role >= roles.length ) return false;
            address[] memory _bearers = roles[_role].bearers;
            for (uint256 i = 0; i < _bearers.length; i++){
                if (_bearers[i] == _account) return true;
            }
        return false;
    }
    /**
     * @notice Add a bearer to a role
     * @param _account The address to add as a bearer.
     * @param _role The role to add the bearer to.
     */
    function addBearer(address _account,uint256 _role) public {
        require(_role < roles.length,"Role doesn't exist.");
        require(
            hasRole(msg.sender, roles[_role].admin),
            "User not authorized to add bearers."
        );
        if (hasRole(_account, _role) == false){
            roles[_role].bearers.push(_account);
            emit BearerAdded(_account, _role);
        }
    }
    /**
     * @notice Remove a bearer from a role
     * @param _account The address to remove as a bearer.
     * @param _role The role to remove the bearer from.
     */
    function removeBearer(address _account,uint256 _role) public 
{
        require(_role < roles.length,"Role doesn't exist.");
        require(hasRole(msg.sender, roles[_role].admin),"User not authorized to remove bearers.");
        address[] memory _bearers = roles[_role].bearers;
        for (uint256 i = 0; i < _bearers.length; i++){
            if (_bearers[i] == _account){
                _bearers[i] = _bearers[_bearers.length - 1];
                roles[_role].bearers.pop();
                emit BearerRemoved(_account, _role);
            }
        }
    }
}