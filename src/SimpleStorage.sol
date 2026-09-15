// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

contract SimpleStorage{

        uint256 public myFavoriteNumber;

        struct Person //this is a way to create ones custom types
        {
           uint256 favoriteNumber;
           string name;     // now in a custom type you have to pass in the types 
                           // of your custom types say arguements what can be in the custom type and what cant.
                          //  now custom  types count like arrays from 0 - m+, e.g here favnumber is 0 and name = 

        } 

                    Person public pat =Person(7,"pat"); // thesame =      Person public pat = Person({favoriteNumber: 7 name: "pat" })
// now say you want to actually have an array of people
Person[] public ListOfPeople; // this right here helps us do just that, create a lists or an array for person permiting person to be able to add other peple like we will do.

       mapping (string=>uint256) public nameToFavoriteNumber; // a beter way of storing data in arrays by mapping something to something
// Noting there are 2 states of functions, a function 
//that is actively changing the state of the blockchain, 
//that is updating and doing a transaction, etc for example
// our store function here affects the state of the blockchain
// by storing a value so it will show on the deploy tab as orange
// a not so participant function that does not change the state of the 
// blockvhain for example our retrieve function will be blue on the deploy tab


    function store(uint256 _favoriteNumber) public virtual {// this virtual keyword permits this function to be used in another function of another completely differnt child function 
            myFavoriteNumber =  _favoriteNumber;
    }
// again a function can be in a view or pure state, view means it
// can read but cannot change state of the blockchain in whatsoever way
// pure on the other hand cannot read from functions talk less of changing
// the state of the function. they are always blue on the deploy tab
// because one does not have to 
// another interesting fact is these functions(the ones that dont change the state of the blockchain)
// actually dont cost gas except they are being calle by another function that actually does affect the state of the blockchain
// for example our store function here calling our retrieve function (return retrieve; or just retrieve;) 
    function retrieve() public view returns(uint256){
        return myFavoriteNumber;
    }


    function AddPerson(string memory _name, uint256 _favoriteNumber )public  {
            ListOfPeople.push(Person(_favoriteNumber, _name));
            nameToFavoriteNumber[_name]= _favoriteNumber;
    }
}