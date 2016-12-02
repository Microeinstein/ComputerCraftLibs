--hGet by Microeinstein (from wgetAPI)

function download(url, file)
	print("Getting ", file, "...")
	http.request(url)
	local event, eUrl, content = nil, nil, nil
	repeat
		event, eUrl, content = os.pullEvent()
		if event == "http_success" then
			body = content.readAll()
			file = fs.open(file, "w")
			file.write(body)
			file.flush()
			file.close()
			print("Done.")
			return true
		elseif event == "http_failure" then
			print("Unable to get.")
			return false
		end
	until event == "http_success" or event == "http_failure"
end

function CLI()
	loadfile("std")()
	term.wash()
	local url  = term.input("URL:  ", "http://")
	local file = term.input("File: ")
	download(url, file)
end