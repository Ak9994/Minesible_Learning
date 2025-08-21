variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.medium"
}

variable "minecraft_s3_bucket" {
  description = "S3 bucket to store Minecraft saves"
  type        = string
  default     = "minesible-world-backup"
}

variable "motd" {
  description = "Minecraft server MOTD"
  type        = string
  #\u00A75 + u00A7r are minecraft color codes
  default     = "   \u00A75 [🚀 managed minecraft server 🚀]\u00A7r\n \u00A7d\u00A7ka\u00A7r ~ \u00A78\u00A7lminesible server 1.21.6\u00A7r ~ \u00A7d\u00A7ka\u00A7r"
}

variable "max_players" {
  description = "Maximum number of players"
  type        = number
  default     = "10"
}
