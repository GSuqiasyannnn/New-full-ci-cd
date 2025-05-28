variable cidr_block {
    type = string
    default = "10.127.0.0/16"
}

variable public_subnets {
    type = list(string)
    default = [
	"10.127.1.0/24",
	"10.127.3.0/24"
    ] 
} 


variable private_subnets {
    type = list(string)
    default = [
        "10.127.2.0/24",
        "10.127.4.0/24"
    ]
}

variable main_vol_size {
    type    = number
    default = 30

}

variable aws_access_key {
    type    = string
    #default = ${{ secrets.AWS_ACCESS_KEY }}
}

variable aws_secret_key {
    type    = string
    #default = ${{ secrets. AWS_SECRET_KEY }}
}
