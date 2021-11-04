package com.midnightriders.members.data

import org.jetbrains.exposed.dao.Entity
import org.jetbrains.exposed.dao.EntityClass
import org.jetbrains.exposed.dao.id.EntityID
import java.time.Instant

@Suppress("MagicNumber")
internal object Users : ULIDTable() {
    val memberID = integer("member_id").autoIncrement()
    val username = varchar("username", 64)
    val email = varchar("email", 255)
    val firstName = varchar("first_name", 255)
    val lastName = varchar("last_name", 255)
    val address = varchar("address", 255)
    val city = varchar("city", 255)
    val state = varchar("state", 255)
    val postalCode = varchar("postal_code", 255)
    val country = varchar("country", 255)
    val stripeCustomerToken = varchar("stripe_customer_token", 255)

    val passwordDigest = varchar("password_digest", 255)
}

internal class UserEntity(id: EntityID<String>) : Entity<String>(id) {
    companion object : EntityClass<String, UserEntity>(Users)

    var memberID by Users.memberID
    var username by Users.username
    var email by Users.email
    var firstName by Users.firstName
    var lastName by Users.lastName
    var address by Users.address
    var city by Users.city
    var state by Users.state
    var postalCode by Users.postalCode
    var country by Users.country

    var createdAt by Users.createdAt
    var updatedAt by Users.updatedAt

    var passwordDigest by Users.passwordDigest
    var stripeCustomerToken by Users.stripeCustomerToken

    fun toUser() = User(
        id = id.value,
        memberID = memberID,
        username = username,
        email = email,
        firstName = firstName,
        lastName = lastName,
        address = address,
        city = city,
        state = state,
        postalCode = postalCode,
        country = country,

        createdAt = createdAt,
        updatedAt = updatedAt,
    )
}

internal data class User(
    val id: String,
    val memberID: Int,
    val username: String,
    val email: String,
    val firstName: String?,
    val lastName: String?,
    val address: String?,
    val city: String?,
    val state: String?,
    val postalCode: String?,
    val country: String?,

    val createdAt: Instant,
    val updatedAt: Instant,
)
