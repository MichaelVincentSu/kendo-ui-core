require 'yaml'
require 'erb'

DEMOS_CSHTML = FileList['demos/mvc/Views/*/**/*.cshtml']
DEMOS_CS = FileList['demos/mvc/**/*.cs']

SUITE_INDEX_TEMPLATE = ERB.new(File.read('build/templates/suite-index.html.erb'))
BUNDLE_INDEX_TEMPLATE = ERB.new(File.read('build/templates/bundle-index.html.erb'))

def include_item?(item)
    packages = item['packages']

    return true unless packages

    invert = false
    match = false

    packages.each do |package|

        if package.start_with?('!')
            invert = true
            package = package[1..-1]
        end

        match = true if package == 'offline'
    end

    (!invert && match) || (invert && !match)
end

def find_demo_src (filename, path)

    filename = filename.sub(path, 'demos/mvc/Views').pathmap('%X.cshtml')

    DEMOS_CSHTML.find { |file| file == filename }

end

def find_navigation_item(navigation, filename)
    url = filename.pathmap('%-1d/%f')

    navigation.each do |name, categories|
        categories.each do |category|
            category['items'].each do |item|
                return item if item["url"] == url
            end
        end
    end
end

def offline_navigation(suite)

    navigation = YAML.load(File.read("demos/mvc/App_Data/#{suite}.nav.json"))

    offline = {}

    navigation.each do |name, categories|
        offline[name] = []
        categories.each do |category|
            if include_item?(category)
                category['items'] = category['items'].find_all { |item| include_item?(item) }

                offline[name].push(category)
            end
        end
    end

    offline
end

def offline_demos(navigation, path)

    demos = []

    navigation.each do |name, categories|
        categories.each do |category|
            category['items'].each do |item|
                demos.push("#{path}/#{item['url']}")
            end
        end
    end

    FileList[demos]
end

def demos(options)

    path = options[:path] + "/examples"

    mkdir_p path, :verbose => false

    suites = options[:suites]

    files = FileList["#{path}/index.html"].include("#{path}/content")

    tree :to => "#{path}/content",
         :from => FileList['demos/mvc/content/**/*'].exclude('**/docs/*'),
         :root => 'demos/mvc/content/'

    # Build the index.html page of the demos
    file "#{path}/index.html" => [path, 'build/templates/bundle-index.html.erb'] do |t|

        File.open(t.name, 'w') do |file|
            file.write BUNDLE_INDEX_TEMPLATE.result(binding) # 'binding' is the current scope
        end

    end

    suites.each do |suite|

        suite_path  = "#{path}/#{suite}"

        navigation = offline_navigation(suite)

        files = files + offline_demos(navigation, suite_path).include("#{suite_path}/index.html");

        # Build the index.html page of the suite
        file "#{suite_path}/index.html" => 'build/templates/suite-index.html.erb' do |t|

            File.open(t.name, 'w') do |file|
                file.write SUITE_INDEX_TEMPLATE.result(binding) # 'binding' is the current scope
            end

        end

        template = ERB.new(File.read("build/templates/#{suite}-example.html.erb"))

        # Create offline demos by processing the corresponding .cshtml files
        rule /#{path}\/#{suite}\/.+\.html/ => lambda { |t| find_demo_src(t, path) } do |t|
            body = File.read(find_demo_src(t.name, path))
            body.gsub!(/@section \w+ {(.|\n|\r)+?}/, '')
            body.gsub!(/@{(.|\n|\r)+?}/, '')
            body.gsub!(/@@/, '');

            ensure_path(t.name)

            item = find_navigation_item(navigation, t.name)

            File.open(t.name, 'w') do |file|
                title = item['text'] # used by the template and passed via 'binding'

                file.write template.result(binding) # 'binding' is the current scope
            end
        end
    end

    files
end

CLEAN.include('dist/demos')

file 'demos/mvc/bin/Kendo.dll' => DEMOS_CS do |t|
    msbuild 'demos/mvc/Kendo.csproj'
end

THEME_BUILDER_ROOT = 'http://themebuilder.kendoui.com'

