#import "./helpers/bootstrap.mligo" "Bootstrap"
#import "./helpers/helpers.mligo" "Helper"






  // Le test fonctionne :)
  let test_succesful_add = 
    let account = Bootstrap.boot_accounts(Tezos.get_now()) in
    let (_, taddrRendu, contrRendu) = Bootstrap.originate_contractRendu1(Bootstrap.base_storageBis) in
    let () = Test.set_source(account.0) in
    let result = Helper.add_admin(Tezos.get_sender(),contrRendu) in
    let modified_storage = Helper.get_storageBis(taddrRendu) in
    let () = Test.println(Test.to_string(modified_storage)) in
    assert(modified_storage = Bootstrap.base_storageBis)




let participate = 
    let accounts = Bootstrap.boot_accounts(Tezos.get_now()) in
    let (_, _taddr, contr) = Bootstrap.originate_contractRendu1(Bootstrap.base_storageBis) in
    Helper.participate(contr)