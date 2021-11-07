import io.gitlab.arturbosch.detekt.Detekt
import com.github.jengelman.gradle.plugins.shadow.tasks.ShadowJar
import org.jetbrains.kotlin.gradle.tasks.KotlinCompile

plugins {
    application
    jacoco
    java
    kotlin("jvm") version "1.5.31"

    id("io.gitlab.arturbosch.detekt") version "1.18.1"
    id("com.github.johnrengelman.shadow") version "7.0.0"
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
    const val jbcrypt = "0.4"
    const val kgraphql = "0.17.14"
    const val kodein = "7.9.0"
    const val liquibase = "4.4.3"
    const val postgresql = "42.2.2"
    const val ulid = "2.0.0.0"
    const val yaml = "1.29"

    const val detekt = "1.18.1"
    const val junit = "5.7.0"
}

dependencies {
    implementation("com.apurebase:kgraphql:${Versions.kgraphql}")
    implementation("com.apurebase:kgraphql-ktor:${Versions.kgraphql}")
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
    implementation("org.kodein.di:kodein-di-framework-ktor-server-jvm:${Versions.kodein}")
    implementation("org.kodein.di:kodein-di-jvm:${Versions.kodein}")
    implementation("org.mindrot:jbcrypt:${Versions.jbcrypt}")
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
            arguments = mapOf(
                "logLevel" to "debug",
                "changeLogFile" to "src/main/resources/db/main.yaml",
                "url" to System.getenv("JDBC_DATABASE_URL"),
                "username" to System.getenv("JDBC_DATABASE_USERNAME"),
                "password" to System.getenv("JDBC_DATABASE_PASSWORD"),
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

tasks.withType<ShadowJar> {
    manifest {
        attributes("Main-Class" to "com.midnightriders.members.ApplicationKt")
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
