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
          fontFamily: 'Lato'
        },
        backgroundColor: '#F5F5F5',
      },
      title: {
        text: 'DAILY STEPS - LAST 7 DAYS'
      },
      xAxis: {
        categories: gon.chart_days
      },
      yAxis: {
        title: {
            text: 'STEPS'
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
        color: "#EE6557",
        name: "STEPS"
      }],
      credits: {
          enabled: false
      },
    });
});
