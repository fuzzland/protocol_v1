<template>
  <div class="background">
    <div class="body">
      <!--    <nav>FuzzLand</nav>-->

      <div class="slogan">

        <div>
          <h1 style="font-size: 5em"><label class="project-type">Project #{{ project_id }}</label></h1>
          <div class="card">
            <h1 style="font-weight: 100">Auditing Power</h1>
            <line-chart
              style="height: 300px; "
              :chart-options='chartOptions'
              :chart-data='to_plot_data([project.cumulative_comp, project.cumulative_heartbeats])'
              chart-id='myCustomId'
            />
          </div>

          <div class="card">
            <h1 style="font-weight: 100">Vulnerabilities</h1>
            <div v-for="v in vulns">
              <div style="font-size: 1.3em">#{{v.nftId}} violates <strong> {{ v.data.oracle_name }}</strong></div>
              <div>
                <label style="font-size: 1.3em">Details:</label>
              </div>
              <div>
                <textarea disabled style="height: 120px; font-size: 1em; border: 0">{{ v.data.txn }}</textarea>
              </div>
            </div>
          </div>

          <div class="card">
            <h1 style="font-weight: 100">Info</h1>
            <div >
              <div>
                <label style="font-size: 1.3em">Reward Splitting</label>
                <table style="width: 100%">
                  <tr>
                    <th>Vulnerability Name</th>
                    <th>Reward Allocation</th>
                    <th>Reward Paid if Found</th>
                  </tr>
                  <tr v-for="(pct, name) in splittings" :key="name">
                    <td>{{ name }}</td>
                    <td>{{ pct }}%</td>
                    <td>{{ pct * parseInt(project.reward) / 1e20 }} FuZL</td>
                  </tr>

                </table>
              </div>
              <div>
                <label style="font-size: 1.3em">Program Content</label>
                <pre>IPFS Hash: {{ project["ipfsHash"] }}</pre>

                <textarea style="font-size: 1em; border: 0" disabled>{{ hex2a(project_content) }}</textarea>
              </div>

              <div>
                <label style="font-size: 1.3em">Owner</label>
                <pre>{{ project["owner"] }}</pre>
              </div>
            </div>
          </div>

          <div class="card">
            <h1 style="font-weight: 100">Actions <label style="color: #aaa">(Owners Only)</label></h1>

            <label style="font-size: 1.3em">Update Program</label>
            <div style="display: flex; margin-top: 10px">
              <input></input><button class="button button-dark">Submit</button>
            </div>
            <br>

            <label style="font-size: 1.3em">Offboard Project</label>
            <div style="display: flex; margin-top: 10px">
              <button class="button button-dark">Offboard</button>
            </div>
          </div>


        </div>
      </div>
    </div>
  </div>

</template>

