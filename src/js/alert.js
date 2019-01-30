var visited = localStorage.getItem('visited');
if (!visited) {
    alert("Disclaimer:\nThis website is built for educational purposes.\nIn case of emergency contact your local authorities for help and further information.");
    localStorage.setItem('visited', true);
}
