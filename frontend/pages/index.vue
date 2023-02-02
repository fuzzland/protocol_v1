<template style="margin: 0">
  <div class="background">
    <div class="body">
      <!--    <nav>FuzzLand</nav>-->

      <div class="slogan">
        <h1 style="font-size: 5em;">Let <label class="project-type">Everyone</label> Audits for Your Next
          <typewriter
            :speed="300"
            :full-erase="true"
            :interval="800"
            :words="this.projects" style="font-weight: bold">
          </typewriter>Project



        </h1>
        <h2 style="font-size: 3em; font-weight: 100">A decentralized protocol for automated auditing.</h2>

        <div class="button slogan-button" @click="redirect('https://docs.fuzz.land/miner')">Run Miner</div>
        <div class="button slogan-button button-dark" @click="onboard()">Audit a Project</div>
        <div style="margin-top: 15px;">
          <a style=" font-size: 1.2em; color: #666; text-underline-offset: 4px;" href="https://docs.fuzz.land">Read the Docs</a> <label style="font-size: 1em; color: #ccc">/</label>
          <a style=" font-size: 1.2em; color: #666; text-underline-offset: 4px;" href="/stake">Stake</a>
        </div>
      </div>



    </div>
    <div class="below">
      <div style="margin: 12em auto 0;  padding: 40px 10px;  max-width: 1500px;" class="card_medium">
        <h1 style="font-weight: 600; z-index: 10; width: 20%; margin-left: 50px" class="ht5"><span
          style="position:absolute;z-index: 0; margin-top: -.5em; margin-left: -.5em; opacity: 0.7; font-size: 1.5em">🔥</span><span style="z-index: 100">Top Projects
          <span style="font-weight: 300">Auditing Now</span></span></h1>

        <div style="display: flex" class="projects">

          <div class="results" style="width: 100%">

            <div class="ht1" style="cursor: pointer" @click="redirect_project(k)" v-for="(project, k) in top_projects">
              <div style="padding: 14px 20px; color: #333; display: flex; align-items: center; justify-content: space-between">
                <div>
                  <span style="color: #666; font-size: 1.2em; font-weight: 800">#{{k}} {{ project.projectName || "" }}</span>
                  <br>
                  <span><span style="font-weight: 600; font-size: 3em">{{ project.reward / 1e18 }}</span>
                    <br><span style="opacity: 0.5">$FUZL Bounty</span></span>
                </div>

                <div style="margin-top: 20px; width: 60%; margin-left: 30px">
                  <line-chart
                    style="height: 80px; "
                    :chart-options='chartOptions'
                    :chart-data='to_plot_data([project.cumulative_comp, project.cumulative_heartbeats])'
                    chart-id='myCustomId'
                  />
                  <div style="margin-left: auto; text-align: right">
                    <span style="opacity: 0.5">Auditing Power</span>
                  </div>
                </div>
              </div>
            </div>

          </div>
        </div>



        <!--        <div class="card">-->
        <!--          <div style="padding: 20px 30px">-->
        <!--          </div>-->
        <!--        </div>-->
      </div>
      <div style="margin: 2em auto 0;  padding: 40px 10px;  max-width: 1500px;">
        <div style="display: flex; justify-content: space-around" class="intros">

          <div style="width: 40%;text-align: left" class="comm intro-text" >
            <h2 style="font-weight: 500;text-align: left">Gain Provable Audits with Consensus</h2>
            <p style="color: #666; text-align: left">
              FuzzLand is a decentralized protocol for automated auditing. It allows anyone to audit any project, and
              receive a reward for their work. The protocol is designed to be as decentralized as possible, and to
              incentivize the community to audit projects.
            </p>

            <button class="comm-button button button-dark" style="margin-top: 40px; width: max-content" @click="onboard">Get Audited</button>
          </div>
          <div class="intro-img">
            <img src="/p2.svg" />
          </div>
        </div>


        <div style="display: flex; justify-content: space-around; margin-top: 200px" class="intros">
          <div class="intro-img">
            <img src="/p1.svg" />
          </div>
          <div class="comm intro-text" style="width: 40%;text-align: left">
            <h2 style="font-weight: 500;text-align: left">Earn Tokens by Sharing Computing Power</h2>
            <p style="color: #666; text-align: left">
              FuzzLand is a decentralized protocol for automated auditing. It allows anyone to audit any project by contributing computing power. The auditors are rewarded with $FUZL tokens.
            </p>

            <button class="comm-button button button-dark" style="margin-top: 40px; width: max-content" @click="redirect('https://docs.fuzz.land/miner')">Start Earning</button>
          </div>

        </div>
      </div>

      <div style="margin: 2em auto 0;  padding: 40px 10px;  max-width: 1500px;">
        <h1 style="font-weight: 600; text-align: center">Join our Community</h1>

        <div style="display: flex; margin: 0 auto; width: 100%; justify-content: center" class="comms">
          <div style="display: flex; justify-content: space-between; margin-top: 2em">
            <div class="comm">
              <img src="/discord.svg"/>
              <h2>Discord</h2>
              <p>Join our Discord server to chat with the community.</p>

              <button class="button button-dark comm-button" @click="redirect('https://discord.gg/PWY5GSqYGJ')">Join</button>
            </div>
          </div>

          <div style="display: flex; justify-content: space-between; margin-top: 2em">
            <div class="comm">
              <img src="/twitter.svg"/>
              <h2>Twitter</h2>
              <p>Follow us on Twitter to get the latest updates.</p>

              <button class="button button-dark comm-button" @click="redirect('https://twitter.com/hackthedefi')">Follow</button>
            </div>
          </div>

          <div style="display: flex; justify-content: space-between; margin-top: 2em">
            <div class="comm">
              <img src="/telegram.svg"/>
              <h2>Telegram</h2>
              <p>Join our Telegram group to chat with the community.</p>
              <button class="button button-dark comm-button">Join</button>
            </div>
          </div>
        </div>

      </div>
    </div>
  </div>