<script>
import Web3 from 'web3'
import Protocol from "../../contracts/protocols/protocol";
import Token from "../../contracts/protocols/token";
import pages from "~/pages/index";
import {IPFS_GW_API, STATS_API_URL, token_address} from "../../const";
export default {
  name: 'IndexPage',
  data() {
    return {
      step: 1,
      current_project_type: "Web3",
      idx: 0,
      project: {},
      appear: true,
      project_content: "",
      splittings: {},
      project_id: 0,
      vulns: [],
      chartOptions: {
        layout: { autoPadding: true },
        hover: { intersect: false },
        backdropPadding: 0,
        padding: 0,
        plugins: {
          legend: {
            display: true,
          },
          tooltip: {
            caretPadding: 10,
            caretX: 0,
            caretY: 0,
            intersect: true,
            mode: 'index',
            yAlign: 'center',
            position: 'nearest',
            callbacks: {
              label: (item) => {
                return `${item.dataset.label}: ${item.parsed.y}`
              },
            },
            displayColors: false,
            padding: 3,
            pointHitRadius: 5,
            pointRadius: 1,
            caretSize: 10,
            backgroundColor: 'rgba(255,255,255,.9)',
            borderWidth: 1,
            bodyFont: {
              family: 'Inter',
              size: 12,
            },
            bodyColor: '#303030',
            titleFont: {
              family: 'Inter',
            },
            titleColor: 'rgba(0,0,0,0.6)',
          },
        },
        elements: {
          line: {
            tension: 0.15
          }
        },
        scales: {
          y: {
            ticks: {
              display: true,
            },
            grid: {
              drawBorder: true,
              borderWidth: 0,
              drawTicks: true,
              color: 'transparent',
              width: 0,
              backdropPadding: 0,
            },
            drawBorder: true,
            drawTicks: true,
          },
          x: {
            ticks: {
              display: true,
            },
            grid: {
              drawBorder: false,
              borderWidth: 0,
              drawTicks: false,
              display: false,
            },
          },
        },
        responsive: true,
        maintainAspectRatio: false,
      },
    }
  },
  mounted() {
    this.project_id = parseInt(window.location.href.split("?id=").pop());
    this.load_program();
  },
  methods: {
    async load_program(){
      const loader = this.$loading({
        fullscreen: true,
        text: 'Waiting for the transaction to be confirmed...',
        lock: true
      })
      while (true) {
        const data = await fetch(`${STATS_API_URL}/project/${this.project_id}`);
        let json = {};
        try {
          json = await data.json();
        } catch (e) {
          console.log(e);
          await new Promise(r => setTimeout(r, 1000));
          continue;
        }
        this.project = json;
        console.log(json);
        await this.load_project_content();
        loader.close();
        break;
      }
    },

    hex2a(hexx) {
      let hex = hexx.toString();//force conversion
      let str = '';
      for (let i = 0; i < hex.length; i += 2)
        str += String.fromCharCode(parseInt(hex.substr(i, 2), 16));
      return str;
    },
    async load_project_content(){
      this.project_content = await this.get_from_ipfs(this.project.ipfsHash);
      this.splittings = JSON.parse(await this.get_from_ipfs(this.project.splittings));
      this.vulns = []
      for (const k in this.project.vulns) {
        const v = this.project.vulns[k];
        this.vulns.push({
          reward: v.rewards / 1e20,
          data: JSON.parse(await this.get_from_ipfs(v.ipfsHash)),
          nftId: k
        });
      }

      console.log(this.vulns)


    },
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
      await this.token.init();
    },
    async get_from_ipfs(cid) {
      const data = await fetch(`${IPFS_GW_API}/${cid}`).then(response => response.json());
      if (data.success) {
        return data.data;
      }
      return null;
    },

    async submitOnboardTxn() {
      console.log("submitOnboardTxn");
      this.reward_cid = await this.upload(JSON.stringify(this.oracles_allocation));
      if (!this.connected) await this.connect();
      if (!this.connected) return;
      console.log(this.protocol)
      const BN = this.web3.utils.BN;
      const needed = BN(this.web3.utils.toWei("1000000000000000", "ether"));
      let allowance = BN(await this.token.allowance(this.web3.currentProvider.selectedAddress, protocol_address));
      if (allowance.cmp(needed) === -1) {
        console.log("need to approve")
        await this.token.approve(protocol_address, needed.toString())
      }
      const project_deploy_info = await this.protocol.AddProject(
        this.program_cid,
        this.web3.utils.toWei(`${this.bounty}`, "ether"),
        this.is_implicit,
        this.testcase_cid,
        this.reward_cid
      );
      console.log(project_deploy_info.events.ProjectDeployed.returnValues[0])
    },
    to_plot_data(data_list) {

      let datasets = [];
      let labels = [];

      let first = true;
      let index = 0;
      let colors = ['#ffeaa7', '#fab1a0'];
      let labels_name = ['Comp', 'Heartbeat'];
      const width = 20;

      data_list.forEach(data => {
        let dataset = [];
        for (const key in data) {
          if (first) labels.push(key);
          dataset.push(data[key]);
        }
        first = false;
        datasets.push({
          data: dataset,
          minBarLength: width,
          barThickness: width * 0.75,
          borderRadius: width * 0.75 * 2,
          backgroundColor: colors[index],
          borderColor: colors[index],
          pointRadius: 0,
          borderSkipped: false,
          label: labels_name[index],
          lineTension: 0.4
        })
        index++;
      })

      return {
        labels: labels,
        datasets
      }
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
    font-family: 'Open Sans', sans-serif;
    font-weight: 600;
    font-size: 1.1em;
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


.card {
  background: #fff;
  border-radius: 5px;
  box-shadow: rgba(0, 0, 0, 0.05) 0px 0px 0px 1px;
  padding: 40px;
  margin: 20px 0;
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
