package com.midnightriders.members

import com.midnightriders.members.data.Users
import com.zaxxer.hikari.HikariConfig
import com.zaxxer.hikari.HikariDataSource
import io.ktor.application.Application
import org.jetbrains.exposed.sql.Database
import org.jetbrains.exposed.sql.SchemaUtils
import org.jetbrains.exposed.sql.transactions.transaction
import org.slf4j.LoggerFactory

fun Application.initDB() {
    val hikariConfig = HikariConfig().also {
        it.dataSourceClassName = "org.postgresql.Driver"
        it.jdbcUrl = environment.config.property("hikari.jdbcUrl").getString()
    }
    val hikariDataSource = HikariDataSource(hikariConfig)
    Database.connect(hikariDataSource)
    createTables()
    LoggerFactory.getLogger(Application::class.simpleName).info("Initialized Database")
}

private fun createTables() = transaction {
    SchemaUtils.create(
        Users
    )
}
