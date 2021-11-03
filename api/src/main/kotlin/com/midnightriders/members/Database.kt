package com.midnightriders.members

import com.midnightriders.members.config.DBConfig
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
        val cfg = DBConfig(environment.config.property("hikari.jdbcUrl").getString())
        logger.debug("jdbc parts: {}", cfg)
        it.jdbcUrl = cfg.jdbcUrl
        it.username = cfg.username
        it.password = cfg.password
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
    LoggerFactory.getLogger(Application::class.simpleName).info("Initialized Database")
}
