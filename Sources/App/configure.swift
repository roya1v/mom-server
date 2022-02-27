import Fluent
import FluentSQLiteDriver
import Vapor

// configures your application
public func configure(_ app: Application) throws {
    // uncomment to serve files from /Public folder
    // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))


    switch app.environment {
    case .production:
        app.databases.use(.sqlite(.file("prod.sqlite")), as: .sqlite)
    default:
        app.databases.use(.sqlite(.file("db.sqlite")), as: .sqlite)
    }

    app.migrations.add(CreateTodo())
    app.migrations.add(CreateGarment())
    app.migrations.add(CreateStorageLocation())
    app.migrations.add(CreateStorageEntity())

    // register routes
    try routes(app)
}
