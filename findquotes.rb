#!/usr/bin/env ruby
if ARGV.length < 1 || ARGV.include?('--help') then
	puts "Usage: ruby #{$0} <source file>"
end

fail = false

ARGV.each do |item|
	if not File.exists? item then
		puts "Error. #{item} does not exist."
		exit 1
	elsif File.directory? item then
		puts "Error. #{item} is a directory."
		exit 2
	end
	ctnt_of_file = File.read(item).gsub("\r\n", "\n").split("\n")
	index_line = 0
	ctnt_of_file.each do |line|
		index_line += 1
		inside_quotes = false
		need_subst = true
		quotes_count = 0
		quotes_pairs = []
		index_char = -1
		type_of_quotes = ''
		line.split('').each do |charc|
			index_char += 1
			if (charc == '"' || charc == '\'') && need_subst then
				if inside_quotes && type_of_quotes != charc then
					next
				end
				inside_quotes = (not inside_quotes)
				quotes_count += 1
				if inside_quotes then
					type_of_quotes = charc
					quotes_pairs.push({ 'start' => index_char.clone,
							    'end' => -1 })
				else
					type_of_quotes = ''
					quotes_pairs[-1]['end'] = index_char.clone
				end
			elsif charc == "\\" then
				need_subst = false
				next
			end
			if need_subst == false then
				need_subst = true
			end
		end
		if (quotes_count % 2) != 0 then
			fail = true
			awaited = quotes_pairs.length * 2
			puts "Quotes mismatches were found on line #{index_line} in file \"#{item}\":"
			puts "   Awaited quotes count: #{awaited}"
			puts "   Found quotes: #{quotes_count}"
			puts "   Details:"
			quotes_pairs.each do |hash|
				outl = 'PAIR '
				if hash['end'] == -1 then
					outl = 'NOT A PAIR '
				end
				outl += " start index = #{hash['start']}, end index = "
				if hash['end'] == -1 then
					outl += 'NONE'
				else
					outl += "#{hash['end']}"
				end
				puts "     #{outl}"
			end
		end
	end
end

if fail then
	exit 1
end
exit 0
