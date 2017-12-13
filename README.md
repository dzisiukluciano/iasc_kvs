# IascKvs

mix deps.get
mix compile


levantar nodos workers:
./apps/kv_worker/run.sh 1
./apps/kv_worker/run.sh 2
./apps/kv_worker/run.sh 3

levantar server/orquestador
./apps/kv_server/run.sh

levantar api rest
./apps/client/run.sh


curl -X GET http://localhost:8888/size
curl -X POST "http://localhost:8888/entries?key=k1&value=v1" | python -mjson.tool
curl -X GET http://localhost:8888/entries/k1
curl -X DELETE http://localhost:8888/entries/k1
curl -X GET http://localhost:8888/entries?values_gt=v2
