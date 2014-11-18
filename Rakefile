require 'rake'
require 'rake/clean'

task default: %w{
  admin:build
  audience:build
}

namespace :admin do
  task build: %w{
    view/admin/index.html
    view/admin/index.css
    view/admin/index.js
  }

  file 'view/admin/index.js' => %w{view-src/jq-admin/index.coffee view/admin} do |t|
    sh "coffee -c -o view/admin #{t.prerequisites[0]}"
  end

  file 'view/admin/index.css' => %w{view-src/jq-admin/index.less view/admin} do |t|
    sh "lessc #{t.prerequisites[0]} >| #{t}"
  end

  file 'view/admin/index.html' => %w{view-src/jq-admin/index.slim view/admin} do |t|
    sh "slimrb -c #{t.prerequisites[0]} >| #{t}"
  end

  directory "view/admin"
end

namespace :audience do
  task build: %w{
    view/audience/index.html
    view/audience/index.js
  }

  file 'view/audience/index.html' => %w{view-src/elm-audience/index.html view/audience} do |t|
    sh "cp #{t.prerequisites[0]} #{t}"
  end

  file 'view/audience/index.js' => %w{view-src/elm-audience/index.elm view/audience} do |t|
    Dir.chdir "view-src/elm-audience/"
    sh "elm --build-dir=../../view/audience --only-js --bundle-runtime #{File.basename t.prerequisites[0]}"
  end

  directory "view/audience"
end
