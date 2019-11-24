s3:
	rm -f terraform.tfstate* || true
	terraform apply -var="bucket_name=$(name)"
