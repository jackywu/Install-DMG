#!/usr/bin/env ruby

require 'fileutils'
require 'pathname'
include FileUtils

#go to downloads directory
puts "installing most recent .dmg"
cd File.expand_path("~/Downloads/")
path = Pathname.new('.')

#find most recent .dmg file
files = path.entries.collect { |file| path+file }.sort { |file1,file2| file1.ctime <=> file2.ctime }
files.reject! { |file| ((file.file? and file.to_s.include?(".dmg")) ? false : true) }

files.each { |dmg_file|
  #if there is no .dmg file then reject this.
  if !dmg_file
    puts "No DMG files"
    exit
  end

  puts "Mounting #{dmg_file}"

  mount_point = Pathname.new "/Volumes/#{dmg_file}"

  result = `hdiutil attach -mountpoint #{mount_point}  #{dmg_file}`

  #find any apps in the mounted dmg
  files = mount_point.entries.collect { |file| mount_point+file }
  files.reject! { |file| ((file.to_s.include?(".app")) ? false : true) }

  files.each { |app|
    puts "Copying #{app} to Applications folder"
    `cp -a #{app} /Applications/`
  }

  #unmount the .dmg
  puts "Unmounting #{dmg_file}"
  result = `hdiutil detach #{mount_point}`
  puts "Finished installing #{dmg_file}"


  #delete the .dmg
  rm dmg_file
}
