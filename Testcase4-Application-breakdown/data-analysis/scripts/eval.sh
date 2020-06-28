#!/bin/bash

# This script should be invoked in parent dir of scripts

if [ -z "$SERVERLESSBENCH_HOME" ]; then
    echo "$0: ERROR: SERVERLESSBENCH_HOME environment variable not set"
    exit
fi
source $SERVERLESSBENCH_HOME/local.env
source $SERVERLESSBENCH_HOME/eval-config

SCRIPTS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

couchdb_url=http://$COUCHDB_USERNAME:$COUCHDB_PASSWORD@$COUCHDB_IP:$COUCHDB_PORT

function clearDB() {
  echo "Removing rules..."
  if [[ $(wsk -i rule list | grep data-analysis) ]]; then
      wsk -i rule disable data-analysis
      sleep 1
      wsk -i rule delete data-analysis
  fi

  echo "Removing triggers..."
  if [[ $(wsk -i trigger list | grep data-inserted) ]]; then
    wsk -i trigger delete data-inserted
  fi

  echo "Re-creating databases"
  curl -X DELETE $couchdb_url/$WAGE_COUCHDB_DATABASE
  curl -X DELETE $couchdb_url/$WAGE_COUCHDB_DATABASE_STATISTICS
  curl -X PUT $couchdb_url/$WAGE_COUCHDB_DATABASE
  curl -X PUT $couchdb_url/$WAGE_COUCHDB_DATABASE_STATISTICS

  echo "Inserting initial database records..."

  if [ ! -f $SCRIPTS_DIR/records.json ]; then
    echo "Creating initial records to post to couchdb..."
    $SCRIPTS_DIR/records_generator.sh $record_num
  fi

  curl -H 'Content-Type: application/json' \
       -X POST $couchdb_url/$WAGE_COUCHDB_DATABASE/_bulk_docs \
       --data "@$SCRIPTS_DIR/records.json"

  echo "Creating trigger to fire events when data is inserted"
  wsk -i trigger create data-inserted \
    --feed "/_/$WAGE_COUCHDB_INSTANCE/changes" \
    --param dbname "$WAGE_COUCHDB_DATABASE"

  echo "Creating rule that maps database change trigger to sequence"
  wsk -i rule update data-analysis data-inserted wage-analysis-sequence

}

result=eval-result.log
rm -f $result 

echo "1. measuring cold-invoke..."
clearDB
$SCRIPTS_DIR/run-single.sh -m cold -t $cold_loop -r $result

echo "2. measuring warm-inovke..."
clearDB
$SCRIPTS_DIR/run-single.sh -m warm -t $warm_loop -w $warm_warmup -r $result

echo "3. measuring concurrent invoking..."
clearDB
python3 $SCRIPTS_DIR/run.py $concurrent_client $concurrent_loop $concurrent_warmup

echo "data-analysis application running result: "
cat $result
