allprojects {
    buildDir = rootProject.file("../build/${project.name}") 

    repositories {
        google()
        mavenCentral()
    }
}


tasks.register<Delete>("clean") {
    delete(rootProject.file("../build")) 
}