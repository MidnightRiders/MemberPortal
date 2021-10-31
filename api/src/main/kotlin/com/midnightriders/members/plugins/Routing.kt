package com.midnightriders.members.plugins

import io.ktor.application.Application
import io.ktor.application.call
import io.ktor.http.content.resources
import io.ktor.http.content.static
import io.ktor.response.respondText
import io.ktor.routing.get
import io.ktor.routing.routing

fun Application.configureRouting() {
    routing {
        get("/") {
            call.respondText("Hello World!")
        } // Static plugin. Try to access `/static/index.html`
        static("/static") {
            resources("static")
        }
    }
}
