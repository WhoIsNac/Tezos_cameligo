import { buf2hex } from "@taquito/utils";
import { InMemorySigner } from "@taquito/signer";
import { MichelsonMap, TezosToolkit } from "@taquito/taquito";
import code from "../src/compiled/main.json";
import dotenv from "dotenv";
import metadata from "./metadata/main.json";
import path from "path";

// Read environment variables from .env file
dotenv.config({ path: path.join(__dirname, "..", ".env") });

// Initialize RPC connection
const Tezos = new TezosToolkit(process.env.NODE_URL || "");



const deploy = async () => {
    try {
        const signer = await InMemorySigner.fromSecretKey(process.env.ADMIN_SK || "");
        const admin: string = await signer.publicKeyHash();
        Tezos.setProvider({ signer });

        const storage = 0;
        
        new MichelsonMap();
       

        const op = await Tezos.contract.originate({ code, storage });
        await op.confirmation();
        console.log(`[OK] Token FA2: ${op.contractAddress}`);
        // check contract storage with CLI
        console.log(`tezos-client --endpoint http://localhost:20000 get contract storage for ${op.contractAddress}`);
    } catch (e) {
        console.log(e);
    }
};

deploy();