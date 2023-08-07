#import "./FA2_NFT.mligo" "NFT_FA2"
#import "fa2_storage.mligo" "NFT_FA2_Storage"


type collection = address * address
type collection_list = collection list

type storage = {
    admin_map: (address,bool) map;
    black_list: (address,bool) map;
    white_list: (address,bool) map;
    collections: collection_list;
}


type collectionContract = address
type collectionOwner = address

type generate_collection_param = {
    name : string;
    token_ids : nat list;
}
// j'utilise ce type au lieu de celui au dessus pour plus de simplicité
type create_collection_param = unit


type ext_storage = NFT_FA2_Storage.t
type lambda_create_contract = (key_hash option * tez * ext_storage) -> (operation * address) 


let initial_storage () = {
    all_collections = (Big_map.empty : (collectionContract, collectionOwner) big_map);
    owned_collections = (Big_map.empty : (collectionOwner, collectionContract list) big_map);
    metadata = (Big_map.empty : (string, bytes) big_map);
}


type action =
  Add_admin of address
| Delet_admin of address
| Accept_admin of address
| Black_listUser of address
| Create_collection of create_collection_param * storage
| Participate
| Reset of unit 



type return = operation list * storage

let assert_admin(store: storage)  =

 match Map.find_opt (Tezos.get_sender()) store.admin_map with
    | Some _ -> ()
    | None -> failwith "Not an admin"



let assert_blacklist(store: storage) =

 match Map.find_opt (Tezos.get_sender()) store.black_list with
    | Some _ -> ()
    | None -> failwith "Not in blacklist"



let assert_whitelist(store: storage) =

 match Map.find_opt (Tezos.get_sender()) store.white_list with
    | Some _ -> ()
    | None -> failwith "Not in whitelist"



let add_admin (admin,store: address * storage) = 
  let admin_map = store.admin_map in
  let adminmap = Map.add admin false store.admin_map in
    { store with admin_map = adminmap }

let delet_admin (admin,store: address * storage) = 
  let admin_map = store.admin_map in
  let adminmap = Map.remove admin store.admin_map in
    { store with admin_map = adminmap }


let accept_admin (admin,store: address * storage) = 
  let sender = Tezos.get_sender() in
  let x = match Map.find_opt (Tezos.get_sender()) store.admin_map with
    | Some _ -> Map.add sender true store.admin_map 
    | None -> failwith "Why no admin" in
  { store with admin_map = x }


let black_listUser (user,store: address * storage) = 
  let black_list = store.black_list in
  let blacklist = Map.add user true store.black_list in
    { store with black_list = blacklist }


let participate (store: storage) = 
  let amount : tez = Tezos.get_amount() in
  let sender = Tezos.get_sender() in
  if amount >= 10tz then
    let white_list = store.white_list in
    let whitelist = Map.add sender true store.white_list in
    { store with white_list = whitelist }
  else
    failwith "Not enough tez"

let create_collection(_create_collection_param, store : create_collection_param * storage) : storage =
  let sender = Tezos.get_sender() in
	let initial_storage: ext_storage = {
		ledger = Big_map.empty;
		token_metadata = Big_map.empty;
		operators = Big_map.empty;
		metadata = Big_map.empty;
	} in
  let create_my_contract () : (operation * address) =
    [%Michelson ( {| {
          UNPAIR ;
          UNPAIR ;
          CREATE_CONTRACT
#include "./FA2_NFT.tz"
              ;
          PAIR } |}
            : lambda_create_contract)] ((None : key_hash option), 0tez, initial_storage)
  in
  let originate : operation * address = create_my_contract() in
  let collections : collection list = (sender, originate.1) :: store.collections in
  {store with collections }
  

  let main(action,store: action * storage) : return =
    (([] : operation list),(
      match action with
      | Add_admin(admin) -> add_admin(admin,store)
      | Delet_admin(admin) -> delet_admin(admin,store)
      | Accept_admin(admin) -> accept_admin(admin,store)
      | Black_listUser(user) -> black_listUser(user,store)
      | Create_collection _ -> create_collection((),store)
      | Participate -> participate(store)
      | Reset -> { admin_map = Map.empty; black_list = Map.empty; white_list = Map.empty; collections = [] }
    ))