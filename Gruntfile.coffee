module.exports = (grunt) =>
  grunt.initConfig
    coffee:
      dist:
        files:
          'view/audience.js': 'view-src/audience.coffee'
    less:
      dist:
        files:
          'view/audience.css': 'view-src/audience.less'
    slim:
      dist:
        files:
          'view/audience.html': 'view-src/audience.slim'
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

  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.loadNpmTasks 'grunt-contrib-less'
  grunt.loadNpmTasks 'grunt-contrib-watch'
  grunt.loadNpmTasks 'grunt-slim'
  grunt.loadNpmTasks 'grunt-notify'

  grunt.registerTask('default', ['slim', 'less', 'coffee'])
