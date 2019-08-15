#!/usr/bin/env ruby

brackets = { '(' => ')', '[' => ']', '{' => '}' }

class String
	def find_from_back(charc)
		index = self.length
		out = -1
		self.split('').reverse.each do |item|
			index -= 1
			if item == charc then
				out = index
				break
			end
		end
		return index
	end
end

class Array
	def has_value?(key, value)
		self.each do |item|
			if Hash === item && item.keys.include?(key) then
				if Array === value && (Array === item[key]) == false then
					value.each do |vl|
						if item[key] == vl then
							return true
						end
					end
				else
					if item[key] == value then
						return true
					end
				end
			end
		end
		return false
	end
	
	def incr_every(key, value)
		out = []
		self.each do |item|
			if Hash === item && item.keys.include?(key) then
				ohash = item.clone
				ohash[key] += value
				out.push(ohash)
			else
				out.push(item)
			end
		end
		return out
	end
end

def brackets_detect(line, available_brackets)
	index = -1
	out = []
	line.split('').each do |item|
		index += 1
		if available_brackets.keys.include? item then
			end_index = line.find_from_back(available_brackets[item])
			out.push({ 'start' => index.clone, 'end' => end_index.clone })
			out = out + brackets_detect(line[index + 1...end_index], available_brackets).incr_every('start', index).incr_every('end', index)
		end
	end
	return out
end

if ARGV.length < 1 || ARGV.include?('--help') then
	puts "Usage: ruby #{$0} [source files]"
	exit 1
end

ARGV.each do |file|
	if not File.exists? file then
		puts "Error. #{file} - no such file or directory."
		exit 2
	elsif File.directory? file then
		puts "Error. #{file} is actually a directory."
		exit 3
	end
	linev = 0
	File.read(file).gsub("\r\n", "\n").split("\n").each do |line|
		linev += 1
		array_of_brackets = brackets_detect(line, brackets)
		puts "#{array_of_brackets}"
		if array_of_brackets.has_value?('end', [-1, 0]) then
			puts "Mismatching bracket pairs were found on line #{linev} in file \"#{file}\":"
			puts "   Pairs detected: #{array_of_brackets.length}"
			puts "   Details:"
			array_of_brackets.each do |brackets_hash|
				outl = 'PAIR'
				if [0, -1].include?(brackets_hash['end']) then
					outl = 'NOT A PAIR'
				end
				outl += " start index = #{brackets_hash['start']}, end index = #{brackets_hash['end']} "
				if [0, -1].include?(brackets_hash['end']) then
					outl += ' (NONE)'
				end
				puts "     #{outl}"
			end
		end
	end
end
