module.exports = (grunt) =>
  grunt.initConfig
    coffee:
      dist:
        files:
          'server/view/js/main.js': 'server/view-src/coffee/main.coffee'
    less:
      dist:
        files:
          'server/view/css/main.css': 'server/view-src/less/main.less'
    slim:
      dist:
        files:
          'server/view/index.html': 'server/view-src/slim/index.slim'
    watch:
      options:
        atBegin: true
        livereload: true
      coffee:
        files: 'server/view-src/coffee/*.coffee'
        tasks: 'coffee'
      slim:
        files: 'server/view-src/slim/*.slim'
        tasks: 'slim'
      less:
        files: 'server/view-src/less/*.less'
        tasks: 'less'

  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.loadNpmTasks 'grunt-contrib-less'
  grunt.loadNpmTasks 'grunt-contrib-watch'
  grunt.loadNpmTasks 'grunt-slim'
  grunt.loadNpmTasks 'grunt-notify'

  grunt.registerTask('default', ['slim', 'less', 'coffee'])
