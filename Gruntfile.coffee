module.exports = (grunt) ->
  
  #different builds:
  # browser
  # -->standalone (index.html)
  # -->integration (custom element + deps only)
  # desktop
  # -->linux
  # -->win
  # -->mac

  grunt.initConfig
    pkg: grunt.file.readJSON("package.json")
    currentBuild: null
    uglify:
      main:
        options:
          banner: "/*! <%= pkg.name %> <%= grunt.template.today(\"yyyy-mm-dd\") %> */\n"
        dist:
          files:
            "public/<%= pkg.name %>.min.js": ["public/main.js"]

      integration:
        options: {}
        files:
          "build/<%= currentBuild %>/polymer-nw-example.min.js": ["build/<%= currentBuild %>/polymer-nw-example.js"]
          "build/<%= currentBuild %>/platform.min.js": ["build/<%= currentBuild %>/platform.js"]

      standalone:
        files:
          "build/<%= currentBuild %>/index.min.js": ["build/<%= currentBuild %>/index.js"]
          "build/<%= currentBuild %>/platform.min.js": ["build/<%= currentBuild %>/platform.js"]

    exec:
      standalone:
        command: "vulcanize index.html -o build/<%= currentBuild %>/index.html"
        stdout: true
        stderr: true

      integration:
        command: "vulcanize --csp -i smoke.html -o build/<%= currentBuild %>/polymer-nw-example.html"
        stdout: true
        stderr: true

    nodewebkit:
      options:
        version: "v0.7.5" #0.8.2 0.6.3 works with polymer but unresolved does not get removed, does not work from 0.7.0 onwards, 0.8.2 works only partially (wrong order of events)
        build_dir: "_tmp/desktop" # Where the build version of my node-webkit app is saved
        mac: false # We want to build it for mac
        win: false # We want to build it for win
        linux32: false # We don't need linux32
        linux64: true # We don't need linux64
        keep_nw: true
      src: ["build/<%= currentBuild %>/**"] # Your node-wekit app

    replace:
      integration:
        src: ["build/<%= currentBuild %>/polymer-nw-example.html"]
        dest: "build/<%= currentBuild %>/polymer-nw-example.html"
        replacements: [
          from: "../components/platform"
          to: ""
        ,
          from: "../components/"
          to: ""
        ,
          from: "polymer-nw-example.js"
          to: "polymer-nw-example.min.js"
        ]

      desktopPost:
        src: ["build/<%= currentBuild %>/index.html"]
        overwrite:true
        replacements: [
          from: "../../components/"
          to: ""
        ,
          from: "../components/"
          to: ""
        ,
          from: '<script src="polymer/polymer.js"></script>'
          to: '<script src="polymer.js"></script>'
        ,
          from: '<script src="platform/platform.js"></script>'
          to: '<script src="platform.js"></script>'
        ]
      standalone:
        src: ["build/<%= currentBuild %>/platform.js"]
        dest: "build/<%= currentBuild %>/platform.js"
        replacements: [
          from: "global" # string replacement
          to: "fakeGlobal"
        ]
        

    copy:
      integration:
        files: [
          #{src: 'components/platform/platform.js.map',dest: 'build/<%= currentBuild %>/platform.js.map'} ,
          src: "components/platform/platform.js"
          dest: "build/<%= currentBuild %>/platform.js"
        ]
      standalone:
        files: [
          {src: 'components/platform/platform.js.map',dest: 'build/<%= currentBuild %>/platform.js.map'},{src: 'components/platform/platform.js', dest: 'build/<%= currentBuild %>/platform.js'},{src: "components/polymer/polymer.js", dest: "build/<%= currentBuild %>/polymer.js"}
        ]
      desktop:
        files: [
          src: "package.json"
          dest: "build/<%= currentBuild %>/package.json"
          {src: ['demo-data/**'], dest: 'build/<%= currentBuild %>/'}
          #{expand: true, src: ['components/**'], dest: 'build/<%= currentBuild %>'}
        ]
      desktopFinal:
        files: [
          {expand: true, src: ['_tmp/desktop/releases/polymer-nw-example/linux64/polymer-nw-example/**'], dest: 'build/<%= currentBuild %>/'},
        ]

    rename:
      desktopFinal:
        src: '_tmp/desktop/releases/polymer-nodewebkit-example/linux64'
        dest: 'build/<%= currentBuild %>/'

    htmlmin:
      integration:
        options: {}
        files: # Dictionary of files
          "build/integration/polymer-nw-example.html": "build/integration/polymer-nw-example.html"

    clean:
      integration: ["build/<%= currentBuild %>"]
      postIntegration: ["build/<%= currentBuild %>/platform.js", "build/<%= currentBuild %>/polymer-nw-example.js"]
      standalone: ["build/<%= currentBuild %>"]
      postStandalone: ["build/<%= currentBuild %>/platform.js", "build/<%= currentBuild %>/index.js"]

      desktop:["build/<%= currentBuild %>"]
  
  #generic
  grunt.loadNpmTasks "grunt-contrib-watch"
  grunt.loadNpmTasks "grunt-contrib-copy"
  grunt.loadNpmTasks "grunt-rename"
  grunt.loadNpmTasks "grunt-exec"
  grunt.loadNpmTasks "grunt-text-replace"
  grunt.loadNpmTasks "grunt-contrib-clean"
  
  #builds generation
  grunt.loadNpmTasks "grunt-browserify"
  grunt.loadNpmTasks "grunt-node-webkit-builder"
  grunt.loadNpmTasks "grunt-contrib-uglify"
  grunt.loadNpmTasks "grunt-contrib-htmlmin"
  
  #release cycle

  
  # Task(s).
  #grunt.registerTask "test", ["jshint", "jasmine_node"]
  #grunt.registerTask "release", ["concat", "uglify", "jasmine_node", "release"]
  grunt.registerTask "core", ["browserify", "uglify:main"]
  
  #Builds
  @registerTask 'build', 'Build polymer-nw-example for the chosen target/platform etc', (target = 'browser', subTarget='standalone') =>
    minify = grunt.option('minify');
    platform = grunt.option('platform');
    console.log("target", target, "sub", subTarget,"minify",minify,"platform",platform)
    grunt.config.set("currentBuild", "#{target}-#{subTarget}")
    
    @task.run "clean:#{subTarget}"
    @task.run "copy:#{subTarget}"
    @task.run "exec:#{subTarget}"
    @task.run "replace:#{subTarget}"

    if minify
      @task.run "uglify:#{subTarget}"
      #issues with ,'htmlmin:integration'
      postClean = subTarget[0].toUpperCase() + subTarget[1..-1].toLowerCase()
      @task.run "clean:post#{postClean}"

    if target is 'desktop'
      @task.run "replace:desktopPost"
      @task.run "copy:desktop"
      @task.run "nodewebkit"
      #@task.run "rename:desktopFinal"
      

