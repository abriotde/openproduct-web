#!/usr/local/bin/julia --startup=no

import JSON

OUTPATH="../openproduct-web/public/docs"
SRCPATH="../openproduct-docs"

documentsList = read("public/data/documents.json", String) |> JSON.parse

cd(SRCPATH)
if !isdir(OUTPATH)
	mkdir(OUTPATH)
end

for document in documentsList
	filetype = document["type"]
	filename = "../openproduct-docs/"*document["doc"]*"."filetype
	fileid = document["id"]
	println(filename)
	# cmd = `soffice --headless --convert-to htm:HTML --outdir $OUTPATH -outputfile $fileid $filename`
	cmd = `soffice --headless --convert-to htm:HTML --outdir $OUTPATH $filename`
	open(cmd)
	cp(filename, OUTPATH*"/"*fileid*"."*filetype)
	println(cmd)
end

