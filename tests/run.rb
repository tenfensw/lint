tests_dir = File.dirname(File.absolute_path(__FILE__))
sources_dir = File.dirname(tests_dir)
puts "tests_dir = #{tests_dir}"
puts "sources_dir = #{sources_dir}"

rc = tests_dir + '/.testsrc' 
puts "#{rc}"
if not File.exists? rc then
	puts "Error. Test config #{rc} not found."
	exit 1
end

puts ""
exitcode = 0
ctnt_raw = File.read(rc).gsub("\r\n", "\n")
ctnt_raw.split("\n").each do |item|
	if not item.include? ' => ' then
		next
	end
	awaited_value = false
	split_item = item.split(' ')
	if split_item[0] == 'NORMAL' then
		awaited_value = true
	end
	unit_test = split_item.shift
	if awaited_value then
		unit_test = split_item.shift
	end
	split_item.shift
	filename = sources_dir + '/' + split_item.join(' ')
	unit_test = tests_dir + '/' + unit_test
	puts "Testing \"#{unit_test}\" on \"#{filename}\" (should return #{awaited_value})"
	if system('ruby "' + filename + '" "' + unit_test + '"') == awaited_value then
		puts "Test passed, moving on"
	else
		puts "Test failed"
		exitcode += 1
	end
end

puts ""
puts "-------------------------------------"
puts "#{exitcode} tests failed"
exit exitcode
