pragma solidity ^0.5.0;

import "./Migrations.sol";
import "./admin.sol";
import "./right.sol";

/**
* @title Supply Chain tracking
* @author Michael Adrah
* @notice Implements a basic compositional supply chain contract.
*/
contract supplyChain is Migrations,admin {
   event StepCreated(uint256 step);
    /**  
        * @notice Supply chain step data. By chaining these and not 
        * allowing them to be modified afterwards we create an Acyclic
        * Directed Graph.
        * @dev The step id is not stored in the Step itself because it
        * is always previously available to whoever looks for the step.
        * @param creator The creator of this step.
        * @param product_id The id of the object that this step refers to.
        * @param precedents The step ids preceding this one in the
        * supply chain.
    */
   struct Step {
       address creator;
       uint256 product_id;
       uint256[] precedents;
       string name_of_company;
       string name_of_product;
       string quantity_of_product;
       string stage;

   }
   /**
    * @notice All steps are accessible through a mapping keyed by
    * the step ids. Recursive structs are not supported in solidity.
    */
   mapping(uint256 => Step) public steps;
   /**
    * @notice Step counter
    */
   uint256 public totalSteps;
   /**
    * @notice Mapping from product_id id to the last step in the lifecycle 
    * of that product_id.
    */
   mapping(uint256 => uint256) public lastSteps;
   /**
    * @notice A method to create a new supply chain step. The 
    * msg.sender is recorded as the creator of the step, which might
    * possibly mean creator of the underlying asset as well.
    * @param _product_id The product_id id that this step is for. This must be
    * either the product_id of one of the steps in _precedents, or an id
    * that has never been used before.
    * @param _precedents An array of the step ids for steps
    * considered to be predecessors to this one. Often this would 
    * just mean that the event refers to the same asset as the event 
    * pointed to, but for other steps it could point to other
    * different assets.
    * @return The step id of the step created.
    */
   function newStep(string memory _name_of_company, string memory _name_of_product,
                    string memory _quantity_of_product, uint256 _product_id,
                    uint256[] memory _precedents, string memory _stage ) public rightOnly()

        returns(uint256)
   {
    //    if (keccak256(bytes(_stage)) != keccak256("supplier") || keccak256("manufacturer") || keccak256("distributor") || keccak256("retailer")){
    //        string memory msg1;
    //       msg1 = "CHECK THE SPELLING .......It should be supplier,manufacturer,distributor or retailer";
    //       return msg1;
    //    }

       uint stageRole;
       if(keccak256(bytes(_stage)) == keccak256("supplier") ){stageRole = 1;}
       if(keccak256(bytes(_stage)) == keccak256("manufacturer") ){stageRole = 2;}
       if(keccak256(bytes(_stage)) == keccak256("distributer") ){stageRole = 3;}
       if(keccak256(bytes(_stage)) == keccak256("retailer") ){stageRole = 4;}

       require(hasRole(msg.sender,stageRole)," You don't the permission to add details ");
       for (uint i = 0; i < _precedents.length; i++){
           require(isLastStep(_precedents[i]),"Append only on last steps.");
       }
       bool repeatInstance = false;
       for (uint i = 0; i < _precedents.length; i++){
           if (steps[_precedents[i]].product_id == _product_id) {
               repeatInstance = true;
               break;
           }
       }
       if (!repeatInstance){
           require(lastSteps[_product_id] == 0, "Instance not valid.");
       }
      
       steps[totalSteps] = Step(
           msg.sender,
           _product_id,
           _precedents,
           _name_of_company,
           _name_of_product,
           _quantity_of_product,
           _stage
       );
       uint256 step = totalSteps;
       totalSteps += 1;
       lastSteps[_product_id] = step;
       steps[_product_id].product_id = _product_id;
       steps[_product_id].name_of_company = _name_of_company;
       steps[_product_id].name_of_product = _name_of_product;
       steps[_product_id].quantity_of_product = _quantity_of_product;
       steps[_product_id].stage = _stage;
       emit StepCreated(step);
       return step;
   }
   /**
    * @notice A method to verify whether a step is the last of an 
    * product_id.
    * @param _step The step id of the step to verify.
    * @return Whether a step is the last of an product_id.
    */
   function isLastStep(uint256 _step)
       public
       view
       returns(bool)
   {
       return lastSteps[steps[_step].product_id] == _step;
   }
   /**
    * @notice A method to retrieve the precedents of a step.
    * @param _step The step id of the step to retrieve precedents
    * for.
    * @return An array with the step ids of the precedent steps.
    */
   function getprecedents(uint256 _step, uint _product_id)
       public
       view
       returns(uint256[] memory, uint256, string memory ,string memory, string memory, string memory  )
   {
       return( steps[_step].precedents, steps[_product_id - 1].product_id,
       steps[_product_id - 1].name_of_company,steps[_product_id - 1].name_of_product,
       steps[_product_id - 1].quantity_of_product, steps[_product_id - 1].stage);
   }
}
// function getprecedents(uint256 _step, uint _product_id)
//        public
//        view
//        returns(uint256[] memory, uint256, string memory ,string memory, string memory, string memory  )
//    {   if(_step != 0 ){
//             for(uint256 i = _step; i >= 0; i--){
//                 return( steps[_step].precedents, steps[_product_id - 1].product_id,
//                 steps[_product_id - 1].name_of_company,steps[_product_id - 1].name_of_product,
//                 steps[_product_id - 1].quantity_of_product, steps[_product_id - 1].stage);
//                 _product_id - 1;
//         }
//      }
   }
}