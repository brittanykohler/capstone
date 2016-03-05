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
            text: 'Fruit Consumption'
        },
        xAxis: {
            categories: ['Apples', 'Bananas', 'Oranges']
        },
        yAxis: {
            title: {
                text: 'Fruit eaten'
            }
        },
        series: [{
            name: 'Jane',
            data: [1, 0, 4]
        }, {
            name: 'John',
            data: [5, 7, 3]
        }]
    });
});