</template>

<script>

import {STATS_API_URL} from "../../const";

export default {
  name: 'IndexPage',
  data() {
    return {
      current_project_type: "Web3",
      idx: 0,
      projects: ["Web3", "C++", "Java", "WebApp"],
      appear: true,
      top_projects: [],
      chartData: {
        labels: [ 'January', 'February', 'March' ],
        datasets: [ { data: [40, 20, 12] } ]
      },
      chartOptions: {
        layout: { autoPadding: true },
        hover: { intersect: false },
        backdropPadding: 0,
        padding: 0,
        plugins: {
          legend: {
            display: false,
          },
          tooltip: {
            // TODO: re-enable custom tooltip component
            // enabled: false,
            // external: customTooltip,
            caretPadding: 10,
            caretX: 0,
            caretY: 0,
            intersect: false,
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
              display: false,
            },
            grid: {
              drawBorder: true,
              borderWidth: 0,
              drawTicks: false,
              color: 'transparent',
              width: 0,
              backdropPadding: 0,
            },
            drawBorder: false,
            drawTicks: false,
          },
          x: {
            ticks: {
              display: false,
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
    this.get_top_projects();

  },
  methods: {
    onboard() {
      window.location.href = '/onboard'
    },
    redirect(v) {
      window.location.href = v
    },
    get_top_projects() {
      fetch(`${STATS_API_URL}/projects`, {
      }).then(res => res.json()).then(res => {
        this.top_projects = res;
      })
    },
    get_name(id) {
      return "a"
    },
    redirect_project(id) {
      window.location.href = '/project/?id=' + id
    },

    to_plot_data(data_list) {

      let datasets = [];
      let labels = [];

      let first = true;
      let index = 0;
      let colors = ['#ffeaa7', '#fab1a0'];
      let labels_name = ['Comp', 'Heartbeat'];

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

      const width = 20;
      return {
        labels: labels,
        datasets
      }
    }
  },

}
</script>
<style>

</style>
<style scoped>
@import url('https://fonts.googleapis.com/css2?family=Open+Sans:ital,wght@0,300;0,400;0,500;0,600;0,700;0,800;1,300;1,400;1,500;1,600;1,700;1,800&display=swap');
.background {
  background-image: linear-gradient(159.55deg, rgb(255, 255, 255) 24.48%, rgb(244, 255, 255) 64.09%, rgb(248, 240, 251) 84.45%);
}

.body {
  max-width: 1300px;
  margin: 0 auto;
}
.slogan {
  margin: 10vh auto 0 auto;
  padding: 80px;
  text-align: center;
  background: radial-gradient(circle, rgba(239,221,245,1) 0%, rgba(255,255,255,1) 40%, rgba(255,255,255,1) 100%);
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
  font-weight: 500;
  font-family: 'Open Sans', sans-serif;

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

.card {
  background: #333;
  color: #fff;
  border-radius:0.5em;
  margin: 15% 100px 0;

}


.below {
  color: #000;
  width: 100%;
}


.results {
  /* fit in up to 5 columns of 180px wide tiles, 20px gutters: 5*180 + 4*20: */
  margin: 0 auto;
  display: grid;
  grid-gap: 20px;
  /* fit as many columns as possible, 180px wide each: */
  grid-template-columns: repeat(auto-fill, 450px);
  /* each row is 20px high -- we always span 2+ */
  grid-auto-rows: minmax(20px, auto);
  justify-content: center;
}

.results > * {
  width: 450px;
  /* only for older non-grid browsers: */
  float: left;
  /* only for older non-grid browsers: */
}

.ht0 { grid-row-end: span 2; }
.ht1 { grid-row-end: span 3; }
.ht2 { grid-row-end: span 4; }
.ht3 { grid-row-end: span 5; }
.ht4 { grid-row-end: span 6; }
.ht5 { grid-row-end: span 7; }
.ht6 { grid-row-end: span 8; }
.ht7 { grid-row-end: span 9; }

@supports (display: grid) {
  .results > * {
    /* modern browser -- grid-gap takes care of us: */
    margin: 0 auto;
  }
}

/* cosmetics only from here on down */
.results > div {
  border-radius: 6px;
  background: #fff;
  border: 2px solid #f0f3fb;
}

.results > span {
  color: #333333;
}
.comm {
  width: 250px;
  background: linear-gradient(31.37deg,#fff 1.13%,rgba(255,255,255,0) 100%);
  margin: 15px;
  border: 2px solid #f0f3fb;
  border-radius: 24px;
  padding: 50px 25px;
}

.comm > img {
  height: 70px;
  display: block;
  max-height: 100%;
  width: auto;
  margin: 0 auto 15px;
}

.comm > h2 {
  text-align: center;
}

.comm > p{
  text-align: center;
}

.comm-button {
  width: 100%;
  font-family: 'Open Sans', sans-serif;
  font-weight: 600;
  font-size: 1.1em;
}


@media screen and (max-width: 1000px) {
  .slogan > h1 {
    /*font-size: 1em !important;*/
    display: none;
  }

  .projects {
    flex-direction: column;
  }

  .projects > h1 {
    font-size: 1.5em;
    width: 100% !important;
  }

  .comms {
    flex-direction: column;
  }
  .intros {
    flex-direction: column;
    margin-top: 10px !important;
  }

  .intro-img {
    display: none;
  }
  .intro-text {
    width: auto !important;

  }
  .comm {
    width: auto !important;
  }


}
</style>
