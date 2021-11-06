package com.midnightriders.members.graphql

import com.apurebase.kgraphql.schema.dsl.SchemaBuilder
import java.time.LocalDateTime
import java.time.ZoneOffset

private const val MS_IN_S = 1_000L

fun SchemaBuilder.scalars() {
    longScalar<LocalDateTime> {
        serialize = { date ->
            date.toEpochSecond(ZoneOffset.UTC) / MS_IN_S
        }
        deserialize = { seconds: Long ->
            LocalDateTime.ofEpochSecond(seconds / MS_IN_S, 0, ZoneOffset.UTC)
        }
        description = "Date in MS since UTC"
    }
}

