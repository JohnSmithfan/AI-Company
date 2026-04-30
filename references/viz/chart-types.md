# Visualization Reference Guide

## AI-Company Visualization Module

**Version:** 1.0.0  
**Last Updated:** 2026-04-27  
**Compliance:** AIGC-Compliant | Enterprise-Safe | No External Data Exfiltration  

---

## Table of Contents

1. [Chart Types](#1-chart-types)
2. [Report Templates](#2-report-templates)
3. [Mermaid Diagrams](#3-mermaid-diagrams)
4. [Integration](#4-integration-with-ceo-command-center)
5. [Constraints and Compliance](#5-constraints-and-compliance)

---

## 1. Chart Types

This section provides comprehensive guidance for creating visualizations using Chart.js as the primary library. All templates are designed to be enterprise-safe, VirusTotal-compliant, and free from external data exfiltration risks.

### 1.1 Line Charts

#### When to Use Line Charts

Line charts are the most versatile visualization type and should be your default choice for the following scenarios:

- **Time-series data**: Displaying trends over continuous time periods (daily, weekly, monthly, quarterly, yearly)
- **Trend analysis**: Showing the direction and magnitude of changes over time
- **Comparison**: Comparing multiple data series on the same time axis
- **Forecasting**: Visualizing historical patterns that may indicate future trends
- **Rate of change**: Highlighting acceleration, deceleration, or constant growth/decline

Line charts are NOT appropriate when:
- You need to show part-to-whole relationships (use Pie or Doughnut)
- The x-axis represents categorical data without inherent ordering (use Bar charts)
- You want to emphasize individual values rather than trends
- The data has too many distinct series (maximum 5-7 for readability)

#### Key Parameters

```javascript
// Core parameters for Line Charts
{
  type: 'line',
  data: {
    labels: [],        // X-axis labels (typically dates or time periods)
    datasets: [{
      label: '',       // Series name for legend and tooltip
      data: [],        // Numeric values aligned with labels
      borderColor: '', // Line color (hex or rgba)
      backgroundColor: '', // Fill color below line
      fill: true/false, // Whether to fill area below line
      tension: 0.4,    // Line curvature (0 = straight, 1 = very curved)
      pointRadius: 3,  // Size of data points
      pointHoverRadius: 6, // Size on hover
      borderWidth: 2,  // Line thickness in pixels
    }]
  },
  options: {
    responsive: true,           // Automatically resize to container
    maintainAspectRatio: false, // Allow custom height/width ratio
    interaction: {
      mode: 'index',            // 'index' shows all values at x-axis point
      intersect: false,         // Trigger tooltip even when not directly on point
    },
    plugins: {
      legend: {
        display: true,
        position: 'top',        // 'top', 'bottom', 'left', 'right'
        labels: {
          color: '#333333',
          font: { size: 12 }
        }
      },
      tooltip: {
        enabled: true,
        callbacks: {
          label: function(context) {
            return context.dataset.label + ': ' + context.parsed.y;
          }
        }
      }
    },
    scales: {
      x: {
        title: { display: true, text: 'Time Period' },
        grid: { display: false }
      },
      y: {
        title: { display: true, text: 'Value' },
        beginAtZero: false      // Set true only if negative values are not meaningful
      }
    }
  }
}
```

#### Code Template: Basic Line Chart

```html
<!-- Line Chart Template - Enterprise Safe -->
<!-- AIGC Generated Content - Internal Use Only -->
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Line Chart - Trend Visualization</title>
  <!-- AIGC Generated Content -->
  <style>
    .chart-container {
      position: relative;
      height: 400px;
      width: 100%;
      max-width: 800px;
      margin: 0 auto;
      padding: 20px;
      background: #ffffff;
      border-radius: 8px;
      box-shadow: 0 2px 8px rgba(0,0,0,0.1);
    }
    .aigc-label {
      position: absolute;
      bottom: 5px;
      right: 10px;
      font-size: 10px;
      color: #666;
      opacity: 0.7;
    }
  </style>
</head>
<body>
  <div class="chart-container">
    <canvas id="lineChart"></canvas>
    <div class="aigc-label">AIGC Generated Content</div>
  </div>

  <!-- Chart.js loaded from local bundled file - NO external CDN -->
  <!-- Replace '/local/path/to/chart.umd.js' with actual local path -->
  <script src="/local/path/to/chart.umd.js"></script>
  <script>
    (function() {
      'use strict';
      
      // Data configuration - customize labels and values
      const chartData = {
        labels: ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'],
        datasets: [{
          label: 'Revenue (in thousands)',
          data: [65, 59, 80, 81, 56, 55],
          borderColor: '#2563eb',
          backgroundColor: 'rgba(37, 99, 235, 0.1)',
          fill: true,
          tension: 0.4,
          pointRadius: 4,
          pointHoverRadius: 6
        }]
      };

      // Chart configuration
      const config = {
        type: 'line',
        data: chartData,
        options: {
          responsive: true,
          maintainAspectRatio: false,
          plugins: {
            legend: {
              display: true,
              position: 'top'
            },
            tooltip: {
              enabled: true,
              callbacks: {
                label: function(context) {
                  return context.dataset.label + ': ' + context.parsed.y.toLocaleString();
                }
              }
            }
          },
          scales: {
            y: {
              beginAtZero: false,
              title: {
                display: true,
                text: 'Revenue ($K)'
              }
            }
          }
        }
      };

      // Initialize chart
      const ctx = document.getElementById('lineChart').getContext('2d');
      new Chart(ctx, config);
    })();
  </script>
</body>
</html>
```

#### Code Template: Multi-Line Chart with Multiple Datasets

```html
<!-- Multi-Line Chart Template -->
<!-- AIGC Generated Content - Internal Use Only -->
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>Multi-Line Trend Analysis</title>
  <style>
    .chart-container { position: relative; height: 450px; width: 100%; }
    .aigc-disclaimer { font-size: 9px; color: #888; margin-top: 10px; }
  </style>
</head>
<body>
  <div class="chart-container">
    <canvas id="multiLineChart"></canvas>
  </div>
  <p class="aigc-disclaimer">AIGC Generated Content - Verify Before Use</p>

  <script src="/local/path/to/chart.umd.js"></script>
  <script>
    (function() {
      'use strict';
      
      const multiLineData = {
        labels: ['Q1 2025', 'Q2 2025', 'Q3 2025', 'Q4 2025', 'Q1 2026'],
        datasets: [
          {
            label: 'Product Revenue',
            data: [120, 145, 132, 168, 185],
            borderColor: '#2563eb',
            backgroundColor: 'rgba(37, 99, 235, 0.1)',
            borderWidth: 2,
            tension: 0.3,
            fill: false
          },
          {
            label: 'Service Revenue',
            data: [85, 92, 98, 105, 112],
            borderColor: '#059669',
            backgroundColor: 'rgba(5, 150, 105, 0.1)',
            borderWidth: 2,
            tension: 0.3,
            fill: false
          },
          {
            label: 'Licensing Revenue',
            data: [42, 48, 45, 52, 58],
            borderColor: '#7c3aed',
            backgroundColor: 'rgba(124, 58, 237, 0.1)',
            borderWidth: 2,
            tension: 0.3,
            fill: false
          }
        ]
      };

      const config = {
        type: 'line',
        data: multiLineData,
        options: {
          responsive: true,
          maintainAspectRatio: false,
          interaction: {
            mode: 'index',
            intersect: false
          },
          plugins: {
            legend: { position: 'top' },
            tooltip: {
              callbacks: {
                afterBody: function(tooltipItems) {
                  return '\nAIGC Generated - Verify Data Accuracy';
                }
              }
            }
          },
          scales: {
            y: {
              type: 'linear',
              display: true,
              position: 'left',
              title: { display: true, text: 'Revenue ($K)' }
            }
          }
        }
      };

      new Chart(document.getElementById('multiLineChart').getContext('2d'), config);
    })();
  </script>
</body>
</html>
```

#### Compliance Notes for Line Charts

- All data processing must occur client-side within the browser sandbox
- No external API calls for data enrichment are permitted without explicit approval
- Chart rendering must complete within 2 seconds for datasets up to 10,000 points
- AIGC labeling must be visible in both printed and digital outputs
- Color choices must maintain WCAG AA contrast ratios (minimum 4.5:1 for text)

---

### 1.2 Bar Charts

#### When to Use Bar Charts

Bar charts are optimal for the following use cases:

- **Categorical comparisons**: Comparing discrete categories side-by-side
- **Frequency distributions**: Showing how many items fall into each category
- **Ranking visualization**: Displaying items sorted by value
- **Survey results**: Presenting response distributions
- **Period comparisons**: Comparing values across non-continuous time periods
- **Single time point analysis**: When you want to emphasize individual values rather than trends

Bar charts should be avoided when:
- Showing trends over continuous time (use Line charts instead)
- Displaying part-to-whole relationships with many categories (use Pie if less than 6 categories)
- The categories have no natural ordering
- You need to show data with more than 2 dimensions

#### Key Parameters

```javascript
// Core parameters for Bar Charts
{
  type: 'bar',  // or 'bar' | 'horizontalBar' (use 'bar' with indexAxis: 'y' for horizontal)
  data: {
    labels: [],     // Category labels for each bar
    datasets: [{
      label: '',    // Series name
      data: [],     // Numeric values for each bar
      backgroundColor: [], // Array of colors or single color
      borderColor: [],     // Border color for each bar
      borderWidth: 1,      // Border thickness
      borderRadius: 4,    // Rounded bar corners (Chart.js 3.0+)
      barPercentage: 0.8, // Width of bars relative to grid
      categoryPercentage: 0.9 // Space between categories
    }]
  },
  options: {
    responsive: true,
    indexAxis: 'x',  // 'x' for vertical, 'y' for horizontal bars
    plugins: {
      legend: { display: true },
      tooltip: { enabled: true }
    },
    scales: {
      x: {
        grid: { display: false },
        ticks: { maxRotation: 45 }
      },
      y: {
        beginAtZero: true,
        grid: { color: '#e0e0e0' }
      }
    }
  }
}
```

#### Code Template: Vertical Bar Chart

```html
<!-- Vertical Bar Chart Template -->
<!-- AIGC Generated Content - Internal Use Only -->
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>Bar Chart - Category Comparison</title>
  <style>
    .chart-wrapper {
      max-width: 900px;
      margin: 0 auto;
      padding: 20px;
      background: #fafafa;
      border-radius: 8px;
    }
    .chart-container { position: relative; height: 400px; }
    .aigc-label { 
      text-align: right; 
      font-size: 10px; 
      color: #666; 
      margin-top: 8px; 
    }
  </style>
</head>
<body>
  <div class="chart-wrapper">
    <div class="chart-container">
      <canvas id="barChart"></canvas>
    </div>
    <div class="aigc-label">AIGC Generated Content - Review Before Distribution</div>
  </div>

  <script src="/local/path/to/chart.umd.js"></script>
  <script>
    (function() {
      'use strict';
      
      // Department performance data
      const barData = {
        labels: ['Engineering', 'Sales', 'Marketing', 'Operations', 'Finance', 'HR'],
        datasets: [{
          label: 'Quarterly Performance Score',
          data: [92, 78, 85, 71, 88, 76],
          backgroundColor: [
            'rgba(37, 99, 235, 0.8)',
            'rgba(16, 185, 129, 0.8)',
            'rgba(245, 158, 11, 0.8)',
            'rgba(239, 68, 68, 0.8)',
            'rgba(139, 92, 246, 0.8)',
            'rgba(236, 72, 153, 0.8)'
          ],
          borderColor: [
            '#2563eb',
            '#10b981',
            '#f59e0b',
            '#ef4444',
            '#8b5cf6',
            '#ec4899'
          ],
          borderWidth: 2,
          borderRadius: 6
        }]
      };

      const config = {
        type: 'bar',
        data: barData,
        options: {
          responsive: true,
          maintainAspectRatio: false,
          plugins: {
            legend: {
              display: true,
              position: 'top',
              labels: { font: { size: 12 } }
            },
            tooltip: {
              enabled: true,
              callbacks: {
                label: function(context) {
                  return 'Score: ' + context.parsed.y + '/100';
                },
                footer: function() {
                  return '\nGenerated by AI - Verify Accuracy';
                }
              }
            }
          },
          scales: {
            y: {
              beginAtZero: true,
              max: 100,
              title: {
                display: true,
                text: 'Performance Score',
                font: { size: 14 }
              },
              grid: { color: '#e5e7eb' }
            },
            x: {
              title: {
                display: true,
                text: 'Department',
                font: { size: 14 }
              },
              grid: { display: false }
            }
          }
        }
      };

      new Chart(document.getElementById('barChart').getContext('2d'), config);
    })();
  </script>
</body>
</html>
```

#### Code Template: Grouped Bar Chart for Comparison

```html
<!-- Grouped Bar Chart Template -->
<!-- AIGC Generated Content - Internal Use Only -->
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>Grouped Bar Chart - Multi-Year Comparison</title>
  <style>
    body { font-family: system-ui, sans-serif; padding: 20px; background: #f5f5f5; }
    .container { background: white; padding: 24px; border-radius: 12px; max-width: 1000px; margin: 0 auto; }
    .chart-container { position: relative; height: 400px; }
    .aigc-notice { font-size: 9px; color: #999; margin-top: 12px; text-align: right; }
  </style>
</head>
<body>
  <div class="container">
    <h2 style="text-align: center; margin-bottom: 20px;">Annual Revenue by Region</h2>
    <div class="chart-container">
      <canvas id="groupedBarChart"></canvas>
    </div>
    <div class="aigc-notice">AIGC Generated Content</div>
  </div>

  <script src="/local/path/to/chart.umd.js"></script>
  <script>
    (function() {
      'use strict';
      
      const groupedData = {
        labels: ['North America', 'Europe', 'Asia Pacific', 'Latin America'],
        datasets: [
          {
            label: 'FY 2025',
            data: [4500, 3200, 2800, 950],
            backgroundColor: 'rgba(37, 99, 235, 0.85)',
            borderColor: '#2563eb',
            borderWidth: 1
          },
          {
            label: 'FY 2026',
            data: [5200, 3600, 3400, 1100],
            backgroundColor: 'rgba(16, 185, 129, 0.85)',
            borderColor: '#10b981',
            borderWidth: 1
          }
        ]
      };

      const config = {
        type: 'bar',
        data: groupedData,
        options: {
          responsive: true,
          maintainAspectRatio: false,
          plugins: {
            legend: { position: 'top' },
            tooltip: {
              callbacks: {
                label: function(context) {
                  return context.dataset.label + ': $' + context.parsed.y.toLocaleString() + 'K';
                }
              }
            }
          },
          scales: {
            x: {
              grid: { display: false }
            },
            y: {
              beginAtZero: true,
              title: {
                display: true,
                text: 'Revenue ($K)'
              },
              ticks: {
                callback: function(value) {
                  return '$' + value.toLocaleString() + 'K';
                }
              }
            }
          }
        }
      };

      new Chart(document.getElementById('groupedBarChart').getContext('2d'), config);
    })();
  </script>
</body>
</html>
```

#### Code Template: Stacked Bar Chart

```html
<!-- Stacked Bar Chart Template -->
<!-- AIGC Generated Content - Internal Use Only -->
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>Stacked Bar Chart - Composition Analysis</title>
  <style>
    .container { max-width: 1000px; margin: 20px auto; padding: 20px; }
    .chart-container { position: relative; height: 400px; }
  </style>
</head>
<body>
  <div class="container">
    <h2 style="text-align: center;">Expense Breakdown by Quarter</h2>
    <div class="chart-container">
      <canvas id="stackedBarChart"></canvas>
    </div>
    <p style="font-size: 9px; color: #888; text-align: right; margin-top: 8px;">AIGC Generated</p>
  </div>

  <script src="/local/path/to/chart.umd.js"></script>
  <script>
    (function() {
      'use strict';
      
      const stackedData = {
        labels: ['Q1', 'Q2', 'Q3', 'Q4'],
        datasets: [
          {
            label: 'Personnel',
            data: [450, 470, 480, 500],
            backgroundColor: 'rgba(37, 99, 235, 0.9)'
          },
          {
            label: 'Infrastructure',
            data: [120, 115, 110, 105],
            backgroundColor: 'rgba(16, 185, 129, 0.9)'
          },
          {
            label: 'Marketing',
            data: [80, 95, 110, 130],
            backgroundColor: 'rgba(245, 158, 11, 0.9)'
          },
          {
            label: 'R&D',
            data: [200, 220, 250, 280],
            backgroundColor: 'rgba(139, 92, 246, 0.9)'
          }
        ]
      };

      const config = {
        type: 'bar',
        data: stackedData,
        options: {
          responsive: true,
          maintainAspectRatio: false,
          plugins: {
            legend: { position: 'top' },
            tooltip: {
              callbacks: {
                label: function(context) {
                  return context.dataset.label + ': $' + context.parsed.y.toLocaleString() + 'K';
                }
              }
            }
          },
          scales: {
            x: { stacked: true },
            y: {
              stacked: true,
              title: { display: true, text: 'Expenses ($K)' }
            }
          }
        }
      };

      new Chart(document.getElementById('stackedBarChart').getContext('2d'), config);
    })();
  </script>
</body>
</html>
```

#### Compliance Notes for Bar Charts

- Bar charts with more than 10 categories should include data tables as supplementary material
- Stacked bar charts should not exceed 6 segments per bar for readability
- Grouped bar charts are limited to maximum 4 groups for clear visual distinction
- Percentage calculations displayed in tooltips must be mathematically accurate
- AIGC labeling must be present in all generated outputs

---

### 1.3 Pie Charts

#### When to Use Pie Charts

Pie charts are appropriate for the following scenarios:

- **Part-to-whole relationships**: Showing how individual segments relate to the total
- **Limited categories**: Displaying 2-5 distinct segments (never more than 7)
- **High contrast emphasis**: When one segment significantly dominates others
- **Single point in time**: Showing a snapshot distribution at one moment
- **Simple proportions**: When approximate visual comparison is acceptable

Pie charts should be avoided when:
- Comparing multiple pie charts side by side (very difficult to interpret)
- You need precise comparison of similar-sized segments
- There are more than 5-7 categories
- You want to show trends over time
- The segments represent negative values
- You need to show data with high precision

#### Key Parameters

```javascript
// Core parameters for Pie Charts
{
  type: 'pie',
  data: {
    labels: [],      // Segment labels
    datasets: [{
      data: [],      // Values for each segment
      backgroundColor: [], // Colors for each segment
      borderColor: '#ffffff', // Border between segments
      borderWidth: 2,
      hoverOffset: 10, // How far segment moves on hover
    }]
  },
  options: {
    responsive: true,
    maintainAspectRatio: true, // Pie charts work best with aspect ratio
    plugins: {
      legend: {
        position: 'right', // 'top', 'bottom', 'left', 'right'
        labels: {
          padding: 15,
          usePointStyle: true,
          font: { size: 12 }
        }
      },
      tooltip: {
        callbacks: {
          label: function(context) {
            const value = context.parsed;
            const total = context.dataset.data.reduce((a, b) => a + b, 0);
            const percentage = ((value / total) * 100).toFixed(1);
            return context.label + ': ' + percentage + '%';
          }
        }
      }
    }
  }
}
```

#### Code Template: Basic Pie Chart

```html
<!-- Pie Chart Template -->
<!-- AIGC Generated Content - Internal Use Only -->
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>Pie Chart - Market Share Distribution</title>
  <style>
    body { font-family: system-ui, sans-serif; display: flex; justify-content: center; padding: 40px; background: #f8fafc; }
    .chart-wrapper { background: white; padding: 32px; border-radius: 16px; box-shadow: 0 4px 12px rgba(0,0,0,0.08); max-width: 700px; }
    .chart-container { position: relative; height: 400px; width: 100%; }
    .aigc-label { text-align: center; margin-top: 16px; font-size: 10px; color: #94a3b8; }
  </style>
</head>
<body>
  <div class="chart-wrapper">
    <h2 style="text-align: center; margin-bottom: 24px;">Market Share by Product Line</h2>
    <div class="chart-container">
      <canvas id="pieChart"></canvas>
    </div>
    <div class="aigc-label">AIGC Generated Content - Verify Data Accuracy</div>
  </div>

  <script src="/local/path/to/chart.umd.js"></script>
  <script>
    (function() {
      'use strict';
      
      const pieData = {
        labels: ['Enterprise Software', 'Cloud Services', 'Hardware', 'Support & Maintenance', 'Consulting'],
        datasets: [{
          data: [35, 28, 18, 12, 7],
          backgroundColor: [
            '#2563eb',  // Blue
            '#10b981',  // Green
            '#f59e0b',  // Amber
            '#ef4444',  // Red
            '#8b5cf6'   // Purple
          ],
          borderColor: '#ffffff',
          borderWidth: 3,
          hoverOffset: 15
        }]
      };

      const config = {
        type: 'pie',
        data: pieData,
        options: {
          responsive: true,
          maintainAspectRatio: true,
          plugins: {
            legend: {
              position: 'right',
              labels: {
                padding: 16,
                usePointStyle: true,
                font: { size: 12, weight: '500' }
              }
            },
            tooltip: {
              callbacks: {
                label: function(context) {
                  const total = context.dataset.data.reduce((a, b) => a + b, 0);
                  const percentage = ((context.parsed / total) * 100).toFixed(1);
                  return context.label + ': ' + percentage + '% (' + context.parsed + '%)';
                },
                footer: function() {
                  return '\nGenerated by AI System';
                }
              }
            }
          }
        }
      };

      new Chart(document.getElementById('pieChart').getContext('2d'), config);
    })();
  </script>
</body>
</html>
```

#### Code Template: Pie Chart with Center Text

```html
<!-- Pie Chart with Center Hole Template -->
<!-- AIGC Generated Content - Internal Use Only -->
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>Pie Chart - Budget Allocation</title>
  <style>
    body { display: flex; justify-content: center; padding: 40px; background: #1e293b; }
    .chart-wrapper { background: #334155; padding: 32px; border-radius: 16px; max-width: 600px; }
    h2 { color: #f1f5f9; text-align: center; margin-bottom: 24px; }
    .chart-container { position: relative; height: 400px; width: 100%; }
    .center-text { position: absolute; top: 50%; left: 50%; transform: translate(-50%, -50%); text-align: center; color: white; }
    .center-text .value { font-size: 32px; font-weight: bold; }
    .center-text .label { font-size: 14px; opacity: 0.8; }
    .aigc-label { color: #94a3b8; text-align: center; margin-top: 16px; font-size: 10px; }
  </style>
</head>
<body>
  <div class="chart-wrapper">
    <h2>Annual Budget Allocation</h2>
    <div class="chart-container">
      <canvas id="donutChart"></canvas>
      <div class="center-text">
        <div class="value">$10.5M</div>
        <div class="label">Total Budget</div>
      </div>
    </div>
    <div class="aigc-label">AIGC Generated Content</div>
  </div>

  <script src="/local/path/to/chart.umd.js"></script>
  <script>
    (function() {
      'use strict';
      
      const donutData = {
        labels: ['Operations', 'R&D', 'Marketing', 'Sales', 'Administration'],
        datasets: [{
          data: [30, 25, 20, 15, 10],
          backgroundColor: [
            '#3b82f6',
            '#22c55e',
            '#f59e0b',
            '#ef4444',
            '#a855f7'
          ],
          borderWidth: 0,
          hoverOffset: 12
        }]
      };

      const config = {
        type: 'doughnut',
        data: donutData,
        options: {
          responsive: true,
          maintainAspectRatio: true,
          cutout: '60%',  // Creates the doughnut hole
          plugins: {
            legend: {
              position: 'bottom',
              labels: { color: '#f1f5f9', padding: 12, font: { size: 11 } }
            },
            tooltip: {
              callbacks: {
                label: function(context) {
                  return context.label + ': ' + context.parsed + '%';
                }
              }
            }
          }
        }
      };

      new Chart(document.getElementById('donutChart').getContext('2d'), config);
    })();
  </script>
</body>
</html>
```

#### Compliance Notes for Pie Charts

- Pie charts must never be used to display negative values
- The sum of all segments should equal 100% (display any remainder as "Other" if needed)
- Pie charts must not be used for precise numerical comparisons
- Always include a legend when segment labels are not displayed directly on the chart
- Accessibility requirement: Charts must be interpretable without relying on color alone

---

### 1.4 Doughnut Charts

#### When to Use Doughnut Charts

Doughnut charts (a variant of pie charts with a center cutout) are appropriate for:

- **Single metric emphasis**: Displaying one key metric prominently in the center
- **Space efficiency**: When you need a pie-style chart but have limited horizontal space
- **Part-to-whole with 2-4 segments**: Cleaner visual than pie for fewer segments
- **Multi-chart comparison**: Easier to compare side-by-side than pie charts
- **Progress indicators**: Showing completion percentages or targets

#### Code Template: Multi-Player Doughnut Comparison

```html
<!-- Multi-Doughnut Chart Template -->
<!-- AIGC Generated Content - Internal Use Only -->
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>Doughnut Chart Comparison</title>
  <style>
    body { font-family: system-ui, sans-serif; padding: 40px; background: #f8fafc; }
    .comparison-container { display: flex; justify-content: center; gap: 40px; flex-wrap: wrap; max-width: 1200px; margin: 0 auto; }
    .chart-card { background: white; border-radius: 12px; padding: 24px; box-shadow: 0 2px 8px rgba(0,0,0,0.06); text-align: center; }
    .chart-card h3 { margin: 0 0 16px 0; font-size: 16px; color: #334155; }
    .chart-container { position: relative; height: 200px; width: 200px; margin: 0 auto; }
    .center-label { position: absolute; top: 50%; left: 50%; transform: translate(-50%, -50%); font-size: 24px; font-weight: bold; color: #1e40af; }
    .aigc-label { font-size: 9px; color: #94a3b8; margin-top: 12px; }
  </style>
</head>
<body>
  <h2 style="text-align: center; margin-bottom: 32px;">Regional Performance Metrics</h2>
  
  <div class="comparison-container">
    <!-- North America -->
    <div class="chart-card">
      <h3>North America</h3>
      <div class="chart-container">
        <canvas id="chartNA"></canvas>
        <div class="center-label">85%</div>
      </div>
      <div class="aigc-label">AIGC Generated</div>
    </div>
    
    <!-- Europe -->
    <div class="chart-card">
      <h3>Europe</h3>
      <div class="chart-container">
        <canvas id="chartEU"></canvas>
        <div class="center-label">72%</div>
      </div>
      <div class="aigc-label">AIGC Generated</div>
    </div>
    
    <!-- Asia Pacific -->
    <div class="chart-card">
      <h3>Asia Pacific</h3>
      <div class="chart-container">
        <canvas id="chartAP"></canvas>
        <div class="center-label">91%</div>
      </div>
      <div class="aigc-label">AIGC Generated</div>
    </div>
  </div>

  <script src="/local/path/to/chart.umd.js"></script>
  <script>
    (function() {
      'use strict';
      
      function createDoughnutChart(canvasId, percentage, color) {
        const config = {
          type: 'doughnut',
          data: {
            datasets: [{
              data: [percentage, 100 - percentage],
              backgroundColor: [color, '#e2e8f0'],
              borderWidth: 0
            }]
          },
          options: {
            responsive: true,
            maintainAspectRatio: true,
            cutout: '75%',
            plugins: { legend: { display: false }, tooltip: { enabled: false } }
          }
        };
        new Chart(document.getElementById(canvasId).getContext('2d'), config);
      }
      
      createDoughnutChart('chartNA', 85, '#2563eb');
      createDoughnutChart('chartEU', 72, '#10b981');
      createDoughnutChart('chartAP', 91, '#f59e0b');
    })();
  </script>
</body>
</html>
```

#### Compliance Notes for Doughnut Charts

- Center text (when used) must meet minimum font size of 18px for accessibility
- Doughnut thickness should be consistent across multiple charts for fair comparison
- Cutout percentage between 60-75% is recommended for optimal visual balance
- When displaying percentage in center, ensure it matches the actual data segment

---

### 1.5 Matrix and Heatmap Charts

#### When to Use Matrix/Heatmap Charts

Heatmaps are optimal for the following scenarios:

- **Correlation analysis**: Showing relationships between two categorical variables
- **Time-based patterns**: Day/hour, month/day, or similar time matrix patterns
- **Performance grids**: Comparing multiple entities across multiple metrics
- **Geographic heatmaps**: Showing intensity variations across regions
- **Risk matrices**: Visualizing risk levels across categories
- **Calendar heatmaps**: Activity intensity over time (like GitHub contribution graphs)

Heatmaps should be avoided when:
- Both axes have more than 20 categories (visual overload)
- You need precise numerical comparison
- The data is already well-represented by simpler charts
- Color perception issues may affect interpretation

#### Key Parameters

```javascript
// Core parameters for Heatmap using Chart.js matrix plugin
{
  type: 'matrix',
  data: {
    datasets: [{
      label: 'Heatmap Data',
      data: [],  // Array of { x, y, v } objects
      backgroundColor: function(context) {
        // Color based on value
        const value = context.raw?.v;
        if (value === undefined) return 'transparent';
        // Gradient from blue (low) to red (high)
        const alpha = (value - min) / (max - min);
        return `rgba(239, 68, 68, ${alpha})`;
      },
      borderColor: function(context) {
        return '#ffffff';
      },
      borderWidth: 1,
      width: function(ctx) { return (ctx.chart.chartArea.width / 12) - 2; },
      height: function(ctx) { return (ctx.chart.chartArea.height / 7) - 2; }
    }]
  },
  options: {
    responsive: true,
    plugins: {
      legend: { display: false },
      tooltip: {
        callbacks: {
          label: function(context) {
            return 'Value: ' + context.raw.v;
          }
        }
      }
    },
    scales: {
      x: {
        type: 'category',
        labels: [],
        grid: { display: false }
      },
      y: {
        type: 'category',
        labels: [],
        grid: { display: false }
      }
    }
  }
}
```

#### Code Template: Correlation Heatmap

```html
<!-- Correlation Heatmap Template -->
<!-- AIGC Generated Content - Internal Use Only -->
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>Heatmap - Correlation Matrix</title>
  <!-- Matrix plugin required: https://chartjs-chart-matrix.js.org/ -->
  <style>
    body { font-family: system-ui, sans-serif; padding: 40px; background: #f8fafc; }
    .container { max-width: 900px; margin: 0 auto; background: white; padding: 32px; border-radius: 12px; }
    .chart-container { position: relative; height: 500px; width: 100%; }
    .legend-container { display: flex; justify-content: center; align-items: center; margin-top: 20px; gap: 8px; }
    .legend-gradient { width: 200px; height: 12px; background: linear-gradient(to right, #3b82f6, #fbbf24, #ef4444); border-radius: 4px; }
    .legend-labels { display: flex; justify-content: space-between; width: 200px; font-size: 11px; color: #64748b; }
    .aigc-label { text-align: center; margin-top: 16px; font-size: 10px; color: #94a3b8; }
  </style>
</head>
<body>
  <div class="container">
    <h2 style="text-align: center;">Sales Metrics Correlation Matrix</h2>
    <div class="chart-container">
      <canvas id="heatmapChart"></canvas>
    </div>
    <div class="legend-container">
      <span style="font-size: 11px; color: #64748b;">Low Correlation</span>
      <div>
        <div class="legend-gradient"></div>
        <div class="legend-labels">
          <span>-1.0</span>
          <span>0.0</span>
          <span>+1.0</span>
        </div>
      </div>
      <span style="font-size: 11px; color: #64748b;">High Correlation</span>
    </div>
    <div class="aigc-label">AIGC Generated Content - Statistical Correlation Analysis</div>
  </div>

  <!-- Chart.js Core -->
  <script src="/local/path/to/chart.umd.js"></script>
  <!-- Matrix Plugin for Heatmap -->
  <script src="/local/path/to/chartjs-chart-matrix.js"></script>
  
  <script>
    (function() {
      'use strict';
      
      // Correlation matrix data (6x6 grid)
      const metrics = ['Revenue', 'Growth', 'Margin', 'Retention', 'NPS', 'Support'];
      const correlationData = [
        { x: 0, y: 0, v: 1.00 }, { x: 1, y: 0, v: 0.85 }, { x: 2, y: 0, v: 0.72 }, { x: 3, y: 0, v: 0.45 }, { x: 4, y: 0, v: 0.38 }, { x: 5, y: 0, v: -0.22 },
        { x: 0, y: 1, v: 0.85 }, { x: 1, y: 1, v: 1.00 }, { x: 2, y: 1, v: 0.68 }, { x: 3, y: 1, v: 0.52 }, { x: 4, y: 1, v: 0.41 }, { x: 5, y: 1, v: -0.18 },
        { x: 0, y: 2, v: 0.72 }, { x: 1, y: 2, v: 0.68 }, { x: 2, y: 2, v: 1.00 }, { x: 3, y: 2, v: 0.33 }, { x: 4, y: 2, v: 0.29 }, { x: 5, y: 2, v: -0.35 },
        { x: 0, y: 3, v: 0.45 }, { x: 1, y: 3, v: 0.52 }, { x: 2, y: 3, v: 0.33 }, { x: 3, y: 3, v: 1.00 }, { x: 4, y: 3, v: 0.61 }, { x: 5, y: 3, v: -0.15 },
        { x: 0, y: 4, v: 0.38 }, { x: 1, y: 4, v: 0.41 }, { x: 2, y: 4, v: 0.29 }, { x: 3, y: 4, v: 0.61 }, { x: 4, y: 4, v: 1.00 }, { x: 5, y: 4, v: -0.08 },
        { x: 0, y: 5, v: -0.22 }, { x: 1, y: 5, v: -0.18 }, { x: 2, y: 5, v: -0.35 }, { x: 3, y: 5, v: -0.15 }, { x: 4, y: 5, v: -0.08 }, { x: 5, y: 5, v: 1.00 }
      ];

      function getCorrelationColor(value) {
        // Blue for negative, yellow for neutral, red for positive
        if (value >= 0) {
          const intensity = Math.min(value, 1);
          return `rgba(${Math.round(59 + (251 - 59) * intensity)}, ${Math.round(130 + (191 - 130) * (1 - intensity))}, ${Math.round(246 - 246 * intensity)}, 0.9)`;
        } else {
          const intensity = Math.min(Math.abs(value), 1);
          return `rgba(${Math.round(59 + (239 - 59) * intensity)}, ${Math.round(130 - 92 * intensity)}, ${Math.round(246 - 11 * intensity)}, 0.9)`;
        }
      }

      const config = {
        type: 'matrix',
        data: {
          datasets: [{
            label: 'Correlation',
            data: correlationData,
            backgroundColor: function(context) {
              const value = context.raw?.v;
              if (value === undefined) return 'transparent';
              return getCorrelationColor(value);
            },
            borderColor: '#ffffff',
            borderWidth: 1,
            width: function(ctx) { return Math.floor(ctx.chart.chartArea.width / 6) - 2; },
            height: function(ctx) { return Math.floor(ctx.chart.chartArea.height / 6) - 2; }
          }]
        },
        options: {
          responsive: true,
          maintainAspectRatio: false,
          plugins: {
            legend: { display: false },
            tooltip: {
              callbacks: {
                title: function(items) {
                  const item = items[0];
                  return metrics[item.raw.x] + ' vs ' + metrics[item.raw.y];
                },
                label: function(context) {
                  return 'Correlation: ' + context.raw.v.toFixed(2);
                },
                footer: function() { return '\nAIGC Generated - Verify Statistical Significance'; }
              }
            }
          },
          scales: {
            x: {
              type: 'category',
              labels: metrics,
              ticks: { font: { size: 11 } },
              grid: { display: false },
              position: 'top'
            },
            y: {
              type: 'category',
              labels: metrics,
              ticks: { font: { size: 11 } },
              grid: { display: false }
            }
          }
        }
      };

      new Chart(document.getElementById('heatmapChart').getContext('2d'), config);
    })();
  </script>
</body>
</html>
```

#### Code Template: Calendar Heatmap

```html
<!-- Calendar Heatmap Template -->
<!-- AIGC Generated Content - Internal Use Only -->
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>Calendar Heatmap - Activity Tracking</title>
  <style>
    body { font-family: system-ui, sans-serif; padding: 40px; background: #0f172a; }
    .container { max-width: 1100px; margin: 0 auto; background: #1e293b; padding: 32px; border-radius: 16px; }
    h2 { color: #f1f5f9; text-align: center; margin-bottom: 24px; }
    .chart-container { position: relative; height: 160px; }
    .month-labels { display: flex; justify-content: space-between; padding: 0 20px; color: #94a3b8; font-size: 11px; margin-bottom: 8px; }
    .day-labels { display: flex; flex-direction: column; justify-content: space-between; position: absolute; left: 0; top: 0; height: 140px; color: #64748b; font-size: 10px; padding: 2px 0; }
    .legend { display: flex; justify-content: flex-end; align-items: center; gap: 8px; margin-top: 16px; color: #94a3b8; font-size: 11px; }
    .legend-squares { display: flex; gap: 3px; }
    .legend-square { width: 12px; height: 12px; border-radius: 2px; }
    .aigc-label { color: #64748b; text-align: right; margin-top: 12px; font-size: 9px; }
  </style>
</head>
<body>
  <div class="container">
    <h2>Daily Activity Heatmap - 2026</h2>
    <div style="display: flex;">
      <div class="day-labels"><span>Mon</span><span>Wed</span><span>Fri</span></div>
      <div style="flex: 1; margin-left: 20px;">
        <div class="month-labels">
          <span>Jan</span><span>Feb</span><span>Mar</span><span>Apr</span><span>May</span><span>Jun</span>
          <span>Jul</span><span>Aug</span><span>Sep</span><span>Oct</span><span>Nov</span><span>Dec</span>
        </div>
        <div class="chart-container">
          <canvas id="calendarHeatmap"></canvas>
        </div>
      </div>
    </div>
    <div class="legend">
      <span>Less</span>
      <div class="legend-squares">
        <div class="legend-square" style="background: #1e3a5f;"></div>
        <div class="legend-square" style="background: #2563eb;"></div>
        <div class="legend-square" style="background: #3b82f6;"></div>
        <div class="legend-square" style="background: #60a5fa;"></div>
        <div class="legend-square" style="background: #93c5fd;"></div>
      </div>
      <span>More</span>
    </div>
    <div class="aigc-label">AIGC Generated Content</div>
  </div>

  <script src="/local/path/to/chart.umd.js"></script>
  <script src="/local/path/to/chartjs-chart-matrix.js"></script>
  <script>
    (function() {
      'use strict';
      
      // Generate sample data for 52 weeks
      const generateData = function() {
        const data = [];
        for (let week = 0; week < 52; week++) {
          for (let day = 0; day < 7; day++) {
            // Generate realistic activity pattern
            const isWeekend = day >= 5;
            const baseActivity = isWeekend ? 2 : 5;
            const variance = Math.random() * 3;
            const activity = Math.min(10, Math.max(0, Math.round(baseActivity + variance)));
            data.push({ x: week, y: day, v: activity });
          }
        }
        return data;
      };

      const heatmapData = generateData();

      function getHeatmapColor(value) {
        const levels = ['#1e3a5f', '#2563eb', '#3b82f6', '#60a5fa', '#93c5fd'];
        const index = Math.min(Math.floor(value / 2.5), 4);
        return levels[index];
      }

      const config = {
        type: 'matrix',
        data: {
          datasets: [{
            data: heatmapData,
            backgroundColor: function(context) {
              return getHeatmapColor(context.raw?.v || 0);
            },
            borderWidth: 0,
            width: function(ctx) { return Math.floor(ctx.chart.chartArea.width / 52) - 1; },
            height: function(ctx) { return Math.floor(ctx.chart.chartArea.height / 7) - 1; }
          }]
        },
        options: {
          responsive: true,
          maintainAspectRatio: false,
          plugins: { legend: { display: false }, tooltip: { enabled: true } },
          scales: {
            x: { display: false, type: 'linear', min: 0, max: 51 },
            y: { display: false, type: 'linear', min: 0, max: 6 }
          }
        }
      };

      new Chart(document.getElementById('calendarHeatmap').getContext('2d'), config);
    })();
  </script>
</body>
</html>
```

#### Compliance Notes for Matrix/Heatmap Charts

- Color scales must include a legend for accurate interpretation
- Consider colorblind-friendly palettes (avoid red-green gradients; use blue-orange instead)
- Matrix size should not exceed 20x20 cells for optimal readability
- Tooltips must display exact numerical values for accessibility
- AIGC labeling required on all generated heatmap outputs

---

