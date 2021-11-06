package com.midnightriders.members.data

import org.jetbrains.exposed.dao.Entity
import org.jetbrains.exposed.dao.EntityClass
import org.jetbrains.exposed.dao.id.EntityID
import java.time.LocalDateTime
import java.time.ZoneOffset

@Suppress("MagicNumber")
internal object Users : ULIDTable() {
    val memberID = integer("member_id").autoIncrement()
    val username = varchar("username", 64)
    val email = varchar("email", 255)
    val phone = varchar("phone", 10).nullable()
    val firstName = varchar("first_name", 255).nullable()
    val lastName = varchar("last_name", 255).nullable()
    val address = varchar("address", 255).nullable()
    val city = varchar("city", 255).nullable()
    val state = varchar("state", 255).nullable()
    val postalCode = varchar("postal_code", 255).nullable()
    val country = varchar("country", 255).nullable()
    val memberSince = integer("member_since").nullable()

    val stripeCustomerToken = varchar("stripe_customer_token", 255).nullable()
    val passwordPepper = varchar("password_pepper", 128)
    val passwordDigest = varchar("password_digest", 255)
}

internal class UserEntity(id: EntityID<String>) : Entity<String>(id) {
    companion object : EntityClass<String, UserEntity>(Users)

    var memberID by Users.memberID
    var username by Users.username
    var email by Users.email
    var phone by Users.phone
    var firstName by Users.firstName
    var lastName by Users.lastName
    var address by Users.address
    var city by Users.city
    var state by Users.state
    var postalCode by Users.postalCode
    var country by Users.country
    var memberSince by Users.memberSince

    var createdAt by Users.createdAt
    var updatedAt by Users.updatedAt

    var passwordPepper by Users.passwordPepper
    var passwordDigest by Users.passwordDigest
    var stripeCustomerToken by Users.stripeCustomerToken

    fun toUser() = User(
        id = id.value,
        memberID = memberID,
        username = username,
        email = email,
        phone = phone,
        firstName = firstName,
        lastName = lastName,
        address = address,
        city = city,
        state = state,
        postalCode = postalCode,
        country = country,
        memberSince = memberSince,

        createdAt = LocalDateTime.ofInstant(createdAt, ZoneOffset.UTC),
        updatedAt = LocalDateTime.ofInstant(updatedAt, ZoneOffset.UTC),
    )
}

internal data class User(
    val id: String,
    val memberID: Int,
    val username: String,
    val email: String,
    val phone: String?,
    val firstName: String?,
    val lastName: String?,
    val address: String?,
    val city: String?,
    val state: String?,
    val postalCode: String?,
    val country: String?,
    val memberSince: Int?,

    val createdAt: LocalDateTime,
    val updatedAt: LocalDateTime,
)

internal data class UserInput(
    val username: String,
    val email: String,
    val phone: String?,
    val firstName: String?,
    val lastName: String?,
    val address: String?,
    val city: String?,
    val state: String?,
    val postalCode: String?,
    val country: String?,
    val memberSince: Int?,
)

