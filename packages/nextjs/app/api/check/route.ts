
import { RpcProvider, Account ,Contract} from "starknet";
const provider = new RpcProvider({
    nodeUrl:
      "https://rpc.nethermind.io/sepolia-juno/?apikey=PETeVhMzQLpuJgd14RQDSMit7gVjhctsrwQb6dxsURxj0cd0",
  });

  const privateKey0 =
  "0x044839fa45d8de50f6908b10e30adcaafe4424a54fa32e5492bdeb9e37f0544f";
const account0Address: string =
  "0x0044A4bE0225bDa4199337D7910374b512fedd65E5B7a366035FdC3268C349C6";
const account0 = new Account(provider, account0Address, privateKey0);
const contractAddress =
  "0x03b9D200f3E7569D122aA3114639B36E537DF9Fa6C275E68f0F7E6757c37D73f";

  function toHex(input: number | string): string {
    if (typeof input === "number") {
      return "0x" + input.toString(16);
    } else if (typeof input === "string") {
      return "0x" + Array.from(input)
        .map((char) => char.charCodeAt(0).toString(16))
        .join('');
    } else {
      throw new TypeError("Input must be a number or a string");
    }
  }
  

  export async function POST(req: Request) {
    const formdata = await req.formData();
    const addr = String(formdata.get("addr")) ? String(formdata.get("addr")) : "";
  
  console.log(addr);
    if ( addr) {
        
        const ABIdata =await provider.getClassAt(contractAddress)
        const contract = new Contract(ABIdata.abi,contractAddress,provider)
        contract.connect(account0)
        const balance = await contract.get_balance(addr)
     console.log(balance)
      return new Response(JSON.stringify((Number(balance)*10**-18)), { status: 200 });
    }
  
    return new Response(JSON.stringify({ error: "Invalid request" }), { status: 400 });
  }