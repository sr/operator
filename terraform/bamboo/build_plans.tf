resource "bamboo_build_plan" "BREAD-BREAD" {
  key                   = "BREAD-BREAD"
  name                  = "bread"
  default_repository_id = "${bamboo_repository.bread.id}"
}
