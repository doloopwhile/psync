require 'rake'
require 'rake/clean'
require 'json'

task :default => %w{
  admin:build
  audience:build
  pages:build
}

namespace :admin do
  task :build => %w{
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
    sh "slimrb #{t.prerequisites[0]} >| #{t}"
  end

  directory "view/admin"
end

namespace :audience do
  task :build => %w{
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

namespace :pages do
  task build: %w{
    files/slide.pdf
    files/bg.jpg
  } + [:pages]

  task :pages => 'files' do
    sh 'rm -rf files/p-*.jpg'
    sh 'convert slide.pdf files/p.jpg'

    n = Dir['files/p-*.jpg'].length
    j = {
      page_urls: n.times.map{|i| "/files/p-#{i}.jpg" }
    }
    File.write("files/index.json", j.to_json)
  end

  task 'files/slide.pdf' => %w{files} do
    sh 'rm -rf files/slide.pdf'
    sh 'cp slide.pdf files/slide.pdf'
  end

  task 'files/bg.jpg' => %w{files} do
    sh 'rm -rf files/bg.jpg'
    sh 'cp bg.jpg files/bg.jpg'
  end

  directory 'files'
end
