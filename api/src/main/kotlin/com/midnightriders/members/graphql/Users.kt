package com.midnightriders.members.graphql

import com.apurebase.kgraphql.schema.dsl.SchemaBuilder
import com.midnightriders.members.data.User
import com.midnightriders.members.data.UserInput
import com.midnightriders.members.services.UserService
import io.ktor.application.Application
import org.kodein.di.instance
import org.kodein.di.ktor.closestDI

internal fun SchemaBuilder.usersSchema(app: Application) {
    inputType<UserInput>()
    type<User>()

    query("users") {
        resolver { ->
            val userService by closestDI { app }.instance<UserService>()
            userService.getAllUsers()
        }
    }

    query("user") {
        resolver { id: String ->
            val userService by closestDI { app }.instance<UserService>()
            userService.getUser(id)
        }
    }

    mutation("createUser") {
        resolver { user: UserInput, password: String ->
            val userService by closestDI { app }.instance<UserService>()
            userService.addUser(user, password, app.environment.config.property("ktor.salt").getString())
        }
    }
}
