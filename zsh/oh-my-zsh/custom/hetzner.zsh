function hstart {
  curl \
  	-X POST \
  	-H "Authorization: Bearer $HETZNER_API_TOKEN" \
  	-H "Content-Type: application/json" \
  	-d '{"image":"ubuntu-22.04","location":"hil","name": "cloud","server_type":"cpx11","user_data":"#include\nhttps://raw.githubusercontent.com/erichsend/workstation/main/cloud-init.yaml"}' \
    	'https://api.hetzner.cloud/v1/servers'
}

function hlist {
  curl \
  	-X GET \
  	-H "Authorization: Bearer $HETZNER_API_TOKEN" \
    	'https://api.hetzner.cloud/v1/servers'
}
