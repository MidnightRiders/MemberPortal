package com.midnightriders.members

import com.zaxxer.hikari.HikariConfig
import com.zaxxer.hikari.HikariDataSource
import io.ktor.application.Application
import liquibase.Liquibase
import liquibase.database.jvm.JdbcConnection
import liquibase.resource.ClassLoaderResourceAccessor
import liquibase.resource.CompositeResourceAccessor
import liquibase.resource.FileSystemResourceAccessor
import org.jetbrains.exposed.sql.Database
import org.slf4j.LoggerFactory

private val logger = LoggerFactory.getLogger("Application.initDB")

fun Application.initDB() {
    val hikariConfig = HikariConfig().also {
        it.jdbcUrl = System.getenv("JDBC_DATABASE_URL")
        it.username = System.getenv("JDBC_DATABASE_USERNAME")
        it.password = System.getenv("JDBC_DATABASE_PASSWORD")
    }
    val hikariDataSource = HikariDataSource(hikariConfig)
    val ra = CompositeResourceAccessor(FileSystemResourceAccessor(), ClassLoaderResourceAccessor())
    val lqb = Liquibase(
        "db/main.yaml",
        ra,
        JdbcConnection(hikariDataSource.connection),
    )
    lqb.update("main")
    Database.connect(hikariDataSource)
    logger.info("Initialized Database")
}
