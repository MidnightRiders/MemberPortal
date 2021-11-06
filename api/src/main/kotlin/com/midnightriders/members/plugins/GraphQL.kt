package com.midnightriders.members.plugins

import com.apurebase.kgraphql.GraphQL
import com.midnightriders.members.data.User
import com.midnightriders.members.graphql.scalars
import com.midnightriders.members.graphql.usersSchema
import io.ktor.application.Application
import io.ktor.application.install

fun Application.configureGraphQL() {
    install(GraphQL) {
        playground = environment.config.propertyOrNull("ktor.development")?.getString() == "true"

        schema {
            scalars()
            usersSchema(this@configureGraphQL)
        }
    }
}
