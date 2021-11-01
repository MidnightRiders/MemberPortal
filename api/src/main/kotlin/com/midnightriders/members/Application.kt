package com.midnightriders.members

import com.midnightriders.members.plugins.configureRouting
import com.midnightriders.members.plugins.configureSecurity
import com.midnightriders.members.plugins.configureSerialization
import com.typesafe.config.ConfigFactory
import io.ktor.config.HoconApplicationConfig
import io.ktor.server.engine.applicationEngineEnvironment
import io.ktor.server.engine.connector
import io.ktor.server.engine.embeddedServer
import io.ktor.server.netty.Netty

fun main() {
    val cfg = HoconApplicationConfig(ConfigFactory.load())
    val devMode = cfg.propertyOrNull("ktor.development")?.getString() == "true"
    embeddedServer(
        Netty,
        environment = applicationEngineEnvironment {
            config = cfg
            connector {
                host = cfg.property("ktor.deployment.host").getString()
                port = cfg.property("ktor.deployment.port").getString().toInt()
            }
            developmentMode = devMode
            module {
                initDB()
                configureRouting()
                configureSecurity()
                configureSerialization()
            }
        },
    ).start()
}
