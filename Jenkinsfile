pipeline {
  agent any

  stages {
    stage('Lint') {
        steps {
            echo 'Building..'
        }
    }
  }


}


def server = Artifactory.server 'FIDATA'
def rtGradle = Artifactory.newGradleBuild()
rtGradle.usesPlugin = true
rtGradle.useWrapper = true
/*def buildInfo =*/ rtGradle.run rootDir: "projectDir/", buildFile: 'build.gradle', tasks: 'check'
