#!/usr/local/bin/julia --startup=no

import JSON

OUTPATH="../../openproduct-web/public/docs"
SRCPATH="../../openproduct-docs"

documentsList = read("../public/data/documents.json", String) |> JSON.parse

if !isdir(OUTPATH)
	mkdir(OUTPATH)
end

# cd(SRCPATH)
for document in documentsList
	filetype = document["type"]
	path = SRCPATH
	if haskey(document, "dir")
		path *= "/"*document["dir"]
	end
	filename = path*"/"*document["doc"]*"."*filetype
	fileid = document["id"]
	
	println(filename)
	# cmd = `soffice --headless --convert-to htm:HTML --outdir $OUTPATH -outputfile $fileid $filename`
	cmd = `soffice --headless --convert-to htm:HTML --outdir $OUTPATH $filename`
	open(cmd)
	cp(filename, OUTPATH*"/"*fileid*"."*filetype, force=true)
	println(cmd)
end

