#!/bin/bash

source config.sh

EXPORT_SIZE=10000

for i in `seq 1 1`; do
	outfile="openproduct.producers$i.csv"
	limit_low=`echo $EXPORT_SIZE \* \( $i - 1 \) | bc`
	limit_hight=`echo $EXPORT_SIZE \* $i | bc`
	$MYSQL_CMD > $outfile <<EOF
	SELECT
		id, latitude, longitude, name as nom , firstname as prenom, lastname as nom_de_famille, city, postCode,
	address, siret, phoneNumber as telephone, phoneNumber2 as telephone2, email, sendEmail as envoieMail, website,
	text as description, shortDescription as metier, openingHours as horraire_ouverture,
	case 
		when categories like "H%" then "Habillement"
		when categories like "A%" then "Alimentaire"
		when categories like "3%" then "Produits"
		when categories like "4%" then "Plantes"
		when categories like "O%" then "Artisans / Artistes"
		when categories like "I%" then "PME"
		else "Else" end as category,
	noteModeration, startdate as date_debut, enddate as date_fin
	FROM openproduct.producer
	LIMIT $limit_low, $EXPORT_SIZE
EOF
	sed -i 's/,/ /g;s/	/,/g;s/\r//;s/\\n//' $outfile
done