PRODUCTION_RESOURCES = FileList['demos/mvc/**/*']
            .exclude('**/*.cs')
            .exclude('**/obj/**/*')

MVC_RAZOR_VIEWS = FileList['wrappers/mvc/demos/Kendo.Mvc.Examples/Areas/**/*.cshtml']
                    .exclude('**/Shared/**/*')
                    .exclude('**/_ViewStart.cshtml')
MVC_ASPX_VIEWS = FileList['wrappers/mvc/demos/Kendo.Mvc.Examples/Areas/**/*.as*x']

tree :to => 'dist/demos/production',
     :from => PRODUCTION_RESOURCES,
     :root => 'demos/mvc/'

tree :to => 'dist/demos/production/sources/aspx',
     :from => MVC_ASPX_VIEWS,
     :root => /wrappers\/mvc\/demos\/Kendo\.Mvc\.Examples\/Areas\/.+?\/Views\//

tree :to => 'dist/demos/production/sources/razor',
     :from => MVC_RAZOR_VIEWS,
     :root => /wrappers\/mvc\/demos\/Kendo\.Mvc\.Examples\/Areas\/.+?\/Views\//

tree :to => 'dist/demos/staging',
     :from => PRODUCTION_RESOURCES,
     :root => 'demos/mvc/'

tree :to => 'dist/demos/staging/sources/aspx',
     :from => MVC_ASPX_VIEWS,
     :root => /wrappers\/mvc\/demos\/Kendo\.Mvc\.Examples\/Areas\/.+?\/Views\//

tree :to => 'dist/demos/staging/sources/razor',
     :from => MVC_RAZOR_VIEWS,
     :root => /wrappers\/mvc\/demos\/Kendo\.Mvc\.Examples\/Areas\/.+?\/Views\//

tree :to => 'dist/demos/staging/content/cdn/js',
     :from => COMPLETE_MIN_JS,
     :root => 'src/'

tree :to => 'dist/demos/staging/content/cdn/styles',
     :from => MIN_CSS_RESOURCES,
     :root => /styles\/.+?\//

tree :to => 'dist/demos/staging/content/cdn/themebuilder',
     :from => FileList[THEME_BUILDER_RESOURCES]
                .include('themebuilder/bootstrap.js')
                .sub('themebuilder', 'dist/themebuilder/staging'),
     :root => 'dist/themebuilder/staging/'

def patch_web_config(name, cdn_root, themebuilder_root)

    config = File.read(name)

    config.sub!('$CDN_ROOT', cdn_root)
    config.sub!('$THEMEBUILDER_ROOT', themebuilder_root)

    File.open(name, 'w') do |file|
        file.write(config)
    end

end

namespace :demos do

    desc('Build debug demo site')
    task :debug => 'demos/mvc/Kendo.csproj' do |t|
        msbuild t.prerequisites[0], '/p:Configuration=Debug'
    end

    task :clean do
        rm_rf 'dist/demos'
    end

    task :release => 'demos/mvc/bin/Kendo.dll'

    task :staging_site => [:js,
        :less,
        :release,
        'themebuilder:staging',
        'dist/demos/staging',
        'dist/demos/staging/sources/aspx',
        'dist/demos/staging/sources/razor',
        'dist/demos/staging/content/cdn/js',
        'dist/demos/staging/content/cdn/themebuilder',
        'dist/demos/staging/content/cdn/styles'] do
        patch_web_config('dist/demos/staging/Web.config', '~/content/cdn', '~/content/cdn/themebuilder')
    end

    zip 'dist/demos/staging.zip' => :staging_site

    desc('Build staging demo site')
    task :staging => 'dist/demos/staging.zip'

    task :production_site => [:release,
        'dist/demos/production',
        'dist/demos/production/sources/aspx',
        'dist/demos/production/sources/razor'] do
        patch_web_config('dist/demos/production/Web.config', CDN_ROOT + VERSION, THEME_BUILDER_ROOT)
    end

    zip 'dist/demos/online-examples.zip' => :production_site

    desc('Build online demo site')
    task :production => 'dist/demos/online-examples.zip'
end

