console.log('Thx for visiting my blog!');

/* init papers.html */
$(document).ready(function(){
    papers.init();
})

/* tooltip init */
$(function() {
	$('[data-toggle="tooltip"]').tooltip();
})

/* back to home directory */
$('#blogLink').on('click', function() {
    if (!$('#bodyContainer').hasClass('init')) {
        papers.initCategory();
    }
})

/* after click contact-link,hide modal */
$('a[data-toggle="tooltip"]').bind('click', function() {
	$('#contactModal').modal('hide');
})

/* time roundabout init */
$(document).ready(function() {
    var breakdown = getDateBreakdown();
    
    $('ul#hours-tens').roundabout({
        easing: 'easeOutExpo',
        shape: 'waterWheel',
        startingChild: breakdown.hoursTens,
        minScale: 1
    });
    $('ul#hours-ones').roundabout({
        easing: 'easeOutExpo',
        shape: 'waterWheel',
        startingChild: breakdown.hoursOnes,
        minScale: 1
    });
    $('ul#minutes-tens').roundabout({
        easing: 'easeOutExpo',
        shape: 'waterWheel',
        startingChild: breakdown.minutesTens,
        minScale: 1
    });
    $('ul#minutes-ones').roundabout({
        easing: 'easeOutExpo',
        shape: 'waterWheel',
        startingChild: breakdown.minutesOnes,
        minScale: 1
    });
    $('ul#seconds-tens').roundabout({
        easing: 'easeOutExpo',
        shape: 'waterWheel',
        startingChild: breakdown.secondsTens,
        minScale: 1
    });
    $('ul#seconds-ones').roundabout({
        easing: 'easeOutExpo',
        shape: 'waterWheel',
        startingChild: breakdown.secondsOnes,
        minScale: 1
    });
    $('ul#ampm').roundabout({
        easing: 'easeOutExpo',
        shape: 'waterWheel',
        startingChild: breakdown.ampm
    });
    $('ul.delimiter').roundabout({
        easing: 'easeOutExpo',
        shape: 'waterWheel'
    });
    
    setInterval(function() {
        var breakdown = getDateBreakdown();
        $('ul#hours-tens').roundabout("animateToChild", breakdown.hoursTens);
        $('ul#hours-ones').roundabout("animateToChild", breakdown.hoursOnes);
        $('ul#minutes-tens').roundabout("animateToChild", breakdown.minutesTens);
        $('ul#minutes-ones').roundabout("animateToChild", breakdown.minutesOnes);
        $('ul#seconds-tens').roundabout("animateToChild", breakdown.secondsTens);
        $('ul#seconds-ones').roundabout("animateToChild", breakdown.secondsOnes);
        $('ul#ampm').roundabout("animateToChild", breakdown.ampm);
    }, 1000);
    
});
function getDateBreakdown() {
    var date = new Date(), breakdown = {};
    breakdown.hoursTens = (date.getHours() === 0 || date.getHours() == 23 || date.getHours() == 22 || date.getHours() == 11 || date.getHours() == 12 || date.getHours() == 10) ? 1 : 0;
    breakdown.hoursOnes = (date.getHours() === 0 || date.getHours() > 12) ? Math.abs(date.getHours() - 12) % 10 : date.getHours() % 10;
    breakdown.minutesTens = (date.getMinutes() - (date.getMinutes() % 10)) / 10;
    breakdown.minutesOnes = date.getMinutes() % 10;
    breakdown.secondsTens = (date.getSeconds() - (date.getSeconds() % 10)) / 10;
    breakdown.secondsOnes = date.getSeconds() % 10;
    breakdown.ampm = (date.getHours() > 11) ? 1 : 0;
    return breakdown;
};
