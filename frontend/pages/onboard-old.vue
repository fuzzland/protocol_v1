<template>
  <div class="background">
    <div class="body">
      <!--    <nav>FuzzLand</nav>-->

      <div class="slogan">
        <div v-if="step === 1">
          <h1 style="font-size: 5em"><label class="project-type">Step {{ step }}</label> Compile & Package</h1>
          <h2 style="font-size: 2em; font-weight: 100">Run following command in folder with Solidity contracts (Docker)</h2>
          <div class="terminal space shadow">
            <div class="top">
              <div class="btns">
                <span class="circle red"></span>
                <span class="circle yellow"></span>
                <span class="circle green"></span>
              </div>
              <div class="title">Shell</div>
            </div>
            <div style="overflow-x: scroll" class="shell-body">
              <pre class="shell-area">
<label style="color: #ccc">// setup FuzzLand CLI</label>
$ <strong>docker</strong> pull fuzzland/cli

<label style="color: #ccc">// generate code for onboarding</label>
$ <strong>docker</strong> run -v <em>[FOLDER CONTAINER CONTRACT]</em>:/code fuzzland/cli onboard /code</pre>
            </div>
          </div>
          <br>
          <div style="color: #666">For starting from pre-built binary, please refer to <a href="https://docs.fuzz.land/miner" style="color: #666; text-underline-offset: 4px">docs</a>.</div>
          <br>
          <div class="button" @click="step += 1">Next </div>

        </div>


        <div v-if="step === 2">
          <h1 style="font-size: 5em"><label class="project-type">Step {{ step }}</label> Onboard to Chain</h1>
          <h2 style="font-size: 2em; font-weight: 100">Paste the output of previous command.</h2>
          <textarea style="margin-bottom: 10px" placeholder="eJxxxxxx..." v-model="onboarding_data"></textarea>
          <div class="button" @click="parse(onboarding_data)">Next </div>
          <div class="button" @click="step -= 1">Back </div>
<!--          <div class="button" @click="connect">Test </div>-->
<!--          <div class="button" @click="submitOnboardTxn">Test 2</div>-->

        </div>
        <div v-if="step === 3">
          <h1 style="font-size: 5em"><label class="project-type">Step {{ step }}</label> Reward</h1>
          <h2 style="font-size: 2em; font-weight: 100">Set what you want to pay for the miners. </h2>
          <div>
            <label style="font-size: 1.3em">Total bounty (in FUZL token)</label>
            <input style="margin: 15px 0 15px 0" v-model="bounty"></input>
            <label style="font-size: 1.3em">Project Nickname</label>
            <input style="margin: 15px 0 15px 0" v-model="project_name"></input>
          </div>

          <div style="display: flex; justify-content: left">
            <input type="checkbox" id="vehicle1" name="vehicle1" value="Bike" v-model="is_implicit" style="height: 0.92em; width: 0.92em; margin-right: 10px; margin-bottom: 15px;">
            <label style="font-size: 1.3em" for="vehicle1">Allow rewarding new testcase finding</label>
          </div>

          <table style="width: 100%">
            <tr>
              <th>Vulnerability Name</th>
              <th>Reward Allocation</th>
              <th>Reward Paid if Found</th>
            </tr>
            <tr v-for="name in oracles" :key="name" v-if="form_updated">
              <td>{{ name }}</td>
              <td><input class="input-in-form" v-model="oracles_allocation[name]" v-bind:placeholder="remaining_percentage / remaining_unset"
                         v-bind:max="remaining_percentage" min="0" type="number"/>%</td>
              <td>{{ (oracles_allocation[name] || remaining_percentage / remaining_unset) / 100 * bounty }} FuZL</td>
            </tr>

          </table>

          <div class="button" @click="submitOnboardTxn">Create Onboard Transaction </div>
          <div class="button" @click="step -= 1">Back </div>

        </div>
      </div>
    </div>
  </div>

</template>

<script>
import Web3 from 'web3'
import Protocol from "../../contracts/protocols/protocol";
import Token from "../../contracts/protocols/token";
import {IPFS_GW_API, protocol_address, token_address} from "../../const"
import pages from "~/pages/index";
const DOMAIN = "localhost:4000";
export default {
  name: 'IndexPage',
  data() {
    return {
      step: 1,
      checked: true,
      bounty: 20,
      connected: false,
      web3: null,
      protocol: null,
      token: null,
      // demo_data: "eyJmIjoiUW1XMUxkSFFENmJjZHFZdTNoU3JHeGlaUXczSll5ZFhOUTlKTW5aYUpSN3EyUiIsInRjIjoiUW1XMUxkSFFENmJjZHFZdTNoU3JHeGlaUXczSll5ZFhOUTlKTW5aYUpSN3EyUiIsIm9yYWNsZXMiOlsibGlnaHRmdXp6XzEiXX0=",
      oracles: [],
      oracles_allocation: {},
      testcase_cid: "",
      reward_cid: "",
      program_cid: "",
      remaining_percentage: 100,
      remaining_unset: 0,
      form_updated: true,
      is_implicit: true,
      onboarding_data: "",
      project_name: "N/A",
    }
  },
  mounted() {
    if (typeof window.ethereum !== 'undefined') {
      console.log('MetaMask is installed!');
    } else {
      console.log('MetaMask is not installed!');
    }
  },
  methods: {
    async connect() {
      if (window.ethereum) {
        this.web3 = new Web3(window.ethereum);
        try {
          window.ethereum.enable().then(() => {
            this.connected = true
          });
        } catch (e) {
          alert("User has denied account access to DApp...");
        }
      }
      // Legacy DApp Browsers
      else if (window.web3) {
        this.web3 = new Web3(window.web3.currentProvider);
        this.connected = true
      }
      // Non-DApp Browsers
      else {
        alert('Non-Ethereum browser detected. You should consider trying MetaMask!');
        return
      }
      this.protocol = new Protocol(this.web3, protocol_address)
      await this.protocol.init()
      this.token = new Token(this.web3, token_address)
      await this.token.init()
    },
    parse(data) {
      try {
        let d = JSON.parse(atob(data));
        this.testcase_cid = d.tc;
        this.program_cid = d.f;
        this.oracles = d.oracles;
        this.remaining_unset = this.oracles.length
        this.oracles.forEach(v => {
          this.oracles_allocation[v] = this.remaining_percentage / this.remaining_unset;
        })
        console.log(this.oracles)
        this.step += 1;
      } catch (e) {
        alert("Failed to verify the data, please check the data again.")
      }


    },
    async upload(data) {
      const requestOptions = {
        method: "POST",
        headers: { "FuzzLand-Source": "Onboarding" },
        body: data
      };
      const response = await fetch(`${IPFS_GW_API}`, requestOptions);
      const result = await response.json();
      return result.cid;
    },

    async submitOnboardTxn() {
      console.log("submitOnboardTxn");
      let loader = this.$loading({
        fullscreen: true,
        text: 'Connecting wallet...',
        lock: true
      })
      this.reward_cid = await this.upload(JSON.stringify(this.oracles_allocation));
      if (!this.connected) await this.connect();
      if (!this.connected) return;
      console.log(this.protocol)
      loader.close();
      loader = this.$loading({
        fullscreen: true,
        text: 'Approving FUZL balance for FuzzLand protocol...',
        lock: true
      })
      const BN = this.web3.utils.BN;
      const needed = BN(this.web3.utils.toWei("1000000000000000", "ether"));
      let allowance = BN(await this.token.allowance(this.web3.currentProvider.selectedAddress, protocol_address));
      if (allowance.cmp(needed) === -1) {
        console.log("need to approve")
        await this.token.approve(protocol_address, needed.toString())
      }
      loader.close();
      loader = this.$loading({
        fullscreen: true,
        text: 'Waiting for onboarding transaction confirmation & broadcast...',
        lock: true
      })
      const project_deploy_info = await this.protocol.AddProject(
        this.program_cid,
        this.web3.utils.toWei(`${this.bounty}`, "ether"),
        this.is_implicit,
        this.testcase_cid,
        this.reward_cid,
        this.project_name
      );
      loader.close();
      window.location.href = `/project/?id=${project_deploy_info.events.ProjectDeployed.returnValues[0]}`
    }

  },
  watch: {

  }
}
</script>

<style>
@import url('https://fonts.googleapis.com/css2?family=Open+Sans:ital,wght@0,300;0,400;0,500;0,600;0,700;0,800;1,300;1,400;1,500;1,600;1,700;1,800&display=swap');
.background {}

  .body {
    padding: 0 100px;
    max-width: 1500px;
    margin: 0 auto;
  }
  .slogan {
    margin: 20vh auto 0 auto;
  }
  .button {
    border-width: 1px;
    border-style: solid;
    width: max-content;
    padding: 8px 15px;
    border-radius: 5px;
    display: inline-block;
    cursor: pointer;
  }
  .slogan-button {
    font-size: 1.2em;
  }
  .button-dark {
    background: #333;
    border-width: 1px;
    border-color: #333333;
    color: #fff;
  }
  .project-type {
    background: #333333;
    color: #fff;
    padding: 3px 10px;
  }

.terminal {
  border-radius: 5px 5px 0 0;
  position: relative;
}
.terminal .top {
  background: #E8E6E8;
  color: black;
  padding: 5px;
  border-radius: 5px 5px 0 0;
}
.terminal .btns {
  position: absolute;
  top: 7px;
  left: 5px;
}
.terminal .circle {
  width: 12px;
  height: 12px;
  display: inline-block;
  border-radius: 15px;
  margin-left: 2px;
  border-width: 1px;
  border-style: solid;
}
.title{
  text-align: center;
}
.red { background: #EC6A5F; border-color: #D04E42; }
.green { background: #64CC57; border-color: #4EA73B; }
.yellow{ background: #F5C04F; border-color: #D6A13D; }
.clear{clear: both;}

.shell-area {
  font-size: 1.5em;
  padding: 0 20px 20px 20px;
}

.space {
}
.shadow { box-shadow: 0px 0px 10px rgba(0,0,0,.2)}

textarea {
  width: 100%;
  height: 10em;
  font-size: 1.5em;
  border-radius: 6px;
}

input {
  width: 100%;
  font-size: 1.5em;
  font-family: 'Open Sans', sans-serif;
}

table {
  font-family: 'Open Sans', sans-serif;
  font-size: 1em;
  border-collapse: collapse;
  width: 100%;
  margin: 15px 0;
}

td, th {
  border: 1px solid #dddddd;
  text-align: left;
  padding: 8px;
}

.input-in-form {
  border-width: 0;
  width: max-content;
  font-size: 1em;
  outline: #000;
}

.shell-body::-webkit-scrollbar { display: none; }



</style>
<style>
.el-loading-text {
  color: #192a56 !important;
}

.el-loading-spinner .path {
  stroke: #192a56 !important;
}

</style>
