// src/components/AnnualPremiumChart.js
import * as Plot from "@observablehq/plot";

/**
 * Creates a bar chart showing annual premium costs
 * @param {Object} options - Chart configuration options
 * @param {Array} options.data - The year summary data array
 * @param {string} options.totalAmount - Formatted total amount (e.g. "$10.5M")
 * @param {string} options.yearRange - Year range string (e.g. "2018 - 2022")
 * @param {number} options.width - Width of the chart (responsive)
 * @param {number} options.height - Height of the chart
 * @param {string} options.barColor - Color for the bars
 * @param {string} options.title - Optional custom title
 * @returns {Element} The generated Plot chart element
 */
export function create_annual_cost_chart({
  data,
  totalAmount,
  yearRange,
  width = 500,
  height = 400,
  barColor = "steelBlue",
  title = null
}) {
  return Plot.plot({
    title: title || `Standard Offer Annual Premium | ${totalAmount} from ${yearRange}`,
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
        fill: "white",
        textAnchor: "middle"
      })
    ]
  });
}