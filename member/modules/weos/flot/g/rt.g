    <div id="placeholder" style="width:600px;height:300px;"></div>
<script id="source" language="javascript" type="text/javascript">
$(function () {
    var options = {
        lines: { show: true },
        points: { show: true },
        xaxis: { tickDecimals: 0, tickSize: 1 }
    };
    var data = [];
    var placeholder = $("#placeholder");
    $.plot(placeholder, data, options);
    // fetch one series, adding to what we got
    var alreadyFetched = {};
    	var dataurl = '/r/call.php?'+new Date().getTime();
        function onDataReceived(series) {
                data = [ series ];
                $.plot($("#placeholder"), data, { xaxis: { mode: "time" } });
         }
        $.ajax({
            url: dataurl,
            method: 'GET',
            dataType: 'json',
            success: onDataReceived
        });


    // initiate a recurring data update
        function fetchData() {
    	    var dataurl = '/r/call.php?'+new Date().getTime();
            function onDataReceived(series) {
                // we get all the data in one go, if we only got partial
                // data, we could merge it with what we already got
                data = [ series ];
                
                $.plot($("#placeholder"), data, { xaxis: { mode: "time" } });
                
            }
        
    	    $.ajax({
        	url: dataurl,
        	method: 'GET',
        	dataType: 'json',
        	success: onDataReceived
    	    });
                setTimeout(fetchData, 10000);
        }

        setTimeout(fetchData, 10000);
});
</script>


