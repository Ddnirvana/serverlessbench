

function main(params){
    return new Promise(function(resolve,reject){
        var startTime = Date.now();
        var http = require('http');
        var server = http.createServer().listen(4567);
        var httprequest = require("request")
        server.on('close', function () {
            console.log('close event', Date.now());
        });
    
        server.on('request', function (req, res) {
            var requestTime = Date.now().toString();
            server.close(function () {
                console.log('server closed!', Date.now());
            });
            
            res.end('[{\"requestTime\": ' + requestTime +', \"responseTime\": ' + Date.now().toString()+'}]');
        })
    
        httprequest('http://127.0.0.1:4567',{ json:true},(err,res,body)=>{
            if(err){
                return console.log(err)
            }
            console.log(body)
            var retTime = Date.now()
            resolve ({
                result:"end function",
                startTime:startTime,
                retTime:retTime,
                body:body
            })
        })
        
    })
    
}

//console.log(main())