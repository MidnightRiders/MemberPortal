json.clubs do
  json.array!(@clubs) do |club|
    json.partial! 'club', club: club
  end
end
