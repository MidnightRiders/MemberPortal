import io.gitlab.arturbosch.detekt.Detekt
import org.jetbrains.kotlin.gradle.tasks.KotlinCompile

plugins {
    application
    jacoco
    java
    kotlin("jvm") version "1.5.31"

    id("io.gitlab.arturbosch.detekt") version "1.18.1"
    id("org.liquibase.gradle") version "2.0.4"
}

group = "com.midnightriders.members"
version = "0.0.1"
application {
    mainClass.set("com.midnightriders.members.ApplicationKt")
}

repositories {
    mavenCentral()
    maven { url = uri("https://jitpack.io") }
}

private object Versions {
    const val kotlin = "1.5.31"
    const val ktor = "1.6.4"
    const val logback = "1.2.6"

    const val exposed = "0.35.1"
    const val hikari = "5.0.0"
    const val kodein = "7.9.0"
    const val liquibase = "4.4.3"
    const val postgresql = "42.2.2"
    const val ulid = "2.0.0.0"
    const val yaml = "1.29"

    const val detekt = "1.18.1"
    const val junit = "5.7.0"
}

dependencies {
    implementation("ch.qos.logback:logback-classic:${Versions.logback}")
    implementation("com.github.guepardoapps:kulid:${Versions.ulid}")
    implementation("com.zaxxer:HikariCP:${Versions.hikari}")
    implementation("io.ktor:ktor-auth-jwt:${Versions.ktor}")
    implementation("io.ktor:ktor-auth:${Versions.ktor}")
    implementation("io.ktor:ktor-jackson:${Versions.ktor}")
    implementation("io.ktor:ktor-server-core:${Versions.ktor}")
    implementation("io.ktor:ktor-server-host-common:${Versions.ktor}")
    implementation("io.ktor:ktor-server-netty:${Versions.ktor}")
    implementation("org.jetbrains.exposed:exposed-core:${Versions.exposed}")
    implementation("org.jetbrains.exposed:exposed-dao:${Versions.exposed}")
    implementation("org.jetbrains.exposed:exposed-jdbc:${Versions.exposed}")
    implementation("org.jetbrains.exposed:exposed-java-time:${Versions.exposed}")
    implementation("org.kodein.di:kodein-di-jvm:${Versions.kodein}")
    implementation("org.postgresql:postgresql:${Versions.postgresql}")

    // Liquibase
    implementation("org.liquibase:liquibase-core:${Versions.liquibase}")
    implementation("org.yaml:snakeyaml:${Versions.yaml}")
    liquibaseRuntime("org.liquibase:liquibase-core:${Versions.liquibase}")
    liquibaseRuntime("org.postgresql:postgresql:${Versions.postgresql}")
    liquibaseRuntime("org.yaml:snakeyaml:${Versions.yaml}")

    // Linting
    implementation("io.gitlab.arturbosch.detekt:detekt-formatting:${Versions.detekt}")

    // Testing
    testImplementation("io.ktor:ktor-server-tests:${Versions.ktor}")
    testImplementation("org.jetbrains.kotlin:kotlin-test:${Versions.kotlin}")
    testImplementation("org.junit.jupiter:junit-jupiter:${Versions.junit}")
}

dependencyLocking {
    lockAllConfigurations()
}

java {
    targetCompatibility = JavaVersion.VERSION_11
    sourceCompatibility = JavaVersion.VERSION_11
}

liquibase {
    activities {
        create("main") {
            // This mostly duplicates com.midnightriders.members.config.DBConfig, but
            // I can't find a way to import that or reuse that across Gradle and here,
            // despite no extra dependencies or imports—it's a pure Kotlin class.
            @Suppress("MagicNumber")
            val defaultPort = 5432
            val dbUrl = System.getenv("DATABASE_URL") ?: "postgresql://username:password@localhost:5432/database"
            val jdbcUrlRegex = Regex(
                "^(?<protocol>postgresql://)?(?:(?<username>.+?):(?<password>.+?)@)?(?<host>.+?)"+
                    "(?::(?<port>[0-9]+))?/(?<dbname>.*?)(?:\\?(?<query>.+))?$",
            )
            val groups = jdbcUrlRegex.matchEntire(dbUrl)!!.groups
            val dbname = groups["dbname"]!!.value
            val host = groups["host"]!!.value
            val password = groups["password"]!!.value
            val port = groups["port"]?.value?.toInt() ?: defaultPort
            val protocol = groups["protocol"]?.value ?: "postgresql://"
            val query = groups["query"]?.value ?: ""
            val username = groups["username"]!!.value

            arguments = mapOf(
                "logLevel" to "debug",
                "changeLogFile" to "src/main/resources/db/main.yaml",
                "url" to "jdbc:$protocol$host:$port/$dbname?$query",
                "username" to username,
                "password" to password
            )
        }
    }
}

tasks.withType<KotlinCompile> {
    kotlinOptions {
        jvmTarget = "11"
        targetCompatibility = "11"
    }
}

detekt {
    toolVersion = Versions.detekt
    allRules = false
    autoCorrect = false
    buildUponDefaultConfig = false
    config = files("detekt.yaml")
    parallel = true
    reports {
        xml.enabled = false
        txt.enabled = false
        sarif.enabled = true
        html.enabled = true
    }
}

tasks.register<Detekt>("detektFormat") {
    description = "Formats entire project"
    allRules = false
    autoCorrect = true
    buildUponDefaultConfig = false
    config.setFrom(file("$rootDir/detekt.yaml"))
    parallel = true
    setSource(files("src/main/kotlin", "src/test/kotlin"))
    reports {
        xml.enabled = false
        txt.enabled = false
        sarif.enabled = true
        html.enabled = true
    }
}

tasks.withType<Test> {
    useJUnitPlatform()
    finalizedBy(tasks.jacocoTestReport)
}

tasks.jacocoTestReport {
    reports {
        xml.required.set(true)
        csv.required.set(false)
        html.required.set(false)
        xml.outputLocation.set(file("testReport.xml"))
    }
    dependsOn(tasks.test)
}

jacoco {
    toolVersion = "0.8.7"
}
