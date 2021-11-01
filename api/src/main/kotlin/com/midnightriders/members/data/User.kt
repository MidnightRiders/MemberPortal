package com.midnightriders.members.data

import org.jetbrains.exposed.dao.Entity
import org.jetbrains.exposed.dao.EntityClass
import org.jetbrains.exposed.dao.id.EntityID

@Suppress("MagicNumber")
internal object Users : ULIDTable() {
    val username = varchar("username", 64)
    val email = varchar("email", 255)
    val passwordDigest = varchar("password_digest", 255)
}

internal class UserEntity(id: EntityID<String>) : Entity<String>(id) {
    companion object : EntityClass<String, UserEntity>(Users)

    var username by Users.username
    var email by Users.email
    var passwordDigest by Users.passwordDigest

    fun toUser() = User(id.value, username, email)
}

internal data class User(
    val id: String,
    val username: String,
    val email: String,
)
