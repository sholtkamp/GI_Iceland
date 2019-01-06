$(document).ready(function () {

    $('#sidebar').on('click', function () {
       if(!$('#sidebar').hasClass('active')){
        $('#sidebar').toggleClass('active')
       }
    });
});
