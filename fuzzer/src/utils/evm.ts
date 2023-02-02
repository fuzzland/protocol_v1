import {EVM, InterpreterStep} from "@ethereumjs/evm";
import {EEI} from "@ethereumjs/vm";
import {Chain, Common, Hardfork} from "@ethereumjs/common";

type dag_t = {src: number, dst: number}[];
let shared_dag: dag_t = [];
const peek_back = (arr: any[], idx: number = 0) => {
    return arr[arr.length - idx - 1];
}

let EVM_cache: EVM | null = null;
const get_EVM = async (eei: EEI, custom: undefined | ((data: InterpreterStep) => void)[] = undefined) : Promise<EVM> => {
    if (!EVM_cache) {
        const common = new Common({ chain: Chain.Mainnet, hardfork: Hardfork.London })
        EVM_cache = new EVM({
            common,
            eei,
        })

        if (custom) {
            custom.map((cb) => {
                EVM_cache?.events.on('step', cb);
            })
        }
        EVM_cache.events.on('step', function (data) {
            // https://ethereum.github.io/execution-specs/autoapi/ethereum/dao_fork/vm/instructions/control_flow/index.html
            if (data.opcode.name == "JUMPI") {
                shared_dag.push({
                    src: data.pc, dst: peek_back(data.stack, 1) ? parseInt(peek_back(data.stack).toString()) : data.pc + 1,
                });
            }
            // console.log(`Opcode: ${data.opcode.name}\tStack: ${data.stack}\t${data.pc}`)
        })

    }
    EVM_cache.eei = eei
    return EVM_cache
}


const reset_shared_dag = () : void => {
    shared_dag = [];
}

const get_shared_dag = () : dag_t => {
    return shared_dag;
}

export {get_EVM, reset_shared_dag, get_shared_dag, dag_t};