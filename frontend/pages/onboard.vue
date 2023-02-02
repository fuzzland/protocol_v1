<template>
  <div class="background">
    <div class="body">
      <!--    <nav>FuzzLand</nav>-->

      <div class="slogan">
        <div v-if="step === 1">
          <h1 style="font-size: 3em; font-weight: 200">Share Your Project</h1>
          <div style="display: flex; justify-content: space-between">
            <div style="width: 100%">
              <el-form ref="form" :model="form">
                <el-form-item label="Project Name">
                  <el-input v-model="form.name"></el-input>
                </el-form-item>

                <el-form-item label="Contact Email / Telegram / WeChat">
                  <el-input v-model="form.contact"></el-input>
                </el-form-item>

                <el-form-item label="Additional Information (Optional)">
                  <el-input type="textarea" v-model="form.description"></el-input>
                </el-form-item>
              </el-form>
            </div>
            <div style="margin-left: 30px">
              <el-upload
                drag
                :action="upload_endpoint"
                :http-request="upload"
                :limit="1"
                :on-remove="handleRemove"
                multiple>
                <i class="el-icon-upload"></i>
                <div class="el-upload__text">Drag file into the box or <em>click to upload</em></div>
                <div class="el-upload__tip" slot="tip">Compiled Contract. Upload a zip of *.bin, *.abi, and *.sol files. <a href="#">Help</a></div>
              </el-upload>
            </div>
          </div>


          <div class="button" @click="get_price">Next </div>

        </div>


        <div v-if="step === 2">

          <h1 style="font-size: 3em; font-weight: 200">Select Bounty</h1>
          <el-alert
            title="Contract Information"
            type="success"
            style="margin-bottom: 30px"
            :description="contract_info()">
          </el-alert>
          <div style="display: flex; justify-content: space-between; margin-bottom: 40px; ">
            <div class="comm" style="text-align: center; border-radius: 10px; margin: 0; cursor:pointer;"
                 :class="audit_length === 3 ? 'comm-active' : ''"
                 @click="select_bounty(3)">
              <h2 style="font-weight: 100; font-size: 2em">${{calc_price(3, manual_def, manual_inspection)}}</h2>
              <p>Finishes in <strong>3</strong> days.</p>
            </div>

            <div class="comm" style="text-align: center; border-radius: 10px; margin: 0; cursor:pointer;"
                 :class="audit_length === 7 ? 'comm-active' : ''"
                 @click="select_bounty(7)">
              <h2 style="font-weight: 100; font-size: 2em">${{calc_price(7, manual_def, manual_inspection)}}</h2>
              <p>Finishes in <strong>7</strong> days.</p>
            </div>

            <div class="comm" style="text-align: center; border-radius: 10px; margin: 0; cursor:pointer;"
                 :class="audit_length === 14 ? 'comm-active' : ''"
                 @click="select_bounty(14)">
              <h2 style="font-weight: 100; font-size: 2em">${{calc_price(14, manual_def, manual_inspection)}}</h2>
              <p>Finishes in <strong>14</strong> days.</p>
            </div>


          </div>
          <div style="margin-bottom: 30px">
            <el-checkbox v-model="manual_inspection">Require Manual Inspection</el-checkbox>
            <el-checkbox v-model="manual_def">Require Manual Oracle Definition</el-checkbox>
          </div>

          <div class="button" @click="get_accepted_bounty();">Next </div>
          <div class="button" @click="step -= 1">Back </div>


        </div>
        <div v-if="step === 3">
          <h1 style="font-size: 3em; font-weight: 200">Confirmation</h1>
          <div>
            <h3>Project Name</h3>
            <p>{{form.name}}</p>

            <h3>Contact</h3>
            <p>{{form.contact}}</p>

            <h3>Additional Information</h3>
            <p>{{form.description}}</p>
            <p>
              {{manual_inspection ? 'Needs manual inspection.' : ''}}
              {{manual_def ? 'Needs manual oracle definition.' : ''}}
            </p>

            <h3>Contract</h3>
            {{contract_info()}}

            <h3>Price</h3>
            ${{bounty_accepted}}

            <h3>Audit Time Length</h3>
            {{audit_length}} days
            <br>
            <br>
          </div>

          <div class="button" @click="submitOnboardTxn">Onboard Project</div>
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
import {IPFS_GW_API,PRICE_ESTIMATOR, protocol_address, token_address} from "../../const"
import pages from "~/pages/index";
const DOMAIN = "localhost:4000";
export default {
  name: 'IndexPage',
  data() {
    return {
      step: 1,
      checked: true,
      form: {
        name: '',
        contact: '',
        description: ''
      },
      upload_endpoint: IPFS_GW_API,
      file: "",
      bounty: 20,
      bounty_accepted: 0,
      audit_length: 0,
      bounty_info: [],
      manual_inspection: true,
      manual_def: false,
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
      slack: "https://hooks.slack.com/services/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",
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
      const toBase64 = file => new Promise((resolve, reject) => {
        const reader = new FileReader();
        reader.readAsDataURL(file);
        reader.onload = () => resolve(reader.result);
        reader.onerror = error => reject(error);
      });
      console.log((await toBase64(data.file)).split("base64,")[1])
      const requestOptions = {
        method: "POST",
        headers: { "FuzzLand-Source": "Onboarding" },
        body: (await toBase64(data.file)).split("base64,")[1]
      };
      const response = await fetch(`${IPFS_GW_API}`, requestOptions);
      const result = await response.json();
      this.file = result.cid;
    },
    async get_price() {
      if (!this.form.name) {
        alert("Please enter the project name.")
        return
      }
      if (!this.form.contact) {
        alert("Please enter the contact information.")
        return
      }
      if (!this.file) {
        alert("Please upload the contracts.")
        return
      }
      const load = this.$loading()
      fetch(`${PRICE_ESTIMATOR}/${this.file}`)
        .then(response => response.json())
        .then(data => {
          load.close()
          if (!data.success) {
            alert("Failed to get price, please try again later.")
          } else {
            this.bounty = data.cost ** 1.2
            this.bounty_info = data.data;
            this.step += 1
          }
        });
    },

    select_bounty(days) {
      this.audit_length = days;
      this.bounty_accepted = this.calc_price(days, this.manual_def, this.manual_inspection);
    },

    get_accepted_bounty() {
      if (this.audit_length === 0) {
        alert("Please select the audit time length.")
      }
      this.bounty_accepted = this.calc_price(this.audit_length, this.manual_def, this.manual_inspection);
      this.step += 1;
    },

    async handleRemove(file, fileList) {
      this.file = "";
    },

    async submitOnboardTxn() {
      let info = `Name: ${this.form.name}\nContact: ${this.form.contact}\nDescription: ${this.form.description}\nFiles: ${this.file}\nLength: ${this.audit_length}\nBounty: ${this.bounty_accepted}`
      await fetch(`${this.slack}`, {
        method: "POST",
        headers: {"Content-Type": "application/x-www-form-urlencoded"},
        body: JSON.stringify({
          text: "============== Potential User ==============\n" + info
        })
      })
      let loader = this.$loading({
        fullscreen: true,
        text: 'Connecting wallet...',
        lock: true
      })
      try {

        if (!this.connected) await this.connect();
        if (!this.connected) return;
        //
        // loader.text = "Creating USDC transfer transaction..."
        // const BN = this.web3.utils.BN;
        // const needed = BN(this.web3.utils.toWei(this.bounty_accepted, "ether"));
        // await this.token.transfer("0x3a2a700d9d822D23D3F0F55F4b097753b5B2FC9A", needed)
        loader.text = 'Approving FUZL balance for FuzzLand protocol...'
        const BN = this.web3.utils.BN;
        const needed = BN(this.web3.utils.toWei("1000000000000000", "ether"));
        let allowance = BN(await this.token.allowance(this.web3.currentProvider.selectedAddress, protocol_address));
        if (allowance.cmp(needed) === -1) {
          console.log("need to approve")
          await this.token.approve(protocol_address, needed.toString())
        }
        loader.text = 'Creating onboarding transaction...'
        const project_deploy_info = await this.protocol.AddProject(
          this.file,
          this.web3.utils.toWei(`${this.bounty_accepted}`, "ether"),
          true,
          "",
          "",
          this.form.name
        );
        info += "\n============== Confirmed ================\n" + info + "\nProject ID: " + project_deploy_info.events.ProjectDeployed.returnValues[0];
        await fetch(`${this.slack}`, {
          method: "POST",
          headers: {"Content-Type": "application/x-www-form-urlencoded"},
          body: JSON.stringify({
            text: info
          })
        })
        loader.close();
        alert("Success! If you do not receive a confirmation email in 24 hours, please contact us at q@fuzz.land");
        window.location.href = "/"

      } catch (e) {
        console.log(e)
        loader.close();
        alert("Failed to transfer USDC, please try again later.")
      }

    },

    calc_price(day, manual_def, manual_inspection) {
      let price = this.bounty / day;
      if (manual_def) price *= 1.8;
      if (manual_inspection) price *= 1.5;
      return price.toFixed(2);
    },
    contract_info() {
      return this.bounty_info.map(v => {
        return `${v["file"]}: ${0} oracles, ${v["cf_instructions"]} control flows, ${v["instructions"]} instructions`
      }).reduce((a,b) => a + "\n" + b)
    },

    debug() {
      console.log(this.file, this.form)
    },

  },
  watch: {

  }
}
</script>

<style>
@import url('https://fonts.googleapis.com/css2?family=Open+Sans:ital,wght@0,300;0,400;0,500;0,600;0,700;0,800;1,300;1,400;1,500;1,600;1,700;1,800&display=swap');
.background {}

  .body {
    padding: 0 30px;
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

.comm {
  width: 25%;
  background: linear-gradient(31.37deg,#fff 1.13%,rgba(255,255,255,0) 100%);
  margin: 15px;
  border: 2px solid #f0f3fb;
  border-radius: 24px;
  padding: 50px 25px;
}

.comm-active {
  background: #333;
  border: 2px solid #333;
  color: #fff;
}

</style>
<style>
.el-loading-text {
  color: #192a56 !important;
}



.el-loading-spinner .path {
  stroke: #192a56 !important;
}

</style>
