#!/bin/bash
END=$ACME_ITERATIONS
#SOMNS_HOME="/Users/dominikaumayr/Documents/Workspaces/SOMns"
SOMNS_EXEC="$SOMNS_HOME/fast"
ADDRESS="localhost"
PORT=9080
NUM_CUSTOMERS=10000
LOOPCOUNT=10000
THREADS=1
LOAD_URL="http://$ADDRESS:$PORT/rest/api/loader/load?numCustomers=$NUM_CUSTOMERS"

echo "$ADDRESS,$PORT,">hosts.csv

function silentCountDown() {
  COUNTER=$1
  while [  $COUNTER -gt 0 ]; do
    let COUNTER=COUNTER-1 
    sleep 1
  done
}

if [ ! -d "logs" ]; then
  mkdir logs
fi

echo "############ Traced ############"
for i in $(seq 1 $END)
do
  echo "### Iteration $i/$END"
  $SOMNS_EXEC -JXmx5g ./../../../app.ns -clearDB &
  pid=$!
  silentCountDown 5

  echo "# Preparing Database..."
  curl -X GET $LOAD_URL

  kill -9 $pid

  #wait for server to start
  silentCountDown 5

  echo "# Starting Acme-Air"
  $SOMNS_EXEC -at -JXmx5g ./../../../app.ns >> AT_$i.log &
  pid=$!
  echo $pid

  silentCountDown 10

  echo "# Starting JMeter..."
  args=" -n -t AcmeAir.jmx -JNUM_THREAD=$THREADS -JLOOP_COUNT=$LOOPCOUNT -DusePureIDs=true -j logs/AcmeAir_AT$1.log -l logs/AcmeAir_AT$i.jtl"
  bash ./../../../jmeter/bin/jmeter $args

  echo "# Killing AcmeAir"
  kill -9 $pid
  silentCountDown 5
done

echo "############ Untraced ############"
for i in $(seq 1 $END)
do
  echo "### Iteration $i/$END"
  $SOMNS_EXEC -JXmx5g ./../../../app.ns -clearDB &
  pid=$!
  silentCountDown 5

  echo "# Preparing Database..."
  curl -X GET $LOAD_URL

  kill -9 $pid

  #wait for server to start
  silentCountDown 5

  echo "# Starting Acme-Air"
  $SOMNS_EXEC -JXmx5g ./../../../app.ns >> AT_$i.log &
  pid=$!
  echo $pid

  silentCountDown 10

  echo "# Starting JMeter..."
  args=" -n -t AcmeAir.jmx -JNUM_THREAD=$THREADS -JLOOP_COUNT=$LOOPCOUNT -DusePureIDs=true -j logs/AcmeAir$1.log -l logs/AcmeAir$i.jtl"
  bash ./../../../jmeter/bin/jmeter $args

  echo "# Killing AcmeAir"
  kill -9 $pid
  silentCountDown 5
done

#bash ./slackpost.sh "https://hooks.slack.com/services/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" "Benchmarks are Done!"
