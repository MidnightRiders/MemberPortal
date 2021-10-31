import io.gitlab.arturbosch.detekt.Detekt

plugins {
    application
    java
    kotlin("jvm") version "1.5.31"

    id("io.gitlab.arturbosch.detekt") version "1.18.1"
}

group = "com.midnightriders.members"
version = "0.0.1"
application {
    mainClass.set("com.midnightriders.members.ApplicationKt")
}

repositories {
    mavenCentral()
}

private object Versions {
    const val ktor = "1.6.4"
    const val kotlin = "1.5.31"
    const val logback = "1.2.6"

    const val exposed = "0.35.1"
    const val hikari = "5.0.0"
    const val postgresql = "42.2.2"

    const val detekt = "1.18.1"
    const val junit = "5.7.0"
}

dependencies {
    implementation("io.ktor:ktor-server-core:${Versions.ktor}")
    implementation("io.ktor:ktor-jackson:${Versions.ktor}")
    implementation("io.ktor:ktor-auth:${Versions.ktor}")
    implementation("io.ktor:ktor-auth-jwt:${Versions.ktor}")
    implementation("io.ktor:ktor-server-host-common:${Versions.ktor}")
    implementation("io.ktor:ktor-server-netty:${Versions.ktor}")
    implementation("ch.qos.logback:logback-classic:${Versions.logback}")
    implementation("com.zaxxer:HikariCP:${Versions.hikari}")
    implementation("org.jetbrains.exposed:exposed-core:${Versions.exposed}")
    implementation("org.jetbrains.exposed:exposed-dao:${Versions.exposed}")
    implementation("org.jetbrains.exposed:exposed-jdbc:${Versions.exposed}")
    implementation("org.postgresql:postgresql:${Versions.postgresql}")
    implementation("io.gitlab.arturbosch.detekt:detekt-formatting:${Versions.detekt}")

    testImplementation("org.junit.jupiter:junit-jupiter:${Versions.junit}")
    testImplementation("io.ktor:ktor-server-tests:${Versions.ktor}")
    testImplementation("org.jetbrains.kotlin:kotlin-test:${Versions.kotlin}")
}

java {
    targetCompatibility = JavaVersion.VERSION_11
    sourceCompatibility = JavaVersion.VERSION_11
}

tasks.compileKotlin {
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
