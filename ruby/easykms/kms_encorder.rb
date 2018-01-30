#!/usr/bin/env ruby

require 'aws-sdk-kms'

key_id = ARGV[0]
kms_resp = Aws::KMS::Client.new.encrypt({
  key_id: key_id,
  plaintext: STDIN.read,
})

print Base64.strict_encode64(kms_resp.ciphertext_blob)
