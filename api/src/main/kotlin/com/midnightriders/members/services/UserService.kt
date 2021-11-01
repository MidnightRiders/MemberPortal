package com.midnightriders.members.services;

import com.midnightriders.members.data.User;
import com.midnightriders.members.data.UserEntity
import org.jetbrains.exposed.sql.transactions.transaction

internal class UserService {
    fun getAllUsers(): Iterable<User> {
        return UserEntity.all().map(UserEntity::toUser)
    }

    fun addUser(user: User, password: String) {
        return transaction {
            UserEntity.new {
                this.username = user.username
                this.email = user.email
                this.passwordDigest = password // TODO
            }
        }
    }
}
