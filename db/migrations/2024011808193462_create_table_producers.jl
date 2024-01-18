module CreateTableProducers

import SearchLight.Migrations: create_table, column, columns, pk, add_index, drop_table, add_indices

#=
	Insert into producers (producerId, latitude, longitude, name, firstname, lastname, city, postCode, address, phoneNumber, siret, email, website, `text`, wikiTitle, wikiDefaultTitle, shortDescription, openingHours, categories, noteModeration) 
select                         id, latitude, longitude, name, firstname, lastname, city, postCode, address, phoneNumber, siret, email, website, `text`, wikiTitle, wikiDefaultTitle, shortDescription, openingHours, categories, noteModeration
from producer p;
=#
function up()
  create_table(:producers) do
    [
      pk()
      column(:producerId, :integer)
      column(:latitude, :decimal, limit="10,7")
      column(:longitude, :decimal, limit="10,7")
      column(:name, :string, limit=128)
      column(:firstname, :string, limit=64)
      column(:lastname, :string, limit=128)
      column(:city, :string, limit=100)
      column(:postCode, :integer)
      column(:address, :string, limit=256)
      column(:phoneNumber, :string, limit=16)
      column(:siret, :string, limit=100)
      column(:email, :string, limit=256)
      column(:website, :string, limit=256)
      column(:text, :string, limit=1024)
      column(:wikiTitle, :string, limit=100)
      column(:wikiDefaultTitle, :string, limit=100)
      column(:shortDescription, :string, limit=512)
      column(:openingHours, :string, limit=512)
      column(:categories, :string, limit=64)
      column(:noteModeration, :string, limit=100)
    ]
  end

  add_index(:producers, :producerId)
  add_index(:producers, :name)
  # add_indices(:producers, :column_name_1, :column_name_2)
end

function down()
  drop_table(:producers)
end

end
