#!/usr/bin/env ruby
require 'pp'
require 'uri'
require 'optparse'

# list files from a given directory having the list of
# specific extensions
def list_files(options = {})
  options = {
    directory: ".",
    include_keywords: [],
    exclude_keywords: []
  }.merge(options)

  file_patterns(options).select do |f|

    # common condition
    return_condition = !File.directory?(f) && File.size?(f)

    # only include the value that match the keyword
    if !options[:include_keywords].empty?
      return_condition &&= in_keywords?(File.basename(f), options[:include_keywords], options)
    end

    #-- apply the keyword to exclude if any
    if !options[:exclude_keywords].empty?
      return_condition &&= !in_keywords?(File.basename(f), options[:exclude_keywords], options)
    end

    return_condition
  end
end

#-- create list of directory and extensions for use in Dir[]
def file_patterns(options = {})
  options = {
    directory: ".",
    all_extensions: false,
    all_extensions_except: [],
    extensions: ["pdf","epub"]
  }.merge(options)

  result = []

  if options[:all_extensions]
    #-- all file extensions
    result << "#{options[:directory]}/**/*.*"
    return Dir.glob(result,0)
  end

  if options[:all_extensions_except] && !options[:all_extensions_except].empty?
    #-- all file extensions
    result << "#{options[:directory]}/**/*.*"

    # now the list we want to exclude
    exc_result = []
    options[:all_extensions_except].each do |e|
      exc_result << "#{options[:directory]}/**/*.#{e}"
    end

    #-- subtract the two list
    return Dir.glob(result,0) - Dir.glob(exc_result,0)
  end

  #-- default to specific extensions
  options[:extensions].each do |e|
    result << "#{options[:directory]}/**/*.#{e}"
  end

  return Dir.glob(result,0)
end

def html_header
puts <<-eos
  <html>
  <title>File Listing</title>
    <body>
    <ul>
  eos
end

def html_footer
puts <<-eos
    </ul>
  </body>
  </html>
  eos
end

def html_body(file_list, options)

  file_list.each do |f|

    full_path = File.expand_path(f)
    short_path = File.basename(full_path)

    full_path_encoded = URI.escape(full_path, Regexp.new("[^#{URI::PATTERN::UNRESERVED}]"))
    result = make_link(full_path_encoded, full_path, short_path, options)

    # ready to print result
    puts " #{result}"
  end
end

def make_link(full_path_encoded, full_path, short_path, options = {})
  options = {
    full_path: false
  }.merge(options)

  #--TODO: allow the user to see full path using javascript if (short description is enabled)
  if options[:full_path]
     result = %Q{<li><a href="file:///#{full_path_encoded}" target="_blank">#{full_path}</li>}
   else
     result = %Q{<li><a href="file:///#{full_path_encoded}" target="_blank">#{short_path}</li>}
   end
end

# We keep options as hash, so that we can pass more option to it
# maybe allow the 'word boundary'
def in_keywords?(input_text, keywords, options = {})

  options = {
    case_sensitive: false,
    whole_word: false
  }.merge(options)

  keywords.each do |word|

    if (options[:case_sensitive])
      #--TODO: can we make this code more DRY?
      if (options[:whole_word])
        matched = (input_text =~ /\b#{word}\b/)
      else
        matched = (input_text =~ /#{word}/)
      end
    else
      if (options[:whole_word])
        matched = (input_text =~ /\b#{word}\b/i)
      else
        matched = (input_text =~ /#{word}/i)
      end
    end
    # Add more options here if you like

    # return as quickly as we find the match
    return true if matched
  end

  # if we get here, then no match found
  return false
end

#-- print out the options
def print_result(options)

  #-- check if we get empty result
  result_list = list_files(options)

  if result_list && !result_list.empty?
    html_header
    html_body(result_list, options)
    html_footer
  else
    puts "FYI: No match found for your options #{options}"
  end

end

def parse_options()

  options = {}

  optparse = OptionParser.new do |opts|

    #-- mandatory argument
    options[:directory] = "."
    opts.on('-d', '--directory [/path/to/directory]', "optional start directory (default to '.')") do |dir|
      options[:directory] = dir
    end

    #-- list of extensions we want to list
    options[:extensions] = %w(pdf epub)
    opts.on('-t', '--extensions pdf,epub,etc', Array, "List of file extension to be included in the result (default to pdf,epub)" ) do |ext|
      options[:extensions] = ext
    end

    #-- list all of file types (most detail)
    options[:all_extensions] = false
    opts.on('-a', '--all_extensions', "List of all file extension" ) do
      options[:all_extensions] = true
    end

    #-- list all file types except one in this list
    options[:all_extensions_except] = []
    opts.on('-x', '--all_extension_except class,bin', Array, "List of all file except these extensions" ) do |ext|
      options[:all_extensions_except] = ext
    end

    #-- show full description for the link by default
    options[:full_path] = false
    opts.on('-f', '--full_path', "Display link using full path to the file") do
      options[:full_path] = true
    end

    #-- add options to allow user to filter out by list of keywords
    options[:include_keywords] = []
    opts.on('-i', '--include_keywords java,abap,etc', Array, "List of any keywords to be included in the result" ) do |word|
      options[:include_keywords] = word
    end

    #-- add options to allow user to filter out by list of keywords
    options[:exclude_keywords] = []
    opts.on('-e', '--exclude_keywords ', Array, "List of keywords to be excluded in the search result" ) do |word|
      options[:exclude_keywords] = word
    end

    #-- show full description for the link by default
    options[:case_sensitive] = false
    opts.on('-c', '--case_sensitive', "Use case sensitive in the search (default to false)") do
      options[:case_sensitive] = true
    end

    #-- show full description for the link by default
    options[:whole_word] = false
    opts.on('-w', '--whole_word', "Match whole world in search e.g. Java vs Javascript (default to false)" ) do
      options[:whole_word] = true
    end

    #-- TODO: add default option to save the result to file

    # This displays the help screen, all programs are
    # assumed to have this option.
    opts.on( '-h', '--help', 'Display this screen' ) do
      puts opts
      puts "Usage example:"
      puts <<-eos
      htmlify.rb [-d | --directory] ~/Downloads/examples
                 [-a | --all_extensions]
                 [-x | --all_extensions_except] bak,tmp
                 [-t | --extensions] pdf,epub,mobi,etc (will be ignored if use with all_extensions)
                 [-f | --full_path]
                 [-i | --include_keywords] official,guide,etc
                 [-e | --exclude_keywords] draft
                 [-c | --case_sensitive]
                 [-b | --whole_word]
      e.g.
      $htmlify.rb -d . -t java -e R\.java > index.html
      e.g. list all *.java files in current directory excluded the file that have the name 'R.java'

      $htmlify.rb -d ~/Downloads/incoming -i java,android -w -t pdf,epub > index.html
      e.g. list all *.pdf,*.epub files with the word 'java' (will not match 'javascript')

      eos
      exit
    end

  end

  optparse.parse!

  options
end

options = parse_options()
#puts "Your options: #{options}"
print_result options
