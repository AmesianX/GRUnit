require 'minitest/spec'
require 'minitest/autorun'
require 'grunit'
require 'fileutils'
require 'zip'

def unzip_file(file, destination)
  Zip::File.open(file) do |zip_file|
    zip_file.each do |f|
      next if f.name =~ /__MACOSX/ or f.name =~ /\.DS_Store/ or !f.file?
      f_path = File.join(destination, f.name)
      FileUtils.mkdir_p(File.dirname(f_path))
      zip_file.extract(f, f_path) unless File.exist?(f_path)
   end
  end
end

def cleanup
  FileUtils.rm_rf(File.join(File.dirname(__FILE__), "tmp"))
end

def tmp_dir
  File.join(File.dirname(__FILE__), "tmp")
end

def root_dir
  File.join(File.dirname(__FILE__), "..", "..")
end

def generate_empty_project_files
  cleanup

  FileUtils.mkdir_p(tmp_dir)
  src_zip = File.join(root_dir, "Gem", "test", "Project-iOS.zip")
  dst_zip = File.join(tmp_dir, "Project-iOS.zip")
  FileUtils.cp(src_zip, dst_zip)

  unzip_file(dst_zip, tmp_dir)
  File.join(tmp_dir, "Example-iOS", "Example-iOS.xcodeproj")
end

describe GRUnit do

  it "can generate test project" do
    project_path = generate_empty_project_files
    target_name = "Example-iOS"
    test_target_name = "Tests"

    puts "\n\n"

    project = GRUnit::Project.open(project_path, target_name, test_target_name)
    project.create_test_target.wont_be_nil

    # Run again, should only update
    project = GRUnit::Project.open(project_path, target_name, test_target_name)
    project.create_test_target.wont_be_nil

    # Add another test
    project.create_test("SampleTest")
    #project.create_test("SampleKiwiSpec", :kiwi)
    project.save

    # Write a podfile pointing at ourselves
    podfile_content =<<-EOS
platform :ios, '7.0'

target :Tests do
  pod 'GRUnit', :path => "../../../../"
  pod 'Kiwi'
end
EOS
    File.open("Podfile", "w") { |f| f.write(podfile_content) }

    system("pod install")

    # Install run tests script
    project = GRUnit::Project.open(project_path, target_name, test_target_name)
    project.install_run_tests_script

    # Sync test target
    project.sync_test_target_membership    

    workspace = "#{tmp_dir}/Example-iOS/Example-iOS.xcworkspace"
    puts ""
    puts "\t#{workspace}".green
    puts ""
  end

end
