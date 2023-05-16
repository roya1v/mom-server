import Fluent
import FluentPostgresDriver
import Vapor

// configures your application
public func configure(_ app: Application) throws {

    app.databases.use(.postgres(
        hostname: Environment.get("DATABASE_HOST") ?? "localhost",
        port: Environment.get("DATABASE_PORT").flatMap(Int.init(_:)) ?? PostgresConfiguration.ianaPortNumber,
        username: Environment.get("DATABASE_USERNAME") ?? "vapor_username",
        password: Environment.get("DATABASE_PASSWORD") ?? "vapor_password",
        database: Environment.get("DATABASE_NAME") ?? "vapor_database"
    ), as: .psql)

    app.minio = MinioService(
        host: Environment.get("MINIO_HOST") ?? "127.0.0.1",
        accessKeyId: Environment.get("MINIO_ACCESS_KEY_ID") ?? "vapor_acces_key",
        secretAccessKey: Environment.get("MINIO_SECRET_ACCESS_KEY") ?? "vapor_secret_acces")

    app.migrations.add(CreateStorageLocation())
    app.migrations.add(CreateExpiration())
    app.migrations.add(CreateStorageEntity())
    app.routes.defaultMaxBodySize = "10mb"

    try routes(app)
}
