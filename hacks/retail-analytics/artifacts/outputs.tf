output "orcl_db_ip" {
  value = google_compute_address.oracle_vm_eip.address
}

output "orcl_datastream_usr" {
    value = "datastream"
}

output "orcl_datastream_pwd" {
    value = random_string.datastream_user_password.result
}