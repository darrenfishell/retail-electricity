<link rel="stylesheet" href="./styles/style.css">

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
const dark = Generators.dark();
const text_fill = dark ? "white" : "black";
```

<div class="hero">

# Maine's ${formatted_total} retail electricity ripoff (and counting)

## Each year since 2013, Maine customers pay more, on average, with retail electricity suppliers than if they'd taken the default electricity price, called the standard offer.
</div>

```js
function createAnnualPremiumChart({
  data,
  totalAmount,
  yearRange,
  width = 500,
  height = 400,
  barColor = "steelBlue",
  title = null
}) {
  return Plot.plot({
    title: title || `Retail supplier charges above the standard offer`,
    subtitle: `Comparing aggregate sales/kwh to a weighted standard offer from ${year_range}`,
    width: Math.max(500, width),
    height: height,
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
      Plot.rectY(data, {
        x: "year",
        y: "variance",
        fill: barColor,
        target: "_top"
      }),
      Plot.text(data, {
        x: "year",
        y: "variance",
        text: d => "$" + (d.variance / 1_000_000).toFixed(1) + "M",
        dy: -6, // move the label a bit above the top of the bar
        fontSize: 12,
        fill: text_fill,
        textAnchor: "middle"
      }),
      Plot.axisY({
          fontSize: 16, 
          marginLeft: 50, 
          tickFormat: d => "$" + (d / 1_000_000).toFixed(0) + "M" 
      }),
      Plot.axisX({
          fontSize: 16,
          tickFormat: d => d.toString(),
          label: null
      })
        
    ]
  });
}

// Use the function to create and display the chart
const barChart = createAnnualPremiumChart({
  data: year_summary,
  totalAmount: formatted_total,
  yearRange: year_range,
  width: width,
  height: 400
});

display(barChart)
```

```js
// Query data by utility company for the bubble chart
const utility_summary = await cost_db.sql`
    SELECT 
        utility_name AS name,
        SUM(res_cost_variance) AS cost_variance,
        SUM(sales_kwh) as sales_kwh
    FROM cost_db
    GROUP BY utility_name
    ORDER BY cost_variance DESC
`;

const utilityChart = Plot.plot({
    title: 'Charges to customers above the standard offer',
    subtitle: `Comparing aggregate sales/kwh to a weighted standard offer from ${year_range}`,
    height: 500,
    width: Math.max(500, width/2),
    marks: [
      Plot.barX(utility_summary, {
        x: "cost_variance",
        y: "name",
        fill: "steelblue",  // Add color to the bars
        tip: true,
        sort: {y: "x", reverse: true}
      }), 
      Plot.axisY({fontSize: 16}),
      Plot.axisX({
          fontSize: 16, 
          tickFormat: d => "$" + (d / 1_000_000).toFixed(0) + "M",
          label: null
      }),
      // Optional: Add values at the end of each bar
      Plot.text(utility_summary, {
        x: "cost_variance",
        y: "name",
        text: d => "$" + (d.cost_variance / 1_000_000).toFixed(2) + "M",
        dx: 5,
        fill: text_fill,
        fontSize: 14,
        textAnchor: "start",
        marginLeft: 150,
        marginRight: 100,
        sort: {y: "x", reverse: true}
      })
    ],
    x: {
        label: "Cost Variance ($)",
        tickFormat: d => "$" + (d / 1_000_000).toFixed(0) + "M",
        scale: {
            type: 'band',
            interval: 40_000_000
        },
    },
    y: {
        label: null,
        fontSize: 14
    }
  });

const utility = view(utilityChart)
```

```js
// Query time series data for the line chart with updated SQL
const price_trends = await cost_db.sql`
    SELECT * FROM
        (SELECT
            year::INTEGER AS year,
            AVG(kwh_rate) AS avg_price,
            'Retail supplier' AS category
        FROM cost_db
        WHERE utility_name = ${utility?.name}
            OR ${utility?.name ?? 'all'} = 'all'
        GROUP BY year
        UNION ALL
        SELECT 
            year::INTEGER AS year,
            AVG(weighted_standard_offer) AS avg_price,
            'Standard offer' AS category
        FROM cost_db
        GROUP BY year
    ) ORDER BY year
`;

// Create an interactive line chart with hover effects
const lineChart = Plot.plot({
        title: `Electricity Price Trends: Standard Offer vs. Retail Rates`,
        subtitle: `Plotted against the annual average for ${utility?.name ?? 'all suppliers'}`,
        width: Math.max(600, width),
        height: 700,
        color: {legend: true},
        x: {label: "Year"},
        y: {
            label: "Price (¢/kWh)",
            grid: true,
            zero: true
        },
        marks: [
            // Add a horizontal zero line
            Plot.ruleY([0]),
            
            Plot.axisY({fontSize: 30}),
            Plot.axisX({
                fontSize: 30, 
                label: null, 
                tickFormat: d => d.toString()
            }),
            
            // Retail price line
            Plot.line(price_trends, {
                x: "year", 
                y: "avg_price",
                stroke: 'category', 
                strokeWidth: 2,
                tip: true,
                title: d => `Year: ${d.year}\nRetail Price: $${d.avg_price.toFixed(2)}¢/kWh`,
                tooltip: {
                    stroke: 'crimson',
                    strokeWidth: 3
                }
            }),
            
            // Add label for standard offer line using select transform to get the last point
            Plot.text(price_trends, Plot.selectLast({
                x: "year", 
                y: "avg_price", 
                z: 'category',
                text: "avg_price", 
                frameAnchor: "left", 
                dx: 7
            }
            ))
        ]
    });
```

<div class="dashboard">

<div class="grid grid-cols-2" style="gap: 1rem; align-items: start;">
    <div class="chart-container">
      ${utilityChart}
    </div>
    <div class="chart-container">
      ${lineChart}
    </div>
</div>
</div>

<style>
  .dashboard {
    max-width: ${width}px;
    margin: 0 auto;
    font-family: system-ui, sans-serif;
  }

  .chart-container {
    background: ${text_fill};
    box-shadow: 0 2px 6px rgba(0,0,0,0.05);
  }
  
  @media (max-width: 768px) {
    .grid-cols-2 {
      grid-template-columns: 1fr !important;
    }
  }
</style>