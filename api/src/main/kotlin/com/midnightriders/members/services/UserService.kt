package com.midnightriders.members.services

import com.midnightriders.members.data.User
import com.midnightriders.members.data.UserEntity
import com.midnightriders.members.data.UserInput
import org.jetbrains.exposed.dao.exceptions.EntityNotFoundException
import org.jetbrains.exposed.sql.transactions.transaction
import org.mindrot.jbcrypt.BCrypt
import org.slf4j.LoggerFactory
import java.security.SecureRandom
import java.time.LocalDateTime

internal class UserService {
    private val logger = LoggerFactory.getLogger(UserService::class.java)

    fun getAllUsers(): List<User> {
        return UserEntity.all().map(UserEntity::toUser)
    }

    fun addUser(user: UserInput, password: String, salt: String): User {
        return transaction {
            val (pepper, digest) = hashPass(password, salt)
            UserEntity.new {
                this.username = user.username
                this.email = user.email
                this.phone = user.phone
                this.firstName = user.firstName
                this.lastName = user.lastName
                this.address = user.address
                this.city = user.city
                this.state = user.state
                this.postalCode = user.postalCode
                this.memberSince = user.memberSince

                this.passwordPepper = pepper
                this.passwordDigest = digest
            }.toUser()
        }
    }

    fun getUser(id: String): User? {
        return try {
            UserEntity[id].toUser()
        } catch (ex: EntityNotFoundException) {
            logger.warn("failed to look up user with ID \"{}\": {}", id, ex.message)
            null
        }
    }
}

private const val PEPPER_LENGTH = 128

private val secureRandom = SecureRandom()

private fun hashPass(password: String, salt: String): Pair<String, String> {
    val bts = ByteArray(124)
    secureRandom.nextBytes(bts)
    val pepper = bts.toString()
    val digest = BCrypt.hashpw(password+salt+pepper, BCrypt.gensalt())
    return pepper to digest
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
