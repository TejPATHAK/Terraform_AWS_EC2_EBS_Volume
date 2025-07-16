provider "aws" {
	region = "ap-south-1"
}

resource "aws_instance" "myweb" {
	ami = "ami-0a1235697f4afa8a4"
	instance_type = "t2.micro"
	key_name = "aws_tf_key_training"
	security_groups = ["my_tf_sg_ssh_allow"]

	tags = {
		Name = "Tejaswi's Web Server"
	}
}

output "o1"  {
	value = aws_instance.myweb.availability_zone
}

resource "aws_ebs_volume" "ebs1" {
	size		  = 2
	availability_zone = aws_instance.myweb.availability_zone
	tags = {
	    Name = "Tejaswi's Web Server Extra Volume"
	  }
}

resource "aws_volume_attachment" "ebs_att" {
  	device_name = "/dev/xvdg"
	volume_id = aws_ebs_volume.ebs1.id
	instance_id = aws_instance.myweb.id

}


resource "null_resource" "nullremote1" {

	provisioner "remote-exec" {
	
		inline = [
			"sudomks.xfs  /dev/xvdb" ,
			"sudo yum install httpd -y" ,
			"sudo mount  /dev/xvdb /var/www/html",
			"sudo sh -c 'echo 'welcome to World of Linux by Tejaswi Pathak!' > /var/www/html/index.html'" ,
			"sudo systemctl restart httpd"
			]
	}


	connection {
		type = "ssh"
		user = "ec2-user"
		private_key = file("C:/Users/Pathak/Downloads/aws_tf_key_training.pem")
		host = aws_instance.myweb.public_ip
			}
}


resource "null_resource" "nulllocalchrome" {
	provisioner "local-exec" {
		command = "chrome http"//${aws_instance.myweb.public_ip}/"
		}
}