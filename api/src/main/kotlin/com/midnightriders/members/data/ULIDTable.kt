package com.midnightriders.members.data

import com.github.guepardoapps.kulid.ULID
import org.jetbrains.exposed.dao.id.IdTable
import org.jetbrains.exposed.sql.javatime.timestamp
import java.security.SecureRandom

private val secureRandom = SecureRandom()

private const val ENTROPY_BITS = 80
private const val BITS_IN_BYTE = 8

private const val ULID_LENGTH = 26

open class ULIDTable(name: String = "") : IdTable<String>(name) {
    override val id = varchar("id", ULID_LENGTH).clientDefault {
        ULID.generate(System.currentTimeMillis(), randomBytes())
    }.entityId()

    val createdAt = timestamp("created_at")
    val updatedAt = timestamp("updated_at")

    companion object {
        fun randomBytes(): ByteArray {
            val result = ByteArray(ENTROPY_BITS / BITS_IN_BYTE)
            secureRandom.nextBytes(result)
            return result
        }
    }
}
