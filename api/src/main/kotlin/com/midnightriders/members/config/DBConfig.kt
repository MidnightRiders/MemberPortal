package com.midnightriders.members.config

internal class DBConfig(
    jdbcUrl: String,
) {
    val dbname: String
    val host: String
    val password: String
    val port: Int
    val protocol: String
    val query: String
    val username: String

    init {
        val jdbcParts = (
            jdbcUrlRegex.matchEntire(jdbcUrl)
                ?: throw IllegalStateException("jdbcUrl is malformed")
            ).groups
        dbname = jdbcParts["dbname"]!!.value
        host = jdbcParts["host"]!!.value
        password = jdbcParts["password"]!!.value
        port = jdbcParts["port"]?.value?.toInt() ?: defaultPort
        protocol = jdbcParts["protocol"]?.value ?: "postgresql://"
        query = jdbcParts["query"]?.value ?: ""
        username = jdbcParts["username"]!!.value
    }

    val jdbcUrl: String
        get() {
            return "jdbc:$protocol$host:$port/$dbname?$query"
        }

    override fun toString(): String {
        return mapOf(
            "dbname" to dbname,
            "host" to host,
            "password" to password.replace(Regex("."), "x"),
            "port" to port,
            "protocol" to protocol,
            "query" to query,
            "username" to username,
        ).toString()
    }

    companion object {
        private const val defaultPort = 5432

        private val jdbcUrlRegex = Regex(
            "^(?<protocol>postgresql://)?(?:(?<username>.+?):(?<password>.+?)@)?(?<host>.+?)"+
                "(?::(?<port>[0-9]+))?/(?<dbname>.*?)(?:\\?(?<query>.+))?$",
        )
    }
}
