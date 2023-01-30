//
//  MinioService.swift
//  
//
//  Created by Mike Shevelinsky on 26/10/2022.
//

import Vapor
import SotoS3

class MinioService {

    private let client: AWSClient
    private let s3: S3

    init(host: String,
         accessKeyId: String,
         secretAccessKey: String) {
        client = AWSClient(credentialProvider: .static(accessKeyId: accessKeyId,
                                                       secretAccessKey: secretAccessKey),
                           httpClientProvider: .createNew)
        s3 = S3(client: client, endpoint: "http://\(host):9000")
    }

    func get(bucket: String, key: String) async throws -> Data {
        try await s3.getObject(S3.GetObjectRequest(bucket: bucket, key: key)).body!.asData()!
    }

    func put(data: ByteBuffer, bucket: String, key: String) async throws {
        let request = S3.PutObjectRequest(acl: .publicRead, body: AWSPayload.byteBuffer(data), bucket: bucket, key: key)

        try await _ = s3.putObject(request)
    }

    deinit {
        try! client.syncShutdown()
    }
}

struct MinioServiceKey: StorageKey {
    typealias Value = MinioService
}

extension Request {
    var minio: MinioService {
        self.application.storage[MinioServiceKey.self]!
    }
}

extension Application {
    var minio: MinioService? {
        get {
            self.storage[MinioServiceKey.self]
        }
        set {
            self.storage[MinioServiceKey.self] = newValue
        }
    }
}
