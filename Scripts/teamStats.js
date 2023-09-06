
// Get references to the "Games Won" and "Games Lost" column headers
const gamesWonColumn = document.getElementById('games-won-column');
const gamesLostColumn = document.getElementById('games-lost-column');

// Get the data for "Games Won" and "Games Lost" from the table cells
const teamNames = [];
const gamesWonData = [];
const gamesLostData = [];

document.querySelectorAll('table tbody tr').forEach((row) => {
    teamNames.push(row.querySelector('td:nth-child(1)').innerText); // Team Name
    gamesWonData.push(parseInt(row.querySelector('td:nth-child(5)').innerText)); // Games Won
    gamesLostData.push(parseInt(row.querySelector('td:nth-child(6)').innerText)); // Games Lost
});

// Create the bar chart with initial data (Games Won)
const chart = document.getElementById('teamStatsChart').getContext('2d');
const teamStatsChart = new Chart(chart, {
    type: 'bar',
    data: {
        labels: teamNames,
        datasets: [{
            label: 'Games Won',
            data: gamesWonData,
            backgroundColor: '#4bc0c033',
            borderColor: '#4bc0c0',
            borderWidth: 1
        }]
    },
    options: {
        scales: {
            y: {
                beginAtZero: true
            }
        }
    }
});

// Add click event listeners to column headers for switching data
gamesWonColumn.addEventListener('click', () => {
    teamStatsChart.data.datasets[0].label = 'Games Won';
    teamStatsChart.data.datasets[0].data = gamesWonData;
    teamStatsChart.data.datasets[0].backgroundColor = '#4bc0c033';
    teamStatsChart.data.datasets[0].borderColor = '#4bc0c0';
    teamStatsChart.update();
});

gamesLostColumn.addEventListener('click', () => {
    teamStatsChart.data.datasets[0].label = 'Games Lost';
    teamStatsChart.data.datasets[0].data = gamesLostData;
    teamStatsChart.data.datasets[0].backgroundColor = '#FF9D9D';
    teamStatsChart.data.datasets[0].borderColor = '#D95353';
    teamStatsChart.update();
});
