config_secrets = {
  dc = {
    base_url    = "https://fen.rdc-staging.library.northwestern.edu/"
  }
  ezid = {
    password    = "apitest"
    shoulder    = "ark:/99999/fk4"
    user        = "apitest"
  }

  geonames = {
    username    = "<%= ENV['GEONAMES_USERNAME'] %>"
  }

  iiif = {
    base_url     = "https://devbox.library.northwestern.edu:8183/iiif/2/"
    manifest_url = "https://dev-pyramids.s3.localhost.localstack.cloud:4566/public/"
  }
  
  nusso = {
    api_key     = "<%= ENV['NUSSO_API_KEY'] %>"
    base_url    = "https://northwestern-test.apigee.net/agentless-websso/"
  }

  streaming = {
    base_url    = "https://dev-streaming.s3.localhost.localstack.cloud:4566/"
  }
}

ssl_certificate_file    = "/usr/local/etc/devbox_ssl/devbox.library.full.pem"
ssl_key_file            = "/usr/local/etc/devbox_ssl/devbox.library.key.pem"
