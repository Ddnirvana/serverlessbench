/**
 * @param   params.COUCHDB_URL                    Couchdb url
 * @param   params.COUCHDB_DATABASE               Couchdb database to store the file to
 *
 * @return  Promise
 */
function main(params) {
  console.log('[wage-analysis-result] entry');

  // update statistics database
  // Configure database connection
  var couchdb = require('nano')(params.COUCHDB_URL) 
  var database = couchdb.db.use(params.COUCHDB_DATABASE_STATISTICS);
  delete params.COUCHDB_URL;
  delete params.COUCHDB_DATABASE_STATISTICS;

  // this log marks finishing of data analysis
  console.log('[', params['operator'], '] wage analysis result: ', JSON.stringify({'statistics': params}));

  return new Promise(function(resolve, reject) {

    database.get('statistics', (error, body) => {
        if (!error) {
//            console.log('existing statistics doc:', JSON.stringify(body));

            body['statistics'] = params;

            database.insert(body)
                    .then((response) => {
                        console.log('couchdb insert success with', JSON.stringify(response));
                        resolve(response);
                    }).catch( err => {
                        console.log('fail to insert', err);
                        reject(err);
                    });
        } else {
            if (error.statusCode === 404) {
//                console.log('statistics doc not existing, adding.');
           
                var stats = {'statistics': params};

                database.insert(stats, 'statistics')
                    .then((response) => {
                        console.log('couchdb insert success with', JSON.stringify(response));
                        resolve(response);
                    }).catch( err => {
                        console.log('fail to insert', err);
                        reject(err);
                    });
            } else {
                console.log('database get error:', error);
                reject(error);
            }
        }
    });
  });
}

exports.main = main
