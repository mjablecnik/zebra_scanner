mock "GET /dapi/v1/user" {
    status = 200
    headers {
        Content-Type = "application/json"
    }
    body = <<EOF
{
    "firstName": "Martin",
    "id": 67,
    "lastName": "Jablecnik",
    "username": "ML123"
} 
EOF
}

mock "GET /dapi/v1/device/register" {
    status = 200
}

mock "GET /dapi/v1/health" {
    status = 200
}
