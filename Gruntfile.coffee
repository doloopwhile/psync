module.exports = (grunt) =>
  grunt.initConfig
    coffee:
      dist:
        files:
          'view/js/main.js': 'view-src/coffee/main.coffee'
    less:
      dist:
        files:
          'view/css/main.css': 'view-src/less/main.less'
    slim:
      dist:
        files:
          'view/index.html': 'view-src/slim/index.slim'
    watch:
      options:
        atBegin: true
        livereload: true
      coffee:
        files: 'view-src/coffee/*.coffee'
        tasks: 'coffee'
      slim:
        files: 'view-src/slim/*.slim'
        tasks: 'slim'
      less:
        files: 'view-src/less/*.less'
        tasks: 'less'

  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.loadNpmTasks 'grunt-contrib-less'
  grunt.loadNpmTasks 'grunt-contrib-watch'
  grunt.loadNpmTasks 'grunt-slim'
  grunt.loadNpmTasks 'grunt-notify'
  grunt.loadNpmTasks 'grunt-elm'

  grunt.registerTask('default', ['slim', 'less', 'coffee'])
