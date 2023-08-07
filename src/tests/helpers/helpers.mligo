#import "../../../src/contracts/mainrendu.mligo" "MainRendu"





type taddrRendu = (MainRendu.action, MainRendu.storage) typed_address
type contrRendu = MainRendu.action contract


let get_storageBis(taddr : taddrRendu) =
    Test.get_storage taddr


let callBis (p, contr : MainRendu.action * contrRendu) =
    Test.transfer_to_contract contr (p) 0mutez



let add_admin(admin, contr : address * contrRendu) =
    callBis(Add_admin(admin), contr)

let participate(contr : contrRendu) =
    callBis(Participate(), contr)


let accept_admin(admin, contr : address * contrRendu) =
    callBis(Accept_admin(admin), contr)


//let call_increment_success (p) =
//    assert(tx_success(p))