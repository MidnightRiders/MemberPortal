package com.midnightriders.members.plugins

import com.midnightriders.members.services.UserService
import io.ktor.application.Application
import io.ktor.application.install
import org.kodein.di.bind
import org.kodein.di.ktor.DIFeature
import org.kodein.di.ktor.di
import org.kodein.di.singleton

fun Application.configureDI() {
    install(DIFeature) {
        di {
            bind<UserService>() with singleton { UserService() }
        }
    }
}
