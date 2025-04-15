```js
const json_content = await FileAttachment(`data/cost_comparison.json`).json();
const cost_db = await DuckDBClient.of({cost_db: json_content});
const year_summary = await cost_db.sql`
    SELECT 
        year::INTEGER AS year, 
        SUM(res_cost_variance) AS variance
    FROM cost_db
    GROUP BY year
`;
const premium_total_result = Array.from(await cost_db.sql`
    SELECT 
        SUM(res_cost_variance) AS total_variance,
        MIN(year) AS min_year,
        MAX(year) AS max_year
    FROM cost_db
`);
const total_variance = premium_total_result[0]?.total_variance;
const formatted_total = "$" + (total_variance / 1_000_000).toFixed(1) + "M";
const year_range = premium_total_result[0]?.min_year + " - " + premium_total_result[0]?.max_year 
```

<div class="hero">
  <h1>Maine&#x27;s retail electricity ripoff</h1>
  <h2>Welcome to your new app! Edit&nbsp;<code style="font-size: 90%;">src/index.md</code> to change this page.</h2>
  <a href="https://observablehq.com/framework/getting-started">Get started<span style="display: inline-block; margin-left: 0.25rem;">↗︎</span></a>
</div>

```js
display(
  Plot.plot({
    title: `Standard Offer Annual Premium | ${formatted_total} from ${year_range}`,
    width: Math.max(500, width), 
    height: 400,
    x: {
        label: "Year",
        scale: { 
            type: 'band',
            interval: 2
        },
        tickFormat: (d) => `${d}`
    },
    y: { 
        grid: true, 
        label: "Cost over standard offer"
    },
    marks: [
      Plot.rectY(year_summary, {
        x: "year", 
        y: "variance", 
        fill: "steelBlue",
        target: "_top"
      }), 
        Plot.text(year_summary, {
          x: "year",
          y: "variance",
          text: d => "$" + (d.variance / 1_000_000).toFixed(1) + "M",
          dy: -6, // move the label a bit above the top of the bar
          fontSize: 12,
          fill: "white",
          textAnchor: "middle"
        })
    ]
  }));
```

Here are some ideas of things you could try…

<div class="grid grid-cols-4">
  <div class="card">
    Chart your own data using <a href="https://observablehq.com/framework/lib/plot"><code>Plot</code></a> and <a href="https://observablehq.com/framework/files"><code>FileAttachment</code></a>. Make it responsive using <a href="https://observablehq.com/framework/javascript#resize(render)"><code>resize</code></a>.
  </div>
  <div class="card">
    Create a <a href="https://observablehq.com/framework/project-structure">new page</a> by adding a Markdown file (<code>whatever.md</code>) to the <code>src</code> folder.
  </div>
  <div class="card">
    Add a drop-down menu using <a href="https://observablehq.com/framework/inputs/select"><code>Inputs.select</code></a> and use it to filter the data shown in a chart.
  </div>
  <div class="card">
    Write a <a href="https://observablehq.com/framework/loaders">data loader</a> that queries a local database or API, generating a data snapshot on build.
  </div>
  <div class="card">
    Import a <a href="https://observablehq.com/framework/imports">recommended library</a> from npm, such as <a href="https://observablehq.com/framework/lib/leaflet">Leaflet</a>, <a href="https://observablehq.com/framework/lib/dot">GraphViz</a>, <a href="https://observablehq.com/framework/lib/tex">TeX</a>, or <a href="https://observablehq.com/framework/lib/duckdb">DuckDB</a>.
  </div>
  <div class="card">
    Ask for help, or share your work or ideas, on our <a href="https://github.com/observablehq/framework/discussions">GitHub discussions</a>.
  </div>
  <div class="card">
    Visit <a href="https://github.com/observablehq/framework">Framework on GitHub</a> and give us a star. Or file an issue if you’ve found a bug!
  </div>
</div>

<style>

.hero {
  display: flex;
  flex-direction: column;
  align-items: center;
  font-family: var(--sans-serif);
  margin: 4rem 0 8rem;
  text-wrap: balance;
  text-align: center;
}

.hero h1 {
  margin: 1rem 0;
  padding: 1rem 0;
  max-width: none;
  font-size: 14vw;
  font-weight: 900;
  line-height: 1;
  background: linear-gradient(30deg, var(--theme-foreground-focus), currentColor);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
}

.hero h2 {
  margin: 0;
  max-width: 34em;
  font-size: 20px;
  font-style: initial;
  font-weight: 500;
  line-height: 1.5;
  color: var(--theme-foreground-muted);
}

@media (min-width: 640px) {
  .hero h1 {
    font-size: 90px;
  }
}

</style>
