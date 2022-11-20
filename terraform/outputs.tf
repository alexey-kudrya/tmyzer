output "ec2_publick_ip" {
  value       = aws_instance.tmyzer.public_ip
  description = "The public ip of the tmyzer instance"
}
