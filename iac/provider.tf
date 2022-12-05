provider "aws" {
  profile = "default"
  region  = "eu-west-2"
  default_tags {
    tags = {
      Environment = "Demo",
      Owner = "Steven"
      ApplicationName = "Merapar IAC Demo"
      ApplicationVersion = "0.1"
    }
  }
}