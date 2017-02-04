## keyword_arguments

Add a handful of convenient methods to Module, which make working with argument hashes in Ruby a bit easier.

## Usage 
```ruby
require 'keyword_arguments'

class ReadFile
  required_arguments :dir, :filename
  def initialize(opts = {})
    @dir = opts[:dir]
    @filename = opts[:filename]
    Dir.chdir(@dir) unless @dir.nil?
  end
  default_arguments {{mode: 'r'}}
  def open_file(opts = {})
    file = File.open(@filename, opts[:mode] ).readlines
    puts file.join(" ")
  end
  allowed_arguments :text
  def write_in_file(opts = {})
    file = File.open(@filename) do |file|
      file.write(opts[:text])
      file.close
    end
  end
end
file = ReadFile.new(DIR, FILENAME)
file.open_file(mode: 'r+')
file.write_in_file(text: 'Hello World')
```

