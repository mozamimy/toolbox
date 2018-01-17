#!/usr/bin/env ruby

require 'aws-sdk-kms'

kms = Aws::KMS::Client.new
kms_resp = kms.decrypt({
  ciphertext_blob: Base64.decode64(STDIN.read),
})

puts kms_resp.plaintext
