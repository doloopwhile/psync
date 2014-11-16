module.exports = (grunt) =>
  grunt.initConfig
    coffee:
      dist:
        files:
          'view/audience.js': 'view-src/audience.coffee'
          'view/admin.js': 'view-src/admin.coffee'
    less:
      dist:
        files:
          'view/audience.css': 'view-src/audience.less'
          'view/admin.css': 'view-src/admin.less'
    slim:
      dist:
        files:
          'view/audience.html': 'view-src/audience.slim'
          'view/admin.html': 'view-src/admin.slim'
    elm:
      dist:
        files:
          'view/elm-audience/': 'elm-audience/index.elm'
        options:
          bundleRuntime: true
    watch:
      options:
        atBegin: true
        livereload: true
      coffee:
        files: 'view-src/*.coffee'
        tasks: 'coffee'
      slim:
        files: 'view-src/*.slim'
        tasks: 'slim'
      less:
        files: 'view-src/*.less'
        tasks: 'less'
      elm:
        files: 'view-src/*.elm'
        tasks: 'elm'

  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.loadNpmTasks 'grunt-contrib-less'
  grunt.loadNpmTasks 'grunt-contrib-watch'
  grunt.loadNpmTasks 'grunt-slim'
  grunt.loadNpmTasks 'grunt-notify'
  grunt.loadNpmTasks 'grunt-elm'

  grunt.registerTask('default', ['slim', 'less', 'coffee'])
