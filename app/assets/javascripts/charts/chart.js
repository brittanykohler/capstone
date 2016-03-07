// var Highcharts = require('highcharts');
//
// // Load module after Highcharts is loaded
// require('node_modules/highcharts/modules/exporting')(Highcharts);
//
// // Create the chart
// Highcharts.chart('chart', { /*Highcharts options*/ });
//
$(function () {
    $('#chart').highcharts({
      chart: {
        type: 'column',
        style: {
          fontFamily: 'Quicksand'
        }
      },
      title: {
        text: 'Weekly Steps'
      },
      xAxis: {
        categories: gon.chart_days
      },
      yAxis: {
        title: {
            text: 'Steps'
        },
        plotLines: [{
          color: 'black', // Color value
          dashStyle: 'dot', // Style of the plot line. Default to solid
          value: gon.step_goal, // Value of where the line will appear
          width: 2 // Width of the line
        }]
      },
      series: [{
        showInLegend: false,
        data: gon.chart_data,
        color: "#00A9B6",
        name: "Steps"
      }],
      credits: {
          enabled: false
      },
    });
});
