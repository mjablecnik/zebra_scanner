mock "GET /dapi/v1/barcode/types" {
    status = 200
    headers {
        Content-Type = "application/json"
    }
    body = <<EOF
{
  "types": [
    {
      "id": "1",
      "name": "Type1"
    },
    {
      "id": "2",
      "name": "Type2"
    },
    {
      "id": "3",
      "name": "Type3"
    },
    {
      "id": "4",
      "name": "Type4"
    },
    {
      "id": "5",
      "name": "Type5"
    },
    {
      "id": "6",
      "name": "Type6"
    }
  ]
}
EOF
}

mock "POST /dapi/v1/barcode/type/3/send" {
    status = 200
    headers {
        Content-Type = "application/json"
    }
    data = "{'codes':[{'code': 'JC123','note': 'test123'},{'code': 'JC124','note': ''},{'code': 'JC125','note': ''}]}"
}
