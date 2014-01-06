
module.exports = function (grunt) {
  grunt.initConfig({
    pkg: grunt.file.readJSON('package.json'),
    browserify: {
      testing:{
        src: ['src/commonModule.js'],
        dest: 'build/bi_commonModule.js',
        options: {
          external: [],
          alias:[
          'src/commonModule.js:commonModule',
          ]
        }
      }
    },
    uglify: {
      options: {
        banner: '/*! <%= pkg.name %> <%= grunt.template.today("yyyy-mm-dd") %> */\n'
      },
      dist: {
        files: {
          'public/<%= pkg.name %>.min.js': ['public/main.js']
        }
      }
    },
    exec: {
      vulcan: {
        command: 'vulcanize -i build/index.html -o build/index.html',
        stdout: true,
        stderr: true
      }
    },
    nodewebkit: {
      options: {
          version:"0.8.2",// 0.6.3 works with polymer , does not work from 0.7.0 onwards
          build_dir: './releases/desktop', // Where the build version of my node-webkit app is saved
          mac: false, // We want to build it for mac
          win: false, // We want to build it for win
          linux32: false, // We don't need linux32
          linux64: true // We don't need linux64
      },
      src: ['./build/**'] // Your node-wekit app
    },
    copy: {
      testing: {
        files:[
        {src: 'src/index.html',dest: 'build/index.html'} ,
        {src: 'src/foo-element/foo-element.html',dest: 'build/foo-element/foo-element.html'} ,
        {src: 'package.json',dest: 'build/package.json'} ,
        {expand: true, src: ['components/**'], dest: 'build/'},
       ]
     },
    },
    watch: {
      scripts: {
        files: ['src/**/*.*'],
        tasks: [''],
        options: {
          livereload: {
            port: 9000,
          }
        },
      },
    },
    //hack for node webkit to replace polymer platoform's global with something else
    replace: {
      testing:{
        src: ['components/platform/platform.js'],
        dest: 'components/platform/platform_.js',  
        replacements: [{ 
              from: 'global',                   // string replacement
              to: 'fakeGlobal' 
            }] 
       }
    },
  
    clean:{
     testing:["build"]
    }

  });

  //generic
  grunt.loadNpmTasks('grunt-exec');
  grunt.loadNpmTasks('grunt-text-replace');
  grunt.loadNpmTasks('grunt-contrib-clean');

  //builds generation
  grunt.loadNpmTasks('grunt-contrib-watch');
  grunt.loadNpmTasks('grunt-contrib-copy');
  grunt.loadNpmTasks('grunt-browserify');
  grunt.loadNpmTasks('grunt-node-webkit-builder');

  //release cycle
  grunt.loadNpmTasks('grunt-contrib-uglify');

  // Task(s).
  grunt.registerTask('test', ['jshint', 'jasmine_node']);
  grunt.registerTask('build', ['jshint', 'jasmine_node','concat','uglify']);
  grunt.registerTask('release', ['concat','uglify','jasmine_node','release']);
  //grunt.registerTask('default', ['browserify','uglify']);

  //test for polymer vulcanizer (ie full release)
  grunt.registerTask('vulcan', ['exec']);


  grunt.registerTask('bla', ['nodewebkit']);


  //should be a sub task/target
  grunt.registerTask('desktopBuild', ['clean','browserify:testing','copy:testing','replace:testing','exec','nodewebkit']);

  grunt.event.on('watch', function(action, filepath, target) {
    grunt.log.writeln(target + ': ' + filepath + ' has ' + action);
  });

};
//,'nodewebkit'

//see https://github.com/jmreidy/grunt-browserify/blob/master/examples/mappings/Gruntfile.js

