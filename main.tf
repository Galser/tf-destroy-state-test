resource "random_string" "random" {
  length = 8
  special = true
  override_special = "/@£$"
  keepers = {
	timest = timestamp()
 }
}


output "random" {
 value = random_string.random.result
}
