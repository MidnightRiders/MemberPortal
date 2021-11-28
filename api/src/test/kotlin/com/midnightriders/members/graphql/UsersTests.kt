package com.midnightriders.members.graphql

import com.apurebase.kgraphql.KGraphQL
import com.midnightriders.members.plugins.configureDI
import io.ktor.server.testing.createTestEnvironment
import io.ktor.server.testing.withApplication
import kotlinx.coroutines.runBlocking
import org.junit.jupiter.api.DisplayName
import org.junit.jupiter.api.Nested
import org.junit.jupiter.api.Test
import kotlin.test.assertEquals

class UsersTests {
    @Nested
    @DisplayName("query Users")
    inner class UsersTests {
        @Test
        fun `returns a list of users`() = withApplication(environment = createTestEnvironment {
            module {
                configureDI()
            }
        }) {
            val app = this.application
            val schema = KGraphQL.schema {
                scalars()
                usersSchema(app)
            }

            val users = runBlocking(this.coroutineContext) {
                schema.execute(
                    """
                        query GetUsers {
                            users {
                                id
                                username
                            }
                        }
                    """.trimIndent()
                )
            }

            assertEquals("{\"users\":[]}", users)
        }
    }
}
