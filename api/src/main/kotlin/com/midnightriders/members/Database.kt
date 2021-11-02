package com.midnightriders.members

import com.midnightriders.members.data.Users
import com.zaxxer.hikari.HikariConfig
import com.zaxxer.hikari.HikariDataSource
import io.ktor.application.Application
import kotlinx.coroutines.launch
import org.jetbrains.exposed.sql.Database
import org.jetbrains.exposed.sql.SchemaUtils
import org.jetbrains.exposed.sql.transactions.transaction
import org.slf4j.LoggerFactory
import java.lang.IllegalStateException

private val jdbcUrlRegex = Regex(
    "^(?<protocol>postgresql://)?(?:(?<username>.+?):(?<password>.+?)@)?(?<host>.+?)"+
        "(?::(?<port>[0-9]+))?/(?<dbname>.*?)(?:\\?(?<query>.+))?$",
)

private val logger = LoggerFactory.getLogger("Application.initDB")

fun Application.initDB() {
    val hikariConfig = HikariConfig().also {
        val jdbcUrl = environment.config.property("hikari.jdbcUrl").getString()
        val jdbcParts = (
            jdbcUrlRegex.matchEntire(jdbcUrl)
                ?: throw IllegalStateException("jdbcUrl is malformed")
        ).groups
        val protocol = jdbcParts["protocol"]?.value ?: "postgresql://"
        val username = jdbcParts["username"]!!.value
        val password = jdbcParts["password"]!!.value
        val host = jdbcParts["host"]!!.value
        val port = jdbcParts["port"]?.value ?: "5432"
        val dbname = jdbcParts["dbname"]!!.value
        val query = jdbcParts["query"]?.value ?: ""
        logger.debug("jdbc parts: {}", mapOf(
            "protocol" to protocol,
            "username" to username,
            "password" to password.replace(Regex("."), "x"),
            "host" to host,
            "port" to port,
            "dbname" to dbname,
            "query" to query,
        ))
        it.jdbcUrl = "jdbc:$protocol$host:$port/$dbname?$query"
        it.username = username
        it.password = password
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
