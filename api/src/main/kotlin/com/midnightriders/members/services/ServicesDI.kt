package com.midnightriders.members.services

import org.kodein.di.DI
import org.kodein.di.bind
import org.kodein.di.singleton

fun DI.MainBuilder.bindServices() {
    bind<UserService>() with singleton { UserService() }
}
