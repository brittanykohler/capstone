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
            type: 'column'
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
            }
        },
        series: [{
          showInLegend: false,
          data: gon.chart_data,
          color: "#00A9B6"
        }],
        credits: {
            enabled: false
        },

    });
});
