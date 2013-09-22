# Copyright 2012-2013 Amazon.com, Inc. or its affiliates. All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License"). You
# may not use this file except in compliance with the License. A copy of
# the License is located at
#
#     http://aws.amazon.com/apache2.0/
#
# or in the "license" file accompanying this file. This file is
# distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF
# ANY KIND, either express or implied. See the License for the specific
# language governing permissions and limitations under the License.

helpers = require('../helpers')
AWS = helpers.AWS

require('../../lib/services/sts')

describe 'AWS.STS', ->

  sts = null
  beforeEach ->
    sts = new AWS.STS()

  describe 'credentialsFrom', ->
    it 'creates a TemporaryCredentials object with hydrated data', ->
      creds = sts.credentialsFrom Credentials:
         AccessKeyId: 'KEY'
         SecretAccessKey: 'SECRET'
         SessionToken: 'TOKEN'
         Expiration: new Date(0)
      expect(creds instanceof AWS.TemporaryCredentials)
      expect(creds.accessKeyId).toEqual('KEY')
      expect(creds.secretAccessKey).toEqual('SECRET')
      expect(creds.sessionToken).toEqual('TOKEN')
      expect(creds.expireTime).toEqual(new Date(0))
      expect(creds.expired).toEqual(false)

    it 'creates a TemporaryCredentials object with hydrated data', ->
      data = Credentials:
         AccessKeyId: 'KEY'
         SecretAccessKey: 'SECRET'
         SessionToken: 'TOKEN'
         Expiration: new Date(0)
      creds = new AWS.Credentials
      sts.credentialsFrom(data, creds)
      expect(creds instanceof AWS.Credentials)
      expect(creds.accessKeyId).toEqual('KEY')
      expect(creds.secretAccessKey).toEqual('SECRET')
      expect(creds.sessionToken).toEqual('TOKEN')
      expect(creds.expireTime).toEqual(new Date(0))
      expect(creds.expired).toEqual(false)

  describe 'assumeRoleWithWebIdentity', ->
    service = new AWS.STS

    it 'sends an unsigned GET request (params in query string)', ->
      helpers.mockHttpResponse 200, {}, '{}'
      params = RoleArn: 'ARN', RoleSessionName: 'NAME', WebIdentityToken: 'TOK'
      service.assumeRoleWithWebIdentity params, ->
        hr = @request.httpRequest
        expect(hr.method).toEqual('GET')
        expect(hr.body).toEqual('')
        expect(hr.headers['Authorization']).toEqual(undefined)
        expect(hr.headers['Content-Type']).toEqual(undefined)
        expect(hr.path).toEqual('/?Action=AssumeRoleWithWebIdentity&' +
          'RoleArn=ARN&RoleSessionName=NAME&Version=' +
          service.api.apiVersion + '&WebIdentityToken=TOK')